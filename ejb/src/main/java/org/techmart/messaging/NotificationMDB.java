package org.techmart.messaging;

import jakarta.ejb.ActivationConfigProperty;
import jakarta.ejb.EJB;
import jakarta.ejb.MessageDriven;
import jakarta.jms.MapMessage;
import jakarta.jms.Message;
import jakarta.jms.MessageListener;
import org.techmart.ejb.bean.NotificationServiceBean;
import java.util.concurrent.Future;
import java.util.logging.Logger;

@MessageDriven(
    activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "jms/inventoryTopic"),
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "jakarta.jms.Topic"),
        @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge")
    }
)
public class NotificationMDB implements MessageListener {
    private static final Logger LOGGER = Logger.getLogger(NotificationMDB.class.getName());

    @EJB
    private NotificationServiceBean notificationService;

    @Override
    public void onMessage(Message message) {
        LOGGER.info("[MDB] NotificationMDB: Received message from inventoryTopic.");
        try {
            if (message instanceof MapMessage) {
                MapMessage mapMsg = (MapMessage) message;
                Long orderId = mapMsg.getLong("orderId");
                String status = mapMsg.getString("status");
                String email = mapMsg.getString("userEmail");
                double amount = mapMsg.getDouble("totalAmount");

                java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.US);
                nf.setMinimumFractionDigits(2);
                nf.setMaximumFractionDigits(2);
                String formattedAmount = "Rs. " + nf.format(amount);

                String subject = "TechMart Order Update: #" + orderId;
                String body = "Dear customer, your order of " + formattedAmount + " has been " + status.toLowerCase() + ".";

                LOGGER.info("[MDB] Invoking async EJB NotificationService for Order #" + orderId);
                // Call asynchronous EJB method (returns immediately)
                Future<Boolean> asyncResult = notificationService.sendEmailNotification(email, subject, body);
                
                // Fire-and-forget: we let the container thread pool process the notification in the background
            }
        } catch (Exception e) {
            LOGGER.severe("[MDB] Error in NotificationMDB processing: " + e.getMessage());
        }
    }
}
