package org.techmart.ejb.local;

import jakarta.ejb.Local;
import java.util.Map;

@Local
public interface InventoryCacheLocal {
    Integer getStock(Long productId);
    void updateStock(Long productId, Integer quantity);
    void adjustStock(Long productId, Integer quantityChange);
    Map<Long, Integer> getCachedInventory();
    void refreshCache();
}
