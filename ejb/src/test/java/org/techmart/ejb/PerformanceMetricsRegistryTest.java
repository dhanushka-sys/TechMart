package org.techmart.ejb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.techmart.ejb.bean.PerformanceMetricsRegistry;

import static org.junit.jupiter.api.Assertions.*;

public class PerformanceMetricsRegistryTest {

    private PerformanceMetricsRegistry registry;

    @BeforeEach
    public void setUp() {
        registry = new PerformanceMetricsRegistry();
        registry.init();
    }

    @Test
    public void testProcessedAndFailedOrders() {
        registry.incrementOrdersProcessed();
        registry.incrementOrdersProcessed();
        registry.incrementOrdersFailed();

        assertEquals(2, registry.getTotalOrdersProcessed());
        assertEquals(1, registry.getTotalOrdersFailed());
    }

    @Test
    public void testActiveSessions() {
        registry.incrementActiveSessions();
        registry.incrementActiveSessions();
        registry.decrementActiveSessions();

        assertEquals(1, registry.getActiveSessions());
    }

    @Test
    public void testResponseTimes() {
        registry.recordSyncCheckout(120);
        registry.recordSyncCheckout(180);
        registry.recordAsyncCheckout(8);
        registry.recordAsyncCheckout(12);

        assertEquals(150.0, registry.getAverageSyncResponseTimeMs());
        assertEquals(10.0, registry.getAverageAsyncResponseTimeMs());
        assertEquals(2, registry.getSyncCheckoutCount());
        assertEquals(2, registry.getAsyncCheckoutCount());
    }
}
