package org.techmart.entity;

import java.io.Serializable;

public class PaymentResult implements Serializable {
    private static final long serialVersionUID = 1L;

    private boolean success;
    private String message;
    private long durationMs;
    private String transactionId;

    public PaymentResult() {}

    public PaymentResult(boolean success, String message, long durationMs, String transactionId) {
        this.success = success;
        this.message = message;
        this.durationMs = durationMs;
        this.transactionId = transactionId;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public long getDurationMs() {
        return durationMs;
    }

    public void setDurationMs(long durationMs) {
        this.durationMs = durationMs;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }
}
