package org.techmart.messaging;

import jakarta.annotation.Resource;
import jakarta.ejb.ActivationConfigProperty;
import jakarta.ejb.MessageDriven;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.jms.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.bean.PerformanceMetricsRegistry;
import org.techmart.ejb.local.InventoryCacheLocal;
import org.techmart.entity.Inventory;
import org.techmart.entity.Order;
import org.techmart.entity.OrderItem;
import java.util.logging.Level;
import java.util.logging.Logger;

@MessageDriven(
    activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "jms/orderQueue"),
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "jakarta.jms.Queue"),
        @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge")
    }
)
public class OrderProcessingMDB implements MessageListener {
    private static final Logger LOGGER = Logger.getLogger(OrderProcessingMDB.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private InventoryCacheLocal inventoryCache;

    @Inject
    private PerformanceMetricsRegistry metricsRegistry;

    @Inject
    private JMSContext jmsContext;

    @Resource(lookup = "jms/inventoryTopic")
    private Topic inventoryTopic;

    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public void onMessage(Message message) {
        LOGGER.info("[MDB] OrderProcessingMDB: onMessage invoked.");
        try {
            if (message instanceof MapMessage) {
                MapMessage mapMsg = (MapMessage) message;
                Long orderId = mapMsg.getLong("orderId");
                LOGGER.info("[MDB] Processing Order ID: " + orderId);

                Order order = em.find(Order.class, orderId);
                if (order == null) {
                    LOGGER.warning("[MDB] Order not found for ID: " + orderId);
                    return;
                }

                // Check inventory availability
                boolean isStockAvailable = true;
                for (OrderItem item : order.getItems()) {
                    Inventory inv = em.find(Inventory.class, item.getProduct().getId());
                    if (inv == null || inv.getQuantity() < item.getQuantity()) {
                        LOGGER.warning("[MDB] Insufficient inventory for Product ID: " + item.getProduct().getId());
                        isStockAvailable = false;
                        break;
                    }
                }

                if (isStockAvailable) {
                    // Deduct stock levels in database and cache
                    for (OrderItem item : order.getItems()) {
                        Inventory inv = em.find(Inventory.class, item.getProduct().getId());
                        int updatedQty = inv.getQuantity() - item.getQuantity();
                        inv.setQuantity(updatedQty);
                        em.merge(inv);

                        // Synchronize singleton memory cache
                        inventoryCache.updateStock(item.getProduct().getId(), updatedQty);
                        LOGGER.info("[MDB] Deducted stock for product " + item.getProduct().getId() + " to " + updatedQty);
                    }

                    // Update order status
                    order.setStatus("PROCESSED");
                    em.merge(order);
                    metricsRegistry.incrementOrdersProcessed();
                    LOGGER.info("[MDB] Order ID " + orderId + " marked as PROCESSED.");

                    // Publish to Topic for decoulped receivers
                    try {
                        MapMessage topicMsg = jmsContext.createMapMessage();
                        topicMsg.setLong("orderId", order.getId());
                        topicMsg.setString("status", "PROCESSED");
                        topicMsg.setString("userEmail", order.getUser().getEmail());
                        topicMsg.setDouble("totalAmount", order.getTotalAmount().doubleValue());
                        jmsContext.createProducer().send(inventoryTopic, topicMsg);
                        LOGGER.info("[MDB] Dispatched notification event to inventoryTopic for Order ID: " + order.getId());
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "[MDB] Failed to dispatch event to topic.", e);
                    }
                } else {
                    // Update order status to failed
                    order.setStatus("FAILED");
                    em.merge(order);
                    metricsRegistry.incrementOrdersFailed();
                    LOGGER.warning("[MDB] Order ID " + orderId + " set to FAILED due to stockout.");

                    // Send failed notification
                    try {
                        MapMessage topicMsg = jmsContext.createMapMessage();
                        topicMsg.setLong("orderId", order.getId());
                        topicMsg.setString("status", "FAILED");
                        topicMsg.setString("userEmail", order.getUser().getEmail());
                        topicMsg.setDouble("totalAmount", order.getTotalAmount().doubleValue());
                        jmsContext.createProducer().send(inventoryTopic, topicMsg);
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "[MDB] Failed to dispatch failed event to topic.", e);
                    }
                }
            } else {
                LOGGER.warning("[MDB] Unknown message format received: " + message.getClass().getName());
            }
        } catch (JMSException e) {
            LOGGER.log(Level.SEVERE, "[MDB] JMS Exception during order processing.", e);
            throw new RuntimeException("Rollback transaction due to messaging error.", e);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[MDB] General Exception during order processing.", e);
            throw new RuntimeException("Rollback transaction due to application error.", e);
        }
    }
}
