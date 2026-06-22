package org.techmart.ejb.local;

import jakarta.ejb.Local;
import org.techmart.entity.Product;
import java.util.List;

@Local
public interface ProductServiceLocal {
    Product getProductById(Long id);
    Product getProductBySku(String sku);
    List<Product> getAllProducts();
    Product saveProduct(Product product);
    void deleteProduct(Long id);
    void restockProduct(Long productId, int quantity);
}
