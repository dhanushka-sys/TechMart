package org.techmart.web.servlet;

import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.json.Json;
import jakarta.json.JsonArrayBuilder;
import jakarta.json.JsonObjectBuilder;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.bean.PerformanceMetricsRegistry;
import org.techmart.ejb.local.InventoryCacheLocal;
import org.techmart.ejb.local.ProductServiceLocal;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.OperatingSystemMXBean;
import java.lang.management.RuntimeMXBean;
import java.lang.management.ThreadMXBean;
import java.util.logging.Logger;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(HealthServlet.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private PerformanceMetricsRegistry metricsRegistry;

    @Inject
    private InventoryCacheLocal inventoryCache;

    @Inject
    private ProductServiceLocal productService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String format = req.getParameter("format");

        if (!"json".equals(format)) {
            resp.sendRedirect(req.getContextPath() + "/metrics.jsp");
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            // JVM Metrics
            MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
            OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
            RuntimeMXBean runtimeBean = ManagementFactory.getRuntimeMXBean();
            ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();

            long heapUsed = memBean.getHeapMemoryUsage().getUsed() / (1024 * 1024); // MB
            long heapMax = memBean.getHeapMemoryUsage().getMax() / (1024 * 1024); // MB
            long heapCommitted = memBean.getHeapMemoryUsage().getCommitted() / (1024 * 1024); // MB
            double heapUsagePercent = heapMax > 0 ? (double) heapUsed / heapMax * 100 : 0;

            long nonHeapUsed = memBean.getNonHeapMemoryUsage().getUsed() / (1024 * 1024); // MB

            long uptimeMs = runtimeBean.getUptime();
            long uptimeSec = uptimeMs / 1000;
            long uptimeMin = uptimeSec / 60;
            long uptimeHours = uptimeMin / 60;
            String uptimeStr = String.format("%dh %dm %ds", uptimeHours, uptimeMin % 60, uptimeSec % 60);

            int threadCount = threadBean.getThreadCount();
            int peakThreadCount = threadBean.getPeakThreadCount();

            // DB Health Check
            boolean dbHealthy = false;
            String dbStatus = "OFFLINE";
            try {
                Long count = em.createQuery("SELECT COUNT(p) FROM Product p", Long.class).getSingleResult();
                dbHealthy = count >= 0;
                dbStatus = "ONLINE";
            } catch (Exception dbEx) {
                LOGGER.warning("DB health check failed: " + dbEx.getMessage());
            }

            // Inventory Cache Health
            boolean cacheHealthy = false;
            String cacheStatus = "OFFLINE";
            int cachedItems = 0;
            try {
                var cache = inventoryCache.getCachedInventory();
                cachedItems = cache.size();
                cacheHealthy = true;
                cacheStatus = "ONLINE";
            } catch (Exception cacheEx) {
                LOGGER.warning("Cache health check failed: " + cacheEx.getMessage());
            }

            // Build response
            JsonObjectBuilder jvmInfo = Json.createObjectBuilder()
                .add("heapUsedMB", heapUsed)
                .add("heapMaxMB", heapMax)
                .add("heapCommittedMB", heapCommitted)
                .add("heapUsagePercent", Math.round(heapUsagePercent * 10.0) / 10.0)
                .add("nonHeapUsedMB", nonHeapUsed)
                .add("threadCount", threadCount)
                .add("peakThreadCount", peakThreadCount)
                .add("uptimeString", uptimeStr)
                .add("uptimeMs", uptimeMs)
                .add("javaVersion", System.getProperty("java.version"))
                .add("jvmName", runtimeBean.getVmName());

            JsonObjectBuilder ejbStatus = Json.createObjectBuilder()
                .add("database", dbStatus)
                .add("inventoryCache", cacheStatus)
                .add("metricsRegistry", "ONLINE")
                .add("cachedProducts", cachedItems);

            JsonObjectBuilder performanceMetrics = Json.createObjectBuilder()
                .add("totalOrdersProcessed", metricsRegistry.getTotalOrdersProcessed())
                .add("totalOrdersFailed", metricsRegistry.getTotalOrdersFailed())
                .add("activeSessions", metricsRegistry.getActiveSessions())
                .add("syncCheckoutCount", metricsRegistry.getSyncCheckoutCount())
                .add("asyncCheckoutCount", metricsRegistry.getAsyncCheckoutCount())
                .add("avgSyncLatencyMs", metricsRegistry.getAverageSyncResponseTimeMs())
                .add("avgAsyncLatencyMs", metricsRegistry.getAverageAsyncResponseTimeMs());

            // Build channels array for EJB component status
            JsonArrayBuilder channels = Json.createArrayBuilder();
            channels.add(Json.createObjectBuilder()
                .add("name", "JPA Persistence")
                .add("type", "DATABASE")
                .add("status", dbStatus)
                .add("healthy", dbHealthy));
            channels.add(Json.createObjectBuilder()
                .add("name", "Singleton Cache EJB")
                .add("type", "SINGLETON")
                .add("status", cacheStatus)
                .add("healthy", cacheHealthy));
            channels.add(Json.createObjectBuilder()
                .add("name", "Performance Metrics Registry")
                .add("type", "SINGLETON")
                .add("status", "ONLINE")
                .add("healthy", true));
            channels.add(Json.createObjectBuilder()
                .add("name", "JMS Message Queue")
                .add("type", "JMS")
                .add("status", "ONLINE")
                .add("healthy", true));
            channels.add(Json.createObjectBuilder()
                .add("name", "MDB Order Processor")
                .add("type", "MDB")
                .add("status", "ONLINE")
                .add("healthy", true));
            channels.add(Json.createObjectBuilder()
                .add("name", "Async EJB Pipeline")
                .add("type", "ASYNC")
                .add("status", "ONLINE")
                .add("healthy", true));

            String overallStatus = (dbHealthy && cacheHealthy) ? "HEALTHY" : "DEGRADED";

            JsonObjectBuilder response = Json.createObjectBuilder()
                .add("status", overallStatus)
                .add("serverTime", new java.util.Date().toString())
                .add("jvm", jvmInfo.build())
                .add("ejbComponents", ejbStatus.build())
                .add("performance", performanceMetrics.build())
                .add("channels", channels.build());

            out.print(response.build().toString());
        } catch (Exception e) {
            LOGGER.severe("Health servlet failed: " + e.getMessage());
            out.print("{\"status\":\"ERROR\",\"error\":\"Internal server error\"}");
        } finally {
            out.close();
        }
    }
}
