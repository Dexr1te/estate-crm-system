package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

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

    /**
     * When this buyer was last shown it, if they have been.
     *
     * <p>Shown rather than hidden: people come back with a spouse and decide differently, and an
     * agent who cannot see that a flat was already viewed will offer it as though it were new. A
     * listing they turned down is a different matter — that one does not appear at all.
     */
    private LocalDateTime lastShownAt;

    /**
     * When this listing last went out to this buyer in a logged message, if it has. Like
     * {@link #lastShownAt} it marks the row rather than hiding it: a flat sent a month ago is often
     * worth sending again, but the agent should know they are repeating themselves.
     */
    private LocalDateTime lastSentAt;
}
