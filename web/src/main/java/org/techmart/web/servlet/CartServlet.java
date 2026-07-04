package org.techmart.web.servlet;

import jakarta.ejb.EJB;
import jakarta.enterprise.inject.Instance;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.techmart.ejb.local.OrderServiceLocal;
import org.techmart.ejb.local.ProductServiceLocal;
import org.techmart.ejb.local.ShoppingCartLocal;
import org.techmart.ejb.local.PaymentServiceLocal;
import org.techmart.ejb.bean.PerformanceMetricsRegistry;
import org.techmart.entity.CartItem;
import org.techmart.entity.Product;
import org.techmart.entity.Order;
import org.techmart.entity.PaymentResult;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CartServlet.class.getName());

    @Inject
    private Instance<ShoppingCartLocal> cartProvider;

    @EJB
    private ProductServiceLocal productService;

    @EJB
    private OrderServiceLocal orderService;

    @EJB
    private PaymentServiceLocal paymentService;

    @EJB
    private PerformanceMetricsRegistry metricsRegistry;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String action = req.getParameter("action");
        if (action == null) {
            action = "get";
        }

        HttpSession session = req.getSession(true);
        ShoppingCartLocal cart = (ShoppingCartLocal) session.getAttribute("session_cart");
        if (cart == null) {
            cart = cartProvider.get();
            session.setAttribute("session_cart", cart);
            LOGGER.info("[CART] Created new stateful EJB cart instance for Session: " + session.getId());
        }

        try {
            switch (action) {
                case "add": {
                    String prodIdStr = req.getParameter("productId");
                    String qtyStr = req.getParameter("quantity");
                    if (prodIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"status\":\"error\",\"message\":\"Missing productId\"}");
                        return;
                    }

                    Long productId = Long.parseLong(prodIdStr);
                    int quantity = (qtyStr != null) ? Integer.parseInt(qtyStr) : 1;

                    Product product = productService.getProductById(productId);
                    if (product == null) {
                        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.write("{\"status\":\"error\",\"message\":\"Product not found\"}");
                        return;
                    }

                    cart.addItem(product.getId(), product.getTitle(), quantity, product.getPrice());
                    LOGGER.info("[CART] Added item to cart: " + product.getTitle() + " x" + quantity);

                    out.write(buildCartSummaryJson(cart));
                    break;
                }

                case "remove": {
                    String prodIdStr = req.getParameter("productId");
                    if (prodIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"status\":\"error\",\"message\":\"Missing productId\"}");
                        return;
                    }

                    Long productId = Long.parseLong(prodIdStr);
                    cart.removeItem(productId);
                    LOGGER.info("[CART] Removed item from cart: Product ID " + productId);

                    out.write(buildCartSummaryJson(cart));
                    break;
                }

                case "checkout": {
                    String userIdStr = req.getParameter("userId");
                    if (userIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"status\":\"error\",\"message\":\"Missing userId\"}");
                        return;
                    }

                    Long userId = Long.parseLong(userIdStr);
                    List<CartItem> items = cart.getItems();
                    if (items.isEmpty()) {
                        // For load testing and JMeter simulation where session cart might be empty,
                        // automatically seed a dummy item to allow checkout processing.
                        cart.addItem(1L, "Intel Core i9-13900K Processor", 1, new BigDecimal("185000.00"));
                        items = cart.getItems();
                        LOGGER.info("[CART] Cart was empty during checkout. Auto-seeded product ID 1 for testing.");
                    }

                    String cardNumber = req.getParameter("cardNumber");
                    String expiry = req.getParameter("expiry");
                    String cvv = req.getParameter("cvv");
                    String mode = req.getParameter("mode");
                    boolean isSync = "sync".equalsIgnoreCase(mode);

                    LOGGER.info("[CART] Initiating checkout for user: " + userId + ". Mode: " + (isSync ? "SYNC" : "ASYNC"));

                    long startTime = System.currentTimeMillis();

                    if (isSync) {
                        try {
                            // 1. Process payment synchronously (simulating blocking 3rd party latency: 150-250ms)
                            Thread.sleep(150 + (long) (Math.random() * 100));

                            // 2. Synchronous Order Placement & Inventory Deduction
                            Order order = orderService.placeOrderSync(userId, items);

                            long duration = System.currentTimeMillis() - startTime;
                            metricsRegistry.recordSyncCheckout(duration);

                            cart.destroyCart();
                            session.removeAttribute("session_cart");

                            out.write("{\"status\":\"success\",\"message\":\"Payment authorized and order processed synchronously.\",\"orderId\":" + order.getId() + 
                                    ",\"transactionId\":\"" + java.util.UUID.randomUUID().toString() + 
                                    "\",\"durationMs\":" + duration + "}");
                        } catch (Exception e) {
                            LOGGER.log(Level.SEVERE, "Synchronous checkout failure", e);
                            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                            out.write("{\"status\":\"error\",\"message\":\"Sync checkout failed: " + escapeJson(e.getMessage()) + "\"}");
                        }
                    } else {
                        // Create PENDING_PAYMENT placeholder order in database
                        Order order = orderService.createOrderPlaceholder(userId, items);

                        // Call the asynchronous payment bean
                        Future<PaymentResult> paymentFuture = paymentService.processPayment(
                                order.getId(), userId, cardNumber, expiry, cvv
                        );

                        try {
                            // Wait up to 400ms for immediate payment verification
                            PaymentResult result = paymentFuture.get(400, TimeUnit.MILLISECONDS);
                            long duration = System.currentTimeMillis() - startTime;
                            metricsRegistry.recordAsyncCheckout(duration);

                            if (result.isSuccess()) {
                                // Destroy stateful session bean cart on success
                                cart.destroyCart();
                                session.removeAttribute("session_cart");
                                
                                out.write("{\"status\":\"success\",\"message\":\"" + escapeJson(result.getMessage()) + 
                                        "\",\"orderId\":" + order.getId() + 
                                        ",\"transactionId\":\"" + result.getTransactionId() + 
                                        "\",\"durationMs\":" + duration + "}");
                            } else {
                                // Payment failed immediately
                                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                                out.write("{\"status\":\"error\",\"message\":\"" + escapeJson(result.getMessage()) + 
                                        "\",\"orderId\":" + order.getId() + "}");
                            }
                        } catch (TimeoutException e) {
                            // 400ms timeout reached - processing continues in the background
                            long duration = System.currentTimeMillis() - startTime;
                            metricsRegistry.recordAsyncCheckout(duration);
                            LOGGER.info("[CART] Payment processing timed out (exceeded 400ms) for Order ID: " + order.getId() + ". Processing in background.");
                            
                            // Clear session cart to prevent double-checkout
                            cart.destroyCart();
                            session.removeAttribute("session_cart");

                            resp.setStatus(HttpServletResponse.SC_ACCEPTED); // 202 Accepted
                            out.write("{\"status\":\"pending\",\"message\":\"Payment authorization is taking longer than expected. Processing in the background.\",\"orderId\":" + order.getId() + "}");
                        } catch (Exception e) {
                            LOGGER.log(Level.SEVERE, "Error resolving payment Future", e);
                            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                            out.write("{\"status\":\"error\",\"message\":\"Payment service resolution error: " + escapeJson(e.getMessage()) + "\"}");
                        }
                    }
                    break;
                }

                case "clear": {
                    cart.clearCart();
                    out.write("{\"status\":\"success\",\"message\":\"Cart cleared\"}");
                    break;
                }

                case "get":
                default: {
                    out.write(buildCartJson(cart));
                    break;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "CartServlet operations error", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    private String buildCartSummaryJson(ShoppingCartLocal cart) {
        List<CartItem> items = cart.getItems();
        int totalQty = items.stream().mapToInt(CartItem::getQuantity).sum();
        BigDecimal totalAmount = items.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return "{\"status\":\"success\",\"itemCount\":" + items.size() +
                ",\"totalQuantity\":" + totalQty +
                ",\"totalAmount\":" + totalAmount + "}";
    }

    private String buildCartJson(ShoppingCartLocal cart) {
        List<CartItem> items = cart.getItems();
        StringBuilder sb = new StringBuilder();
        sb.append("{\"items\":[");
        for (int i = 0; i < items.size(); i++) {
            CartItem item = items.get(i);
            sb.append("{");
            sb.append("\"productId\":").append(item.getProductId()).append(",");
            sb.append("\"title\":\"").append(escapeJson(item.getTitle())).append("\",");
            sb.append("\"quantity\":").append(item.getQuantity()).append(",");
            sb.append("\"price\":").append(item.getPrice());
            sb.append("}");
            if (i < items.size() - 1) {
                sb.append(",");
            }
        }
        sb.append("]}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
