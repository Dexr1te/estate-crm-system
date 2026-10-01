package com.crm.realestate.enums;

/** Who keeps a buyer's deposit while the deal is under way. A fixed set: these are the three there are. */
public enum DepositHolder {
    /** The agency holds it on the buyer's behalf. */
    AGENCY,
    /** It was paid straight to the seller. */
    SELLER,
    /** A notary keeps it in deposit. */
    NOTARY
}
