package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** A client a partner sent, with their won deals and the fee the agency owes on them. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartnerReferralResponse {
    private Long clientId;
    private String fullName;
    private ClientType type;
    private Long agentId;
    private String agentName;
    private long wonDeals;
    /** The fee on those deals; zero without a won deal or a fee rule. */
    private BigDecimal feeOwed;
    /** Won deals left out of {@link #feeOwed} for want of a recorded commission. */
    private long wonDealsWithoutCommission;
    private LocalDateTime createdAt;
}
