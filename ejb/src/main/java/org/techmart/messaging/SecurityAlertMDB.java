package org.techmart.messaging;

import jakarta.ejb.ActivationConfigProperty;
import jakarta.ejb.MessageDriven;
import jakarta.jms.MapMessage;
import jakarta.jms.Message;
import jakarta.jms.MessageListener;
import java.util.logging.Logger;

@MessageDriven(
    activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "jms/inventoryTopic"),
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "jakarta.jms.Topic"),
        @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge")
    }
)
public class SecurityAlertMDB implements MessageListener {
    private static final Logger LOGGER = Logger.getLogger(SecurityAlertMDB.class.getName());

    @Override
    public void onMessage(Message message) {
        try {
            if (message instanceof MapMessage) {
                MapMessage mapMsg = (MapMessage) message;
                String eventType = mapMsg.getString("eventType");
                
                if ("LOGIN_SUCCESS".equals(eventType) || "LOGIN_FAILURE".equals(eventType)) {
                    String email = mapMsg.getString("email");
                    String ip = mapMsg.getString("ipAddress");
                    String timestamp = mapMsg.getString("timestamp");
                    
                    if ("LOGIN_SUCCESS".equals(eventType)) {
                        LOGGER.warning("[SECURITY ALERT - JMS] SUCCESSFUL LOGIN: User '" + email + "' logged in from IP " + ip + " at " + timestamp);
                    } else {
                        LOGGER.severe("[SECURITY ALERT - JMS] FAILED LOGIN ATTEMPT: Email '" + email + "' with incorrect password from IP " + ip + " at " + timestamp);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.severe("[MDB] Error in SecurityAlertMDB: " + e.getMessage());
        }
    }
}
