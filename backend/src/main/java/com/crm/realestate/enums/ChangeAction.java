package com.crm.realestate.enums;

/**
 * What one row of the change log says happened. The four kinds of edit are the same row shape
 * (a field, its old and its new value); the action only says which kind it is, so the team's feed
 * can be narrowed to, say, price moves.
 */
public enum ChangeAction {
    CREATED,
    DELETED,
    STATUS_CHANGED,
    PRICE_CHANGED,
    AGENT_CHANGED,
    /** Any other field. */
    UPDATED
}
