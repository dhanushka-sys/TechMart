package org.techmart.ejb.remote;

import jakarta.ejb.Remote;
import org.techmart.entity.Product;
import java.util.List;

// @Remote
public interface ProductServiceRemote {
    Product getProductById(Long id);
    Product getProductBySku(String sku);
    List<Product> getAllProducts();
    Product saveProduct(Product product);
    void deleteProduct(Long id);
    void restockProduct(Long productId, int quantity);
}
