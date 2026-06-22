package org.techmart.ejb.bean;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.ejb.AsyncResult;
import jakarta.ejb.Asynchronous;
import jakarta.ejb.Stateless;
import java.util.concurrent.Future;
import java.util.logging.Logger;

@Stateless
public class NotificationServiceBean {
    private static final Logger LOGGER = Logger.getLogger(NotificationServiceBean.class.getName());

    @PostConstruct
    public void init() {
        LOGGER.info("[LIFECYCLE] NotificationServiceBean @PostConstruct: Instance initialized.");
    }

    @PreDestroy
    public void cleanup() {
        LOGGER.info("[LIFECYCLE] NotificationServiceBean @PreDestroy: Instance destroyed.");
    }

    @Asynchronous
    public Future<Boolean> sendEmailNotification(String recipient, String subject, String body) {
        LOGGER.info("Starting async email dispatch to: " + recipient + " on thread: " + Thread.currentThread().getName());
        try {
            // Simulate SMTP network latency (1 second)
            Thread.sleep(1000);
            LOGGER.info("Async email dispatch completed successfully to: " + recipient);
            return new AsyncResult<>(true);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            LOGGER.warning("Async email dispatch interrupted for: " + recipient);
            return new AsyncResult<>(false);
        }
    }
}
