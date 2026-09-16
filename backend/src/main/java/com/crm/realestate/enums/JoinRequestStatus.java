package com.crm.realestate.enums;

public enum JoinRequestStatus {
    /** Sent by a manager, waiting for the agent to answer. */
    PENDING,
    ACCEPTED,
    DECLINED,
    /** Withdrawn by the manager, or made moot because the agent joined another team. */
    CANCELLED
}
