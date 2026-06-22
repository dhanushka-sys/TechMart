package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.local.ProductServiceLocal;
import org.techmart.ejb.remote.ProductServiceRemote;
import org.techmart.entity.Product;
import java.util.List;
import java.util.logging.Logger;

@Stateless
public class ProductServiceBean implements ProductServiceLocal, ProductServiceRemote {
    private static final Logger LOGGER = Logger.getLogger(ProductServiceBean.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @PostConstruct
    public void init() {
        LOGGER.info("[LIFECYCLE] ProductServiceBean @PostConstruct: Instance created and injected.");
    }

    @PreDestroy
    public void cleanup() {
        LOGGER.info("[LIFECYCLE] ProductServiceBean @PreDestroy: Instance is being evicted from pool.");
    }

    @Override
    public Product getProductById(Long id) {
        LOGGER.info("Fetching product with ID: " + id);
        return em.find(Product.class, id);
    }

    @Override
    public Product getProductBySku(String sku) {
        LOGGER.info("Fetching product with SKU: " + sku);
        try {
            return em.createQuery("SELECT p FROM Product p WHERE p.sku = :sku", Product.class)
                    .setParameter("sku", sku)
                    .getSingleResult();
        } catch (Exception e) {
            LOGGER.warning("No product found with SKU: " + sku);
            return null;
        }
    }

    @Override
    public List<Product> getAllProducts() {
        LOGGER.info("Retrieving all products in catalog");
        return em.createQuery("SELECT p FROM Product p", Product.class).getResultList();
    }

    @Override
    public Product saveProduct(Product product) {
        LOGGER.info("Persisting/merging product with SKU: " + product.getSku());
        if (product.getId() == null) {
            em.persist(product);
            return product;
        } else {
            return em.merge(product);
        }
    }

    @Override
    public void deleteProduct(Long id) {
        LOGGER.info("Removing product with ID: " + id);
        Product product = getProductById(id);
        if (product != null) {
            em.remove(product);
        }
    }

    @Override
    public void restockProduct(Long productId, int quantity) {
        LOGGER.info("Restocking product ID: " + productId + " with quantity: " + quantity);
        try {
            org.techmart.entity.Inventory inv = em.createQuery("SELECT i FROM Inventory i WHERE i.productId = :pid", org.techmart.entity.Inventory.class)
                    .setParameter("pid", productId)
                    .getSingleResult();
            if (inv != null) {
                inv.setQuantity(inv.getQuantity() + quantity);
                em.merge(inv);
            }
        } catch (Exception e) {
            LOGGER.severe("Failed to find or update inventory record: " + e.getMessage());
        }
    }
}
