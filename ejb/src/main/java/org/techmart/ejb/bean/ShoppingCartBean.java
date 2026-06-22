package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.PostActivate;
import jakarta.ejb.PrePassivate;
import jakarta.ejb.Remove;
import jakarta.ejb.Stateful;
import org.techmart.ejb.local.OrderServiceLocal;
import org.techmart.ejb.local.ShoppingCartLocal;
import org.techmart.entity.CartItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Stateful
public class ShoppingCartBean implements ShoppingCartLocal, Serializable {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ShoppingCartBean.class.getName());

    private List<CartItem> items;

    @PostConstruct
    public void init() {
        items = new ArrayList<>();
        LOGGER.info("[LIFECYCLE] ShoppingCartBean @PostConstruct: Conversational state initialized.");
    }

    @PreDestroy
    public void cleanup() {
        LOGGER.info("[LIFECYCLE] ShoppingCartBean @PreDestroy: Stateful session terminating.");
    }

    @PrePassivate
    public void passivate() {
        LOGGER.info("[LIFECYCLE] ShoppingCartBean @PrePassivate: Serializing and passivating cart state.");
    }

    @PostActivate
    public void activate() {
        LOGGER.info("[LIFECYCLE] ShoppingCartBean @PostActivate: Deserializing and activating cart state.");
    }

    @Override
    public void addItem(Long productId, String title, Integer quantity, BigDecimal price) {
        LOGGER.info("Adding item: Product ID " + productId + ", Qty: " + quantity);
        for (CartItem item : items) {
            if (item.getProductId().equals(productId)) {
                item.setQuantity(item.getQuantity() + quantity);
                return;
            }
        }
        items.add(new CartItem(productId, title, quantity, price));
    }

    @Override
    public void removeItem(Long productId) {
        LOGGER.info("Removing Product ID: " + productId);
        items.removeIf(item -> item.getProductId().equals(productId));
    }

    @Override
    public List<CartItem> getItems() {
        LOGGER.info("Fetching cart items. Current item count: " + items.size());
        return items;
    }

    @Override
    public void clearCart() {
        LOGGER.info("Clearing cart.");
        items.clear();
    }

    @Override
    @Remove
    public void checkout(Long userId, OrderServiceLocal orderService) throws Exception {
        LOGGER.info("Initiating checkout boundary in @Remove method for User ID: " + userId);
        orderService.placeOrder(userId, new ArrayList<>(items));
        items.clear();
        LOGGER.info("Stateful bean cleared and marked for container destruction.");
    }

    @Override
    @Remove
    public void destroyCart() {
        LOGGER.info("Explicitly destroying ShoppingCartBean stateful EJB instance.");
        items.clear();
    }
}
