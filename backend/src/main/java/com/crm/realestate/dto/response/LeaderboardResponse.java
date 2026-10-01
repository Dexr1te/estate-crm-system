package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * How each person in one agency did over [from, to), for its manager.
 *
 * <p>{@code agents} are the agency's active members, ranked; {@code inactive} are members who
 * have been deactivated but are still in the agency, ranked the same way, kept apart so they do
 * not hold a place on the board. Someone taken off the team is in neither list: their records
 * were handed to a colleague when they left, and count for that colleague.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardResponse {

    private LocalDate from;
    private LocalDate to;
    /** The agency's currency (ISO 4217), for formatting the commission. */
    private String currency;

    private List<Row> agents;
    private List<Row> inactive;
    /** Every row added up, active and inactive. Its win rate is over the whole agency. */
    private Row totals;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Row {
        /** Place on the board, from 1; null on the totals row. */
        private Integer rank;
        private Long agentId;
        private String fullName;
        private String role;

        /** Deals won with their closing date in the period. */
        private long dealsWon;
        /** Deals lost with their closing date in the period. */
        private long dealsLost;
        /** Sum of the won deals' prices; a deal without a price adds nothing. */
        private BigDecimal wonValue;
        /** Commission on the won deals: price × rate / 100, summed; deals missing either add nothing. */
        private BigDecimal commission;
        /** Viewings (meetings with a listing) in the period that have happened, not counting no-shows. */
        private long viewingsHeld;
        /** Clients created in the period that this person holds. */
        private long newClients;
        /** Won over won + lost in the period, 0 to 1; null when nothing closed. */
        private Double winRate;
    }
}
