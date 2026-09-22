package com.crm.realestate.enums;

/**
 * How a showing went, once it has.
 *
 * <p>Recorded against the meeting rather than the listing, because the verdict belongs to one
 * buyer: a flat two people walked away from is still the right flat for a third. Matching reads
 * {@link #REJECTED} and stops offering that listing to that buyer.
 */
public enum ViewingOutcome {
    /** Wants to go further — a second viewing, an offer, a deal. */
    INTERESTED,
    /** Saw it and said no. Not offered to this buyer again. */
    REJECTED,
    /** Nobody came. Says nothing about the flat, so matching ignores it. */
    NO_SHOW
}
