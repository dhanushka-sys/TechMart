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
import org.techmart.entity.Inventory;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(InventoryServlet.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private InventoryCacheLocal inventoryCache;

    @Inject
    private ProductServiceLocal productService;

    @Inject
    private PerformanceMetricsRegistry metricsRegistry;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String format = req.getParameter("format");

        if (!"json".equals(format)) {
            resp.sendRedirect(req.getContextPath() + "/inventory.jsp");
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            List<Product> products = productService.getAllProducts();
            Map<Long, Integer> cachedStock = inventoryCache.getCachedInventory();

            JsonArrayBuilder productsBuilder = Json.createArrayBuilder();
            for (Product p : products) {
                int stock = cachedStock.getOrDefault(p.getId(), 0);
                String stockStatus;
                if (stock <= 0) stockStatus = "OUT_OF_STOCK";
                else if (stock < 20) stockStatus = "LOW";
                else stockStatus = "IN_STOCK";

                productsBuilder.add(Json.createObjectBuilder()
                    .add("id", p.getId())
                    .add("sku", p.getSku())
                    .add("title", p.getTitle())
                    .add("price", p.getPrice().doubleValue())
                    .add("stock", stock)
                    .add("stockStatus", stockStatus)
                );
            }

            int totalProducts = products.size();
            int totalStock = cachedStock.values().stream().mapToInt(Integer::intValue).sum();
            long lowStockCount = products.stream()
                .filter(p -> cachedStock.getOrDefault(p.getId(), 0) < 20)
                .count();

            JsonObjectBuilder response = Json.createObjectBuilder()
                .add("totalProducts", totalProducts)
                .add("totalStock", totalStock)
                .add("lowStockCount", (int) lowStockCount)
                .add("syncLatency", metricsRegistry.getAverageSyncResponseTimeMs())
                .add("products", productsBuilder.build());

            out.print(response.build().toString());
        } catch (Exception e) {
            LOGGER.severe("Failed to build inventory payload: " + e.getMessage());
            out.print("{\"error\":\"Internal server error constructing inventory payload\"}");
        } finally {
            out.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            if ("restock".equals(action)) {
                String productIdStr = req.getParameter("productId");
                String quantityStr = req.getParameter("quantity");
                if (productIdStr != null && quantityStr != null) {
                    long productId = Long.parseLong(productIdStr);
                    int quantity = Integer.parseInt(quantityStr);
                    
                    // Call transactional stateless EJB
                    productService.restockProduct(productId, quantity);
                    
                    // Refresh cache
                    inventoryCache.refreshCache();
                    
                    out.print("{\"status\":\"success\",\"message\":\"Stock updated\"}");
                } else {
                    out.print("{\"status\":\"error\",\"message\":\"Missing productId or quantity\"}");
                }
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Unknown action\"}");
            }
        } catch (Exception e) {
            LOGGER.severe("Inventory POST failed: " + e.getMessage());
            out.print("{\"status\":\"error\",\"message\":\"Internal error\"}");
        } finally {
            out.close();
        }
    }
}
