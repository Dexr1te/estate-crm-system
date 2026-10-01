package com.crm.realestate.dto.response;

import com.crm.realestate.enums.DepositHolder;
import com.crm.realestate.enums.DepositOutcome;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * A deposit on a deal, with enough of the deal to list it on its own (the "deposits ending" list).
 * Active while {@code outcome} is null.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DealDepositResponse {
    private Long id;
    private Long dealId;
    private String dealTitle;
    private Long clientId;
    private String clientName;
    /** The deal's listing, the one the deposit holds; null when the deal names none. */
    private Long propertyId;
    private String propertyTitle;
    private Long agentId;
    private String agentName;

    /** In the agency's currency. */
    private BigDecimal amount;
    private LocalDate receivedOn;
    private LocalDate holdUntil;
    private DepositHolder holder;
    private String note;

    private boolean active;
    /** Null while active. */
    private DepositOutcome outcome;
    private LocalDate closedOn;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
