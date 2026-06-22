package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.annotation.Resource;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.inject.Inject;
import jakarta.jms.JMSContext;
import jakarta.jms.MapMessage;
import jakarta.jms.Queue;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.techmart.ejb.local.OrderServiceLocal;
import org.techmart.ejb.remote.OrderServiceRemote;
import org.techmart.entity.Order;
import org.techmart.entity.OrderItem;
import org.techmart.entity.CartItem;
import org.techmart.entity.User;
import org.techmart.entity.Product;
import org.techmart.entity.AuditLog;
import org.techmart.exception.InventoryException;
import java.math.BigDecimal;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
public class OrderServiceBean implements OrderServiceLocal, OrderServiceRemote {
    private static final Logger LOGGER = Logger.getLogger(OrderServiceBean.class.getName());

    @PersistenceContext(unitName = "TechMartPU")
    private EntityManager em;

    @Inject
    private JMSContext jmsContext;

    @Resource(lookup = "jms/orderQueue")
    private Queue orderQueue;

    @PostConstruct
    public void init() {
        LOGGER.info("[LIFECYCLE] OrderServiceBean @PostConstruct: Instance initialized.");
    }

    @PreDestroy
    public void cleanup() {
        LOGGER.info("[LIFECYCLE] OrderServiceBean @PreDestroy: Instance about to be removed.");
    }

    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Order placeOrder(Long userId, List<CartItem> cartItems) throws InventoryException {
        LOGGER.info("Starting order placement for user ID: " + userId);

        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Cart items cannot be empty.");
        }

        User user = em.find(User.class, userId);
        if (user == null) {
            throw new IllegalArgumentException("User with ID " + userId + " not found.");
        }

        Order order = new Order();
        order.setUser(user);
        order.setStatus("PENDING");
        order.setTotalAmount(BigDecimal.ZERO);
        em.persist(order); // Persist order to get ID

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            Product product = em.find(Product.class, item.getProductId());
            if (product == null) {
                throw new IllegalArgumentException("Product with ID " + item.getProductId() + " not found.");
            }

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(product);
            orderItem.setQuantity(item.getQuantity());
            orderItem.setPriceAtPurchase(product.getPrice());
            em.persist(orderItem);

            order.getItems().add(orderItem);
            total = total.add(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
        }

        order.setTotalAmount(total);
        order = em.merge(order);
        em.flush(); // Force JPA to write SQL INSERTs to the database and assign primary keys

        // Write Audit Log
        AuditLog audit = new AuditLog();
        audit.setAction("ORDER_CREATED");
        audit.setTargetType("Order");
        audit.setTargetId(order.getId());
        audit.setChangedBy(user.getEmail());
        em.persist(audit);

        LOGGER.info("Order saved with ID: " + order.getId() + ". Dispatching message to JMS queue.");

        // Dispatch asynchronous order processing message
        try {
            MapMessage message = jmsContext.createMapMessage();
            message.setLong("orderId", order.getId());
            message.setLong("userId", userId);
            jmsContext.createProducer().send(orderQueue, message);
            LOGGER.info("JMS message successfully dispatched to orderQueue for Order ID: " + order.getId());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to send JMS message for Order ID: " + order.getId(), e);
            // We throw a runtime exception to roll back the order creation if the queue fails
            throw new RuntimeException("Messaging provider error. Order rollback triggered.", e);
        }

        return order;
    }

    @Override
    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    public Order createOrderPlaceholder(Long userId, List<CartItem> cartItems) throws InventoryException {
        LOGGER.info("Creating placeholder order for user ID: " + userId);

        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Cart items cannot be empty.");
        }

        User user = em.find(User.class, userId);
        if (user == null) {
            throw new IllegalArgumentException("User with ID " + userId + " not found.");
        }

        Order order = new Order();
        order.setUser(user);
        order.setStatus("PENDING_PAYMENT");
        order.setTotalAmount(BigDecimal.ZERO);
        em.persist(order);

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            Product product = em.find(Product.class, item.getProductId());
            if (product == null) {
                throw new IllegalArgumentException("Product with ID " + item.getProductId() + " not found.");
            }

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(product);
            orderItem.setQuantity(item.getQuantity());
            orderItem.setPriceAtPurchase(product.getPrice());
            em.persist(orderItem);

            order.getItems().add(orderItem);
            total = total.add(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
        }

        order.setTotalAmount(total);
        order = em.merge(order);
        em.flush();

        // Write Audit Log
        AuditLog audit = new AuditLog();
        audit.setAction("ORDER_CREATED_PENDING_PAYMENT");
        audit.setTargetType("Order");
        audit.setTargetId(order.getId());
        audit.setChangedBy(user.getEmail());
        em.persist(audit);

        LOGGER.info("Placeholder order created with ID: " + order.getId() + " in PENDING_PAYMENT status.");
        return order;
    }

    @Override
    public Order getOrderById(Long id) {
        LOGGER.info("Fetching order by ID: " + id);
        Order order = em.find(Order.class, id);
        if (order != null) {
            // Force eager initialization of items collection for safety outside TX boundary
            order.getItems().size();
        }
        return order;
    }

    @Override
    public List<Order> getOrdersByUser(Long userId) {
        LOGGER.info("Fetching orders for user: " + userId);
        return em.createQuery("SELECT o FROM Order o WHERE o.user.id = :userId ORDER BY o.orderedAt DESC", Order.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    @Override
    public List<Order> getAllOrders() {
        LOGGER.info("Fetching all orders in system");
        return em.createQuery("SELECT o FROM Order o ORDER BY o.orderedAt DESC", Order.class).getResultList();
    }
}
