package org.techmart.config;

import jakarta.jms.JMSConnectionFactoryDefinition;
import jakarta.jms.JMSDestinationDefinition;
import jakarta.jms.JMSDestinationDefinitions;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

@Singleton
@Startup
@JMSConnectionFactoryDefinition(
    name = "jms/TechMartConnectionFactory",
    maxPoolSize = 50,
    minPoolSize = 10
)
@JMSDestinationDefinitions({
    @JMSDestinationDefinition(
        name = "jms/orderQueue",
        interfaceName = "jakarta.jms.Queue",
        destinationName = "orderQueue"
    ),
    @JMSDestinationDefinition(
        name = "jms/inventoryTopic",
        interfaceName = "jakarta.jms.Topic",
        destinationName = "inventoryTopic"
    )
})
public class JmsConfig {
    // Container automatically parses these annotations at deployment time
    // and exposes resources under the defined JNDI names.
}
