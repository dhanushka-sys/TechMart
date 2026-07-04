package org.techmart.ejb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.techmart.ejb.bean.ShoppingCartBean;
import org.techmart.entity.CartItem;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class ShoppingCartBeanTest {

    private ShoppingCartBean cart;

    @BeforeEach
    public void setUp() {
        cart = new ShoppingCartBean();
        cart.init();
    }

    @Test
    public void testAddItem() {
        cart.addItem(1L, "Test Product", 2, new BigDecimal("99.99"));
        List<CartItem> items = cart.getItems();
        assertEquals(1, items.size());
        assertEquals(2, items.get(0).getQuantity());
        assertEquals("Test Product", items.get(0).getTitle());
    }

    @Test
    public void testAddDuplicateItem() {
        cart.addItem(1L, "Test Product", 2, new BigDecimal("99.99"));
        cart.addItem(1L, "Test Product", 3, new BigDecimal("99.99"));
        List<CartItem> items = cart.getItems();
        assertEquals(1, items.size());
        assertEquals(5, items.get(0).getQuantity());
    }

    @Test
    public void testRemoveItem() {
        cart.addItem(1L, "Test Product", 2, new BigDecimal("99.99"));
        cart.removeItem(1L);
        assertTrue(cart.getItems().isEmpty());
    }

    @Test
    public void testClearCart() {
        cart.addItem(1L, "Test Product", 2, new BigDecimal("99.99"));
        cart.clearCart();
        assertTrue(cart.getItems().isEmpty());
    }
}
