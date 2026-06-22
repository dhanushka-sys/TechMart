package org.techmart.ejb.remote;

import jakarta.ejb.Remote;
import org.techmart.entity.Order;
import org.techmart.entity.CartItem;
import org.techmart.exception.InventoryException;
import java.util.List;

@Remote
public interface OrderServiceRemote {
    Order placeOrder(Long userId, List<CartItem> cartItems) throws InventoryException;
    Order createOrderPlaceholder(Long userId, List<CartItem> cartItems) throws InventoryException;
    Order getOrderById(Long id);
    List<Order> getOrdersByUser(Long userId);
    List<Order> getAllOrders();
}
