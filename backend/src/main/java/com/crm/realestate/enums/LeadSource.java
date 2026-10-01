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
    /** Came into the office. */
    WALK_IN,
    /** The agency called them first. */
    COLD_CALL,
    /** Has bought or sold with the agency before. */
    REPEAT,
    OTHER
}
