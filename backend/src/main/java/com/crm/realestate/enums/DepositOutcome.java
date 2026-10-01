package com.crm.realestate.enums;

/** How a deposit ended. A deposit with no outcome is still active. */
public enum DepositOutcome {
    /** Counted towards the price: the purchase went through. */
    APPLIED,
    /** Given back to the buyer. */
    REFUNDED,
    /** Kept: the buyer walked away on terms that cost them the deposit. */
    FORFEITED
}
