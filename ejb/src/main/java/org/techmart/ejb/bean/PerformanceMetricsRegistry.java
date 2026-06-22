package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.ConcurrencyManagement;
import jakarta.ejb.ConcurrencyManagementType;
import jakarta.ejb.Lock;
import jakarta.ejb.LockType;
import jakarta.ejb.Singleton;
import java.util.concurrent.atomic.AtomicLong;
import java.util.logging.Logger;

@Singleton
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class PerformanceMetricsRegistry {
    private static final Logger LOGGER = Logger.getLogger(PerformanceMetricsRegistry.class.getName());

    private final AtomicLong totalOrdersProcessed = new AtomicLong(0);
    private final AtomicLong totalOrdersFailed = new AtomicLong(0);
    private final AtomicLong activeSessions = new AtomicLong(0);

    private final AtomicLong syncCheckoutCount = new AtomicLong(0);
    private final AtomicLong syncCheckoutTimeSum = new AtomicLong(0);

    private final AtomicLong asyncCheckoutCount = new AtomicLong(0);
    private final AtomicLong asyncCheckoutTimeSum = new AtomicLong(0);

    @PostConstruct
    public void init() {
        LOGGER.info("[LIFECYCLE] PerformanceMetricsRegistry @PostConstruct: Metrics monitoring initialized.");
    }

    @Lock(LockType.WRITE)
    public void incrementOrdersProcessed() {
        totalOrdersProcessed.incrementAndGet();
    }

    @Lock(LockType.WRITE)
    public void incrementOrdersFailed() {
        totalOrdersFailed.incrementAndGet();
    }

    @Lock(LockType.WRITE)
    public void incrementActiveSessions() {
        activeSessions.incrementAndGet();
    }

    @Lock(LockType.WRITE)
    public void decrementActiveSessions() {
        activeSessions.decrementAndGet();
    }

    @Lock(LockType.WRITE)
    public void recordSyncCheckout(long timeMs) {
        syncCheckoutCount.incrementAndGet();
        syncCheckoutTimeSum.addAndGet(timeMs);
    }

    @Lock(LockType.WRITE)
    public void recordAsyncCheckout(long timeMs) {
        asyncCheckoutCount.incrementAndGet();
        asyncCheckoutTimeSum.addAndGet(timeMs);
    }

    @Lock(LockType.READ)
    public long getTotalOrdersProcessed() {
        return totalOrdersProcessed.get();
    }

    @Lock(LockType.READ)
    public long getTotalOrdersFailed() {
        return totalOrdersFailed.get();
    }

    @Lock(LockType.READ)
    public long getActiveSessions() {
        return activeSessions.get();
    }

    @Lock(LockType.READ)
    public double getAverageSyncResponseTimeMs() {
        long count = syncCheckoutCount.get();
        return count == 0 ? 0.0 : (double) syncCheckoutTimeSum.get() / count;
    }

    @Lock(LockType.READ)
    public double getAverageAsyncResponseTimeMs() {
        long count = asyncCheckoutCount.get();
        return count == 0 ? 0.0 : (double) asyncCheckoutTimeSum.get() / count;
    }

    @Lock(LockType.READ)
    public long getSyncCheckoutCount() {
        return syncCheckoutCount.get();
    }

    @Lock(LockType.READ)
    public long getAsyncCheckoutCount() {
        return asyncCheckoutCount.get();
    }

    @Lock(LockType.WRITE)
    public void resetMetrics() {
        totalOrdersProcessed.set(0);
        totalOrdersFailed.set(0);
        activeSessions.set(0);
        syncCheckoutCount.set(0);
        syncCheckoutTimeSum.set(0);
        asyncCheckoutCount.set(0);
        asyncCheckoutTimeSum.set(0);
        LOGGER.info("Performance registry metrics reset.");
    }
}
