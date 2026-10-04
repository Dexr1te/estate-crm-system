package com.crm.realestate.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * A deal's whole split, everyone's share at once, totalling exactly 100. The deal's own agent is
 * one of the lines (by their userId) or, left out, holds nothing. Each line is a colleague
 * ({@code userId}) or an outside co-broker ({@code coBrokerName}, optionally their agency), never
 * both.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CommissionSplitRequest {

    public static final int MAX_SHARES = 10;

    @NotNull(message = "Say who shares the commission")
    @Size(min = 1, max = MAX_SHARES, message = "A commission is split between 1 and 10 people")
    @Valid
    private List<Share> shares;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Share {

        /** A colleague from the deal's agency, or the deal's agent. */
        private Long userId;

        @Size(max = 255, message = "A co-broker's name takes at most 255 characters")
        private String coBrokerName;

        @Size(max = 255, message = "A co-broker's agency takes at most 255 characters")
        private String coBrokerAgency;

        @NotNull(message = "Each share needs a percentage")
        @DecimalMin(value = "0", inclusive = false, message = "A share is more than zero")
        @DecimalMax(value = "100", message = "A share is at most 100%")
        @Digits(integer = 3, fraction = 2, message = "A share takes at most 2 decimals")
        private BigDecimal percent;
    }
}
