package com.crm.realestate.enums;

/**
 * Why a deal ended in CLOSED_LOST.
 *
 * <p>Required from the moment a deal is lost. Deals lost before the reason was recorded have none,
 * and the funnel reports those as unspecified rather than guessing.
 */
public enum DealLostReason {
    PRICE,
    CHOSE_ANOTHER,
    FINANCING,
    CHANGED_MIND,
    NO_RESPONSE,
    OTHER
}
