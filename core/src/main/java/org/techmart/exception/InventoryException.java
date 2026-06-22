package org.techmart.exception;

import jakarta.ejb.ApplicationException;

/**
 * Custom application exception to indicate inventory errors,
 * such as stock unavailability. Annotated with @ApplicationException(rollback = true)
 * to ensure the EJB container automatically rolls back the active transaction
 * when this exception is thrown.
 */
@ApplicationException(rollback = true)
public class InventoryException extends Exception {
    private static final long serialVersionUID = 1L;

    public InventoryException(String message) {
        super(message);
    }
}
