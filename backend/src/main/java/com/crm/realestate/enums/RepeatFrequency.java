package com.crm.realestate.enums;

/**
 * How often a task comes back. {@link #NONE} is only ever sent and answered; a task that does not
 * repeat has no series at all.
 */
public enum RepeatFrequency {
    NONE,
    DAILY,
    WEEKLY,
    MONTHLY,
    QUARTERLY,
    YEARLY
}
