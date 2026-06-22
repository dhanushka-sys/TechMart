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
import org.techmart.entity.AuditLog;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/audit")
public class AuditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AuditServlet.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private PerformanceMetricsRegistry metricsRegistry;

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
            List<AuditLog> audits = em.createQuery(
                "SELECT a FROM AuditLog a ORDER BY a.timestamp DESC", AuditLog.class)
                .setMaxResults(100)
                .getResultList();

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

            JsonObjectBuilder response = Json.createObjectBuilder()
                .add("totalAuditLogs", audits.size())
                .add("processedOrders", metricsRegistry.getTotalOrdersProcessed())
                .add("activeSessions", metricsRegistry.getActiveSessions())
                .add("auditLogs", auditsBuilder.build());

            out.print(response.build().toString());
        } catch (Exception e) {
            LOGGER.severe("Audit servlet failed: " + e.getMessage());
            out.print("{\"error\":\"Internal server error\"}");
        } finally {
            out.close();
        }
    }
}
