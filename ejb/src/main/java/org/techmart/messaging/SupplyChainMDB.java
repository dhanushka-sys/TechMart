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
public class SupplyChainMDB implements MessageListener {
    private static final Logger LOGGER = Logger.getLogger(SupplyChainMDB.class.getName());

    @Override
    public void onMessage(Message message) {
        LOGGER.info("[MDB] SupplyChainMDB: Received message from inventoryTopic.");
        try {
            if (message instanceof MapMessage) {
                MapMessage mapMsg = (MapMessage) message;
                if (!mapMsg.itemExists("orderId")) {
                    return;
                }
                Long orderId = mapMsg.getLong("orderId");
                String status = mapMsg.getString("status");

                // Simulating conceptual integration update to Legacy ERP (e.g. C++ CORBA interface)
                LOGGER.info("[MDB] ERP INTEGRATION SIMULATION: Synchronizing status to Legacy ERP...");
                LOGGER.info("[MDB] Order ID #" + orderId + " is synced with ERP. Action: ERP_UPDATE, Status: " + status);
            }
        } catch (Exception e) {
            LOGGER.severe("[MDB] Error in SupplyChainMDB: " + e.getMessage());
        }
    }
}
