package org.techmart.ejb.local;

import jakarta.ejb.Local;
import org.techmart.entity.PaymentResult;
import java.util.concurrent.Future;

@Local
public interface PaymentServiceLocal {
    Future<PaymentResult> processPayment(Long orderId, Long userId, String cardNumber, String expiry, String cvv);
}
