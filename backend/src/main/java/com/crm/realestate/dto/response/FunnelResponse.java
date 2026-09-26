package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * How the deals created in [from, to) moved through the pipeline, and why the lost ones were lost.
 *
 * <p>Rates are fractions between 0 and 1, and null when there is nothing to divide by — no deals
 * created, or none reaching negotiation — so the app can show a dash rather than a false 0%.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FunnelResponse {

    private LocalDate from;
    private LocalDate to;

    /** Every deal created in the period: they all start as leads. */
    private long created;
    /** Deals that got at least as far as negotiation — now there, won, or lost after it. */
    private long reachedNegotiation;
    private long won;
    private long lost;

    private Double leadToNegotiationRate;
    private Double negotiationToWonRate;
    private Double leadToWonRate;

    /** Sum of the prices of the won deals; deals without a price add nothing. */
    private BigDecimal wonValue;
    /** Mean days from creation to winning, over won deals; null when none were won. */
    private Double avgDaysToWin;

    private List<LostReasonShare> lostReasons;
    /** The last six calendar months, oldest first, whatever the period. */
    private List<MonthPoint> monthly;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LostReasonShare {
        /** A {@code DealLostReason} name, or {@code UNSPECIFIED} for deals lost before reasons were asked. */
        private String reason;
        private long count;
        /** Fraction of the lost deals, 0 to 1. */
        private double share;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MonthPoint {
        /** First day of the month. */
        private LocalDate month;
        /** Deals created that month. */
        private long created;
        /** Deals won or lost that month, by the date they closed. */
        private long won;
        private long lost;
    }
}
