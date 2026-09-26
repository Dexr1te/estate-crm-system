package com.crm.realestate.enums;

/**
 * What a notification says happened. The app turns it into a sentence in the reader's language,
 * with the values from the notification's payload.
 *
 * <p>What {@code targetId} points at depends on the type: a task, a deal, a listing, a join
 * request, or nothing.
 */
public enum NotificationType {
    /** Somebody gave you a task. Target: the task. */
    TASK_ASSIGNED,
    /** A colleague's records were handed to you. No target; the payload carries the counts. */
    RECORDS_HANDED_OVER,
    /** An agency asks you to join it. Target: the join request. */
    JOIN_REQUEST,
    /** The agent you asked has joined your agency. Target: that agent. */
    JOIN_ACCEPTED,
    /** A listing came up that fits one of your buyers. Target: the listing. */
    NEW_MATCH,
    /** A listing that fits one of your buyers got cheaper. Target: the listing. */
    PRICE_DROP_MATCH,
    /** Somebody else moved one of your deals. Target: the deal. */
    DEAL_STATUS_CHANGED
}
