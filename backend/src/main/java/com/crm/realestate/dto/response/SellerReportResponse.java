package com.crm.realestate.dto.response;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.ViewingOutcome;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * What the agency has done for one listing, in the figures its owner asks about: how long it has
 * been on the market, who came to see it and what they said, what the public link brought in, how
 * the price moved, and how many of the agency's buyers it still fits.
 *
 * <p>Counts only. No buyer is named, so the agent can read it out or forward it to the seller as
 * it is. Prices are in the agency's currency.
 */
@Data
@Builder
public class SellerReportResponse {

    private Long propertyId;
    private String title;
    private String address;
    private String city;
    private PropertyStatus status;

    private LocalDateTime listedAt;
    /** Whole days from listing to today, or to the won deal's close once it has sold. */
    private long daysOnMarket;
    /** The close of the won deal, when there is one; days on the market stop counting there. */
    private LocalDateTime soldAt;
    private LocalDate generatedOn;

    private Viewings viewings;
    private PublicLink publicLink;
    private Price price;

    /** Buyers whose stated requirements the listing answers today, as matching counts them. */
    private int matchingBuyers;

    @Data
    @Builder
    public static class Viewings {
        private int total;
        /** Done, or their time has passed. */
        private int held;
        private int upcoming;
        /** Every {@link ViewingOutcome}, zeros included, so a new one shows up without a change here. */
        private Map<ViewingOutcome, Integer> outcomes;
        /** Held, but nobody has said how it went. */
        private int awaitingOutcome;
        /** The latest viewing that has taken place, or null. */
        private LocalDateTime lastHeldAt;
        /** The soonest one still to come, or null. */
        private LocalDateTime nextAt;
    }

    @Data
    @Builder
    public static class PublicLink {
        /** Whether the listing has a working link right now. */
        private boolean active;
        /** Opens of the page through every link it has had, revoked ones included. */
        private long views;
        /** Buyers who left their details on the page. */
        private long leads;
    }

    @Data
    @Builder
    public static class Price {
        private BigDecimal current;
        /** What it was first listed at: the old price of the first change, or current if none. */
        private BigDecimal original;
        /** current - original; zero when it never moved. */
        private BigDecimal change;
        /** The change as a percentage of the original, one decimal; null without an original. */
        private Double changePercent;
        /** Every change, oldest first. */
        private List<PropertyPriceChangeResponse> changes;
    }
}
