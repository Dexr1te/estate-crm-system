package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * A listing that fits what a buyer asked for.
 *
 * <p>{@code overBudget} carries the one requirement a match is allowed to miss:
 * a listing just above the stated ceiling. An agent shows those anyway — a flat
 * 2% over budget is a conversation, not a rejection — so they come back in the
 * same list, marked, rather than being hidden and retyped as a wider search.
 */
@Data
@AllArgsConstructor
public class PropertyMatch {
    private PropertyResponse property;
    private boolean overBudget;
}
