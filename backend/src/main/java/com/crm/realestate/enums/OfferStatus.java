package com.crm.realestate.enums;

/**
 * Where a buyer's offer on a listing stands. NEW and COUNTERED are open; the rest are decided.
 * EXPIRED is never stored: an open offer whose last day has gone reads as it (V47).
 */
public enum OfferStatus {
    NEW,
    COUNTERED,
    ACCEPTED,
    REJECTED,
    WITHDRAWN,
    EXPIRED;

    public boolean isOpen() {
        return this == NEW || this == COUNTERED;
    }
}
