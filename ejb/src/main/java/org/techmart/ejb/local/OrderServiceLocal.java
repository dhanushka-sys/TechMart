package org.techmart.ejb.local;

import jakarta.ejb.Local;
import org.techmart.entity.Order;
import org.techmart.entity.CartItem;
import org.techmart.exception.InventoryException;
import java.util.List;

@Local
public interface OrderServiceLocal {
    Order placeOrder(Long userId, List<CartItem> cartItems) throws InventoryException;
    Order createOrderPlaceholder(Long userId, List<CartItem> cartItems) throws InventoryException;
    Order getOrderById(Long id);
    List<Order> getOrdersByUser(Long userId);
    List<Order> getAllOrders();
}
