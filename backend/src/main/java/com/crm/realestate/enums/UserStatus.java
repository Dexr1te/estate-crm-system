package com.crm.realestate.enums;

public enum UserStatus {
    /** Signed up, but has not yet entered the code mailed to them. Cannot sign in. */
    PENDING_VERIFICATION,
    PENDING_INVITE,
    ACTIVE,
    DEACTIVATED
}
