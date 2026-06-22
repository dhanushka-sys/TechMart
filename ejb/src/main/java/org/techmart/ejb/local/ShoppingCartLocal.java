package org.techmart.ejb.local;

import jakarta.ejb.Local;
import org.techmart.entity.CartItem;
import java.util.List;

@Local
public interface ShoppingCartLocal {
    void addItem(Long productId, String title, Integer quantity, java.math.BigDecimal price);
    void removeItem(Long productId);
    List<CartItem> getItems();
    void clearCart();
    void checkout(Long userId, OrderServiceLocal orderService) throws Exception;
    void destroyCart();
}
