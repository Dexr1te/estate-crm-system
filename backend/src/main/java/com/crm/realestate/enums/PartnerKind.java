package com.crm.realestate.enums;

/** What an outside partner of the agency does. See {@code V53__partners.sql}. */
public enum PartnerKind {
    MORTGAGE_BROKER,
    /** A lawyer or a notary. */
    LAWYER,
    APPRAISER,
    /** A developer selling new builds. */
    DEVELOPER,
    AGENCY,
    OTHER
}
