package com.crm.realestate.enums;

/**
 * How a client reached the agency: the channel, not how the card was entered (that is
 * {@link ClientSource}). Optional on a client. See {@code V41__client_lead_source.sql}.
 */
public enum LeadSource {
    /** Sent by someone: a past client, a friend, a colleague. */
    REFERRAL,
    /** The agency's own website, a listing's public page included. */
    WEBSITE,
    /** A listings portal such as krisha.kz. */
    PORTAL,
    /** Instagram, Telegram, WhatsApp channels and the like. */
    SOCIAL,
    WALK_IN,
    COLD_CALL,
    /** Has bought or sold with the agency before. */
    REPEAT,
    /**
     * Sent by one of the agency's partners: always beside the partner on the client, never alone
     * (V53). A referral by a person who is not a partner stays {@link #REFERRAL}.
     */
    PARTNER,
    OTHER
}
