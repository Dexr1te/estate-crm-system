package com.crm.realestate.dto.response;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Is this price right? Answered from the agency's own book: its active listings and what it sold.
 * Figures per square metre are in the agency's currency, rounded to whole units.
 */
@Data
@Builder
public class PriceInsightResponse {

    /** Comparables actually used, active and sold together. */
    private int count;
    /** Fewer than five comparables even with any number of rooms. */
    private boolean lowConfidence;
    private Criteria criteria;
    private Stats active;
    private Stats sold;
    /** p25–p75 of every comparable's price per m², times the area asked about; null without one. */
    private Range suggested;
    /** Only on the insight for an existing listing. */
    private Position position;
    /** The newest comparables, at most 50. Ids and titles only — never agents or clients. */
    private List<ComparableListing> comparables;

    public enum RoomsRule { EXACT, NEAR, ANY }

    @Data
    @Builder
    public static class Criteria {
        private String city;
        private PropertyType type;
        private Integer rooms;
        private Double areaSqm;
        private Long excludeId;
        /** How far the rooms were widened: EXACT, NEAR (±1) or ANY. */
        private RoomsRule roomsRule;
        /** The rooms range used; both null under ANY. */
        private Integer minRooms;
        private Integer maxRooms;
    }

    @Data
    @Builder
    public static class Stats {
        private int count;
        private BigDecimal medianPerSqm;
        private BigDecimal p25PerSqm;
        private BigDecimal p75PerSqm;
        /** Sold only: listed to won deal, in days; null when no sale has a closing date. */
        private Integer medianDaysOnMarket;
    }

    @Data
    @Builder
    public static class Range {
        private BigDecimal low;
        private BigDecimal median;
        private BigDecimal high;
    }

    @Data
    @Builder
    public static class Position {
        private BigDecimal pricePerSqm;
        /** Share of active comparables priced below it per m², ties counting half, 0–100. */
        private Integer percentile;
        /** How far above (positive) or below (negative) the active median, in percent. */
        private Double vsMedianPercent;
    }

    @Data
    @Builder
    public static class ComparableListing {
        private Long id;
        private String title;
        private BigDecimal price;
        private Double areaSqm;
        private BigDecimal pricePerSqm;
        private Integer rooms;
        private PropertyStatus status;
        /** Listed as SOLD, or has a won deal. Its price is then the deal's when there is one. */
        private boolean sold;
    }
}
