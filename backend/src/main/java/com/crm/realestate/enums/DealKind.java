package com.crm.realestate.enums;

/**
 * What a deal is about: buying a place or renting it. Every deal from before V50 is a sale.
 *
 * <p>A sale has a price. A rent has a monthly rent and a lease with a first and a last day, and
 * its commission is a percentage of one month's rent.
 */
public enum DealKind {
    SALE,
    RENT
}
