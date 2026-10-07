package com.crm.realestate.enums;

/** A reason to get back in touch that comes round every year. See {@code V45__client_dates.sql}. */
public enum ClientDateKind {
    BIRTHDAY,
    /** The day, years ago, the client's deal was won: the flat they bought or sold with us. */
    PURCHASE_ANNIVERSARY
}
