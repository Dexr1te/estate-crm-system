package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * Where the clients created in [from, to) came from, and how many of each reached a won deal.
 *
 * <p>A client counts as won if any deal of theirs is closed won, whenever it closed: a buyer met
 * in March who bought in May is March's channel converting. The rate is null when a source
 * brought nobody, which never appears, since sources with no clients are left out.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeadSourceBreakdown {

    /** What a client with no recorded source is reported under. */
    public static final String UNKNOWN = "UNKNOWN";

    private LocalDate from;
    private LocalDate to;

    /** Clients created in the period. */
    private long clients;
    /** Of those, the ones with a won deal. */
    private long won;

    /** One row per source that brought anyone, most clients first; unknown last. */
    private List<Row> sources;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Row {
        /** A {@code LeadSource} name, or {@link #UNKNOWN}. */
        private String source;
        private long clients;
        private long won;
        /** won / clients, 0 to 1. */
        private double conversionRate;
    }
}
