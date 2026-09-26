package com.crm.realestate.enums;

/** Where a client record came from. See {@code V35__client_source.sql}. */
public enum ClientSource {
    /** Typed in by an agent. */
    MANUAL,
    /** Brought in from a spreadsheet. */
    IMPORT,
    /** Left their details on a listing's public page. */
    PUBLIC_LINK
}
