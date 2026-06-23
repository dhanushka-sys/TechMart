CREATE DATABASE IF NOT EXISTS techmart_db;
USE techmart_db;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_product_sku (sku)
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id BIGINT PRIMARY KEY,
    quantity INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id),
    KEY idx_order_user (user_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(id),
    KEY idx_item_order (order_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id BIGINT NOT NULL,
    changed_by VARCHAR(150) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (id, name, email, password, role) VALUES 
(1, 'Jane Doe', 'jane@techmart.com', 'password123', 'CUSTOMER'),
(2, 'Admin System', 'admin@techmart.com', 'admin123', 'ADMIN'),
(3, 'Kamal Fernando', 'kamal@techmart.com', 'kamal123', 'CUSTOMER')
ON DUPLICATE KEY UPDATE name=name;

INSERT INTO products (id, sku, title, description, price) VALUES 
(1, 'SKU-001', 'Intel Core i9-13900K Processor', 'Intel 13th Gen LGA1700 processor', 185000.00),
(2, 'SKU-002', 'NVIDIA GeForce RTX 4090 GPU', 'NVIDIA flagship ADA Lovelace graphics card', 650000.00),
(3, 'SKU-003', 'ASUS ROG Maximus Z790 Hero', 'High-end gaming motherboard for LGA1700', 145000.00),
(4, 'SKU-004', 'G.Skill Trident Z5 RGB 32GB DDR5', '32GB DDR5 6000MHz CL30 RAM kit', 45000.00),
(5, 'SKU-005', 'Samsung 990 Pro 2TB NVMe SSD', 'PCIe Gen4 M.2 SSD with heatsink', 65000.00)
ON DUPLICATE KEY UPDATE title=title;

INSERT INTO inventory (product_id, quantity) VALUES 
(1, 45),
(2, 12),
(3, 20),
(4, 55),
(5, 75)
ON DUPLICATE KEY UPDATE quantity=quantity;
