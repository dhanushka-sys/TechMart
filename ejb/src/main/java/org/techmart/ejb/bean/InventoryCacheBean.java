package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.*;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.local.InventoryCacheLocal;
import org.techmart.entity.Inventory;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

@Singleton
@Startup
@ConcurrencyManagement(ConcurrencyManagementType.CONTAINER)
public class InventoryCacheBean implements InventoryCacheLocal {
    private static final Logger LOGGER = Logger.getLogger(InventoryCacheBean.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    private final Map<Long, Integer> cache = new ConcurrentHashMap<>();

    @PostConstruct
    public void init() {
        LOGGER.info("[LIFECYCLE] InventoryCacheBean @PostConstruct: Starting and loading inventory cache.");
        refreshCache();
    }

    @PreDestroy
    public void cleanup() {
        LOGGER.info("[LIFECYCLE] InventoryCacheBean @PreDestroy: Shutting down. Cache cleared.");
        cache.clear();
    }

    @Override
    @Lock(LockType.READ)
    public Integer getStock(Long productId) {
        LOGGER.info("Reading stock level from cache for Product ID: " + productId);
        return cache.getOrDefault(productId, 0);
    }

    @Override
    @Lock(LockType.WRITE)
    public void updateStock(Long productId, Integer quantity) {
        LOGGER.info("Updating stock level in cache for Product ID: " + productId + " to " + quantity);
        cache.put(productId, quantity);
    }

    @Override
    @Lock(LockType.WRITE)
    public void adjustStock(Long productId, Integer quantityChange) {
        LOGGER.info("Adjusting stock level in cache for Product ID: " + productId + " by " + quantityChange);
        Integer current = cache.getOrDefault(productId, 0);
        cache.put(productId, current + quantityChange);
    }

    @Override
    @Lock(LockType.READ)
    public Map<Long, Integer> getCachedInventory() {
        LOGGER.info("Retrieving copy of full inventory cache.");
        return new HashMap<>(cache);
    }

    @Override
    @Lock(LockType.WRITE)
    public void refreshCache() {
        LOGGER.info("Refreshing inventory cache from relational database.");
        try {
            List<Inventory> list = em.createQuery("SELECT i FROM Inventory i", Inventory.class).getResultList();
            cache.clear();
            for (Inventory inv : list) {
                cache.put(inv.getProductId(), inv.getQuantity());
            }
            LOGGER.info("Inventory cache refresh complete. Total cached products: " + cache.size());
        } catch (Exception e) {
            LOGGER.severe("Failed to refresh inventory cache: " + e.getMessage());
        }
    }
}
