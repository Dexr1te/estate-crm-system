package com.crm.realestate.enums;

/**
 * How an agent was in touch with a client.
 *
 * <p>{@link #NOTE} is the odd one out: nobody was contacted, the agent wrote something down, so a
 * note without text says nothing and is refused.
 */
public enum ActivityType {
    CALL,
    MESSAGE,
    EMAIL,
    NOTE
}
