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
import org.techmart.ejb.local.OrderServiceLocal;
import org.techmart.entity.Order;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(OrdersServlet.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private OrderServiceLocal orderService;

    @Inject
    private PerformanceMetricsRegistry metricsRegistry;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String format = req.getParameter("format");

        if (!"json".equals(format)) {
            resp.sendRedirect(req.getContextPath() + "/orders.jsp");
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            List<Order> orders = orderService.getAllOrders();

            JsonArrayBuilder ordersBuilder = Json.createArrayBuilder();
            double totalRevenue = 0;
            int processedCount = 0;
            int pendingCount = 0;
            int failedCount = 0;

            for (Order o : orders) {
                String email = (o.getUser() != null) ? o.getUser().getEmail() : "system@techmart.com";
                String orderTime = (o.getOrderedAt() != null) ? o.getOrderedAt().toString() : "";
                double amount = (o.getTotalAmount() != null) ? o.getTotalAmount().doubleValue() : 0.0;

                if ("PROCESSED".equals(o.getStatus()) || "PAYMENT_SUCCESS".equals(o.getStatus())) {
                    processedCount++;
                    totalRevenue += amount;
                } else if ("PENDING".equals(o.getStatus()) || "PENDING_PAYMENT".equals(o.getStatus())) {
                    pendingCount++;
                } else if ("FAILED".equals(o.getStatus()) || "CANCELLED".equals(o.getStatus()) || "FAILED_PAYMENT".equals(o.getStatus())) {
                    failedCount++;
                }

                ordersBuilder.add(Json.createObjectBuilder()
                    .add("id", o.getId())
                    .add("userEmail", email)
                    .add("totalAmount", amount)
                    .add("status", o.getStatus())
                    .add("orderedAt", orderTime)
                );
            }

            JsonObjectBuilder response = Json.createObjectBuilder()
                .add("totalOrders", orders.size())
                .add("processedCount", processedCount)
                .add("pendingCount", pendingCount)
                .add("failedCount", failedCount)
                .add("totalRevenue", totalRevenue)
                .add("processedOrders", metricsRegistry.getTotalOrdersProcessed())
                .add("failedOrders", metricsRegistry.getTotalOrdersFailed())
                .add("syncLatency", metricsRegistry.getAverageSyncResponseTimeMs())
                .add("asyncLatency", metricsRegistry.getAverageAsyncResponseTimeMs())
                .add("orders", ordersBuilder.build());

            out.print(response.build().toString());
        } catch (Exception e) {
            LOGGER.severe("Orders servlet failed: " + e.getMessage());
            out.print("{\"error\":\"Internal server error\"}");
        } finally {
            out.close();
        }
    }
}
