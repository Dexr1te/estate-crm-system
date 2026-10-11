package com.crm.realestate.enums;

public enum UserStatus {
    /** Signed up, but has not yet opened the link Firebase emailed them. Cannot sign in. */
    PENDING_VERIFICATION,
    PENDING_INVITE,
    ACTIVE,
    DEACTIVATED
}
