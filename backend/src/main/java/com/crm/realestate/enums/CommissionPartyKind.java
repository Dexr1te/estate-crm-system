package com.crm.realestate.enums;

/** Who a share of a deal's commission goes to (V55). */
public enum CommissionPartyKind {
    /** The deal's own agent, who holds what the others do not. */
    AGENT,
    /** A colleague from the deal's agency. */
    COLLEAGUE,
    /** An agent from outside the agency, known by name; their share leaves the agency. */
    CO_BROKER
}
