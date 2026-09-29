package com.crm.realestate.enums;

/**
 * The stages a deal checklist is organised by. A lost deal has nothing left to collect, so it is
 * not one of them; for counting, a lost deal is treated as having got as far as negotiation.
 */
public enum ChecklistStage {
    LEAD,
    NEGOTIATION,
    CLOSED_WON;

    /** The furthest checklist stage a deal in {@code status} has reached. */
    public static ChecklistStage reachedBy(DealStatus status) {
        if (status == null) {
            return LEAD;
        }
        return switch (status) {
            case LEAD -> LEAD;
            case NEGOTIATION, CLOSED_LOST -> NEGOTIATION;
            case CLOSED_WON -> CLOSED_WON;
        };
    }
}
