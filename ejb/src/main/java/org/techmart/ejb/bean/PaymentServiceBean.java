package org.techmart.ejb.bean;

import jakarta.annotation.Resource;
import jakarta.ejb.AsyncResult;
import jakarta.ejb.Asynchronous;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.jms.JMSContext;
import jakarta.jms.MapMessage;
import jakarta.jms.Queue;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.local.PaymentServiceLocal;
import org.techmart.entity.AuditLog;
import org.techmart.entity.Order;
import org.techmart.entity.PaymentResult;

import java.util.UUID;
import java.util.concurrent.Future;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
public class PaymentServiceBean implements PaymentServiceLocal {
    private static final Logger LOGGER = Logger.getLogger(PaymentServiceBean.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private JMSContext jmsContext;

    @Resource(lookup = "jms/orderQueue")
    private Queue orderQueue;

    @Override
    @Asynchronous
    @TransactionAttribute(TransactionAttributeType.REQUIRES_NEW)
    public Future<PaymentResult> processPayment(Long orderId, Long userId, String cardNumber, String expiry, String cvv) {
        long startTime = System.currentTimeMillis();
        LOGGER.info("[ASYNC] Starting asynchronous payment processing for Order ID: " + orderId + ", User ID: " + userId);

        // 1. Simulate processing delay (randomized between 300ms and 700ms to test timeout logic)
        long delay = 300 + (long) (Math.random() * 400);
        try {
            Thread.sleep(delay);
        } catch (InterruptedException e) {
            LOGGER.log(Level.WARNING, "Payment processing thread interrupted", e);
            Thread.currentThread().interrupt();
        }

        // 2. Decide outcome (95% success rate, 5% failure rate)
        boolean success = Math.random() < 0.95;
        long durationMs = System.currentTimeMillis() - startTime;
        String transactionId = UUID.randomUUID().toString();
        String messageDetail = success ? "Payment Authorized Successfully" : "Payment Declined: Insufficient Funds";

        LOGGER.info("[ASYNC] Payment simulation finished. Result: " + (success ? "SUCCESS" : "FAILED") + " in " + durationMs + "ms");

        try {
            // Find order
            Order order = em.find(Order.class, orderId);
            if (order != null) {
                if (success) {
                    order.setStatus("PAYMENT_SUCCESS");
                } else {
                    order.setStatus("FAILED_PAYMENT");
                }
                em.merge(order);

                // Write Audit Log
                AuditLog audit = new AuditLog();
                audit.setAction(success ? "PAYMENT_SUCCESS" : "PAYMENT_FAILED");
                audit.setTargetType("Order");
                audit.setTargetId(orderId);
                audit.setChangedBy(order.getUser().getEmail());
                em.persist(audit);
                em.flush();

                LOGGER.info("[ASYNC] Updated order ID: " + orderId + " status to: " + order.getStatus());

                // 3. Dispatch to JMS Queue ONLY if payment was successful
                if (success) {
                    try {
                        MapMessage jmsMsg = jmsContext.createMapMessage();
                        jmsMsg.setLong("orderId", orderId);
                        jmsMsg.setLong("userId", userId);
                        jmsContext.createProducer().send(orderQueue, jmsMsg);
                        LOGGER.info("[ASYNC] Successfully dispatched Order ID: " + orderId + " to jms/orderQueue for inventory processing.");
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "[ASYNC] Failed to dispatch order to JMS. Triggering failure rollback path.", e);
                        order.setStatus("FAILED_PAYMENT");
                        em.merge(order);
                        
                        AuditLog rollbackAudit = new AuditLog();
                        rollbackAudit.setAction("PAYMENT_JMS_FAILED");
                        rollbackAudit.setTargetType("Order");
                        rollbackAudit.setTargetId(orderId);
                        rollbackAudit.setChangedBy(order.getUser().getEmail());
                        em.persist(rollbackAudit);
                    }
                }
            } else {
                LOGGER.warning("[ASYNC] Order ID " + orderId + " not found to update payment status.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[ASYNC] Error updating database states for Order: " + orderId, e);
            success = false;
            messageDetail = "Internal payment processing error: " + e.getMessage();
        }

        PaymentResult result = new PaymentResult(success, messageDetail, durationMs, transactionId);
        return new AsyncResult<>(result);
    }
}
