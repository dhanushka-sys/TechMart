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
import org.techmart.entity.Product;
import org.techmart.entity.Order;
import org.techmart.entity.AuditLog;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DashboardServlet.class.getName());

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
        String action = req.getParameter("action");

        // Action: Reset Metrics
        if ("reset".equals(action)) {
            metricsRegistry.resetMetrics();
            if ("json".equals(format)) {
                resp.setContentType("application/json");
                resp.getWriter().write("{\"status\":\"success\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            }
            return;
        }

        // If format is not specified as json, redirect client to the static dashboard.jsp page
        if (!"json".equals(format)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
            return;
        }

        // Generate JSON response for AJAX dashboard client
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            // Retrieve catalog, stocks, recent orders, and security audit logs
            List<Product> products = productService.getAllProducts();
            Map<Long, Integer> cachedStock = inventoryCache.getCachedInventory();

            List<Order> orders = em.createQuery("SELECT o FROM Order o ORDER BY o.orderedAt DESC", Order.class)
                    .setMaxResults(10)
                    .getResultList();

            List<AuditLog> audits = em.createQuery("SELECT a FROM AuditLog a ORDER BY a.timestamp DESC", AuditLog.class)
                    .setMaxResults(15)
                    .getResultList();

            BigDecimal totalRevenue = em.createQuery("SELECT SUM(o.totalAmount) FROM Order o WHERE o.status = 'PROCESSED'", BigDecimal.class).getSingleResult();
            if (totalRevenue == null) {
                totalRevenue = BigDecimal.ZERO;
            }

            int totalProducts = products.size();
            int totalStock = cachedStock.values().stream().mapToInt(Integer::intValue).sum();

            JsonObjectBuilder json = Json.createObjectBuilder()
                .add("syncLatency", metricsRegistry.getAverageSyncResponseTimeMs())
                .add("asyncLatency", metricsRegistry.getAverageAsyncResponseTimeMs())
                .add("processedOrders", metricsRegistry.getTotalOrdersProcessed())
                .add("failedOrders", metricsRegistry.getTotalOrdersFailed())
                .add("syncCount", metricsRegistry.getSyncCheckoutCount())
                .add("asyncCount", metricsRegistry.getAsyncCheckoutCount())
                .add("activeSessions", metricsRegistry.getActiveSessions())
                .add("totalProducts", totalProducts)
                .add("totalStock", totalStock)
                .add("totalRevenue", totalRevenue.doubleValue());

            // Build stocks object
            JsonObjectBuilder stockBuilder = Json.createObjectBuilder();
            for (Map.Entry<Long, Integer> entry : cachedStock.entrySet()) {
                stockBuilder.add(entry.getKey().toString(), entry.getValue());
            }
            json.add("stocks", stockBuilder.build());

            // Build catalog array
            JsonArrayBuilder catalogBuilder = Json.createArrayBuilder();
            for (Product p : products) {
                catalogBuilder.add(Json.createObjectBuilder()
                    .add("id", p.getId())
                    .add("sku", p.getSku())
                    .add("title", p.getTitle())
                    .add("price", p.getPrice().doubleValue())
                );
            }
            json.add("catalog", catalogBuilder.build());

            // Build recent orders array
            JsonArrayBuilder ordersBuilder = Json.createArrayBuilder();
            for (Order o : orders) {
                // Ensure LAZY properties don't throw exception on serialisation
                String email = (o.getUser() != null) ? o.getUser().getEmail() : "system@techmart.com";
                String orderTime = (o.getOrderedAt() != null) ? o.getOrderedAt().toString() : "";
                
                ordersBuilder.add(Json.createObjectBuilder()
                    .add("id", o.getId())
                    .add("userEmail", email)
                    .add("totalAmount", o.getTotalAmount().doubleValue())
                    .add("status", o.getStatus())
                    .add("orderedAt", orderTime)
                );
            }
            json.add("recentOrders", ordersBuilder.build());

            // Build recent audits array
            JsonArrayBuilder auditsBuilder = Json.createArrayBuilder();
            for (AuditLog a : audits) {
                String logTime = (a.getTimestamp() != null) ? a.getTimestamp().toString() : "";
                auditsBuilder.add(Json.createObjectBuilder()
                    .add("id", a.getId())
                    .add("action", a.getAction())
                    .add("targetType", a.getTargetType())
                    .add("targetId", a.getTargetId())
                    .add("changedBy", a.getChangedBy())
                    .add("timestamp", logTime)
                );
            }
            json.add("recentAudits", auditsBuilder.build());

            // Output JSON object
            out.print(json.build().toString());
        } catch (Exception e) {
            LOGGER.severe("Failed to generate JSON metrics payload: " + e.getMessage());
            out.print("{\"error\":\"Internal server error constructing payload\"}");
        } finally {
            out.close();
        }
    }
}
