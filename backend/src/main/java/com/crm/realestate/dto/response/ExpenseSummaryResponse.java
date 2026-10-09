package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/** What was spent on listings over a period, in the agency's currency. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExpenseSummaryResponse {
    /** The first and the last day counted, both inclusive. */
    private LocalDate from;
    private LocalDate to;
    private BigDecimal total;
    /** Per category that has any, the largest first. */
    private List<ExpenseCategoryTotal> byCategory;
    /** The listings that cost the most, at most five, the most first. */
    private List<Listing> topListings;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Listing {
        private Long propertyId;
        private String title;
        private BigDecimal total;
    }
}
