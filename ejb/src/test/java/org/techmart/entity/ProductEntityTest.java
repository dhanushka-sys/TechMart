package org.techmart.entity;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

public class ProductEntityTest {

    @Test
    public void testProductGettersAndSetters() {
        Product p = new Product();
        p.setId(1L);
        p.setSku("SKU-999");
        p.setTitle("Test GPU RTX");
        p.setDescription("Flagship GPU description");
        p.setPrice(new BigDecimal("1500.00"));

        assertEquals(1L, p.getId());
        assertEquals("SKU-999", p.getSku());
        assertEquals("Test GPU RTX", p.getTitle());
        assertEquals("Flagship GPU description", p.getDescription());
        assertEquals(new BigDecimal("1500.00"), p.getPrice());
    }

    @Test
    public void testCartItemProperties() {
        CartItem item = new CartItem(10L, "DDR5 RAM", 2, new BigDecimal("120.00"));

        assertEquals(10L, item.getProductId());
        assertEquals("DDR5 RAM", item.getTitle());
        assertEquals(2, item.getQuantity());
        assertEquals(new BigDecimal("120.00"), item.getPrice());
    }
}
