package org.techmart.ejb;

import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit5.ArquillianExtension;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import jakarta.ejb.EJB;
import org.techmart.ejb.local.OrderServiceLocal;
import org.techmart.entity.Order;
import org.techmart.entity.CartItem;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Disabled;

@Disabled("Requires a fully configured Payara Micro container with MySQL JDBC driver and JMS JNDI resources.")
@ExtendWith(ArquillianExtension.class)
public class OrderServiceIntegrationTest {

    @Deployment
    public static WebArchive createDeployment() {
        String driverJarPath = System.getProperty("mysql.driverJar");
        if (driverJarPath == null) {
            driverJarPath = "target/mysql-connector-j.jar";
        }
        return ShrinkWrap.create(WebArchive.class, "techmart-test.war")
                .addPackages(true, org.jboss.shrinkwrap.api.Filters.exclude(".*messaging.*"), "org.techmart")
                .addAsLibrary(new java.io.File(driverJarPath))
                .addAsResource("META-INF/persistence.xml");
    }

    @EJB
    private OrderServiceLocal orderService;

    @Test
    public void testOrderServiceInjection() {
        assertNotNull(orderService, "OrderServiceLocal EJB should be successfully injected by Arquillian container");
    }

    @Test
    public void testOrderLookupWithNonExistentId() {
        Order order = orderService.getOrderById(9999L);
        assertNull(order, "Order lookup for non-existent ID should return null");
    }
}
