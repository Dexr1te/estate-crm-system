package com.crm.realestate.dto.response;

import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.enums.ReferralFeeType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * A partner with what its referrals came to, counted over the clients the caller sees: everyone's
 * for a manager or an agent with the team's scope, their own for an agent on their own records.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartnerResponse {
    private Long id;
    private String name;
    private String company;
    private PartnerKind kind;
    private String phone;
    private String email;
    private String note;
    /** Null when no fee was agreed. */
    private ReferralFeeType feeType;
    private BigDecimal feeValue;
    /** Who added it; null once that account is closed. */
    private Long createdById;
    private String createdByName;
    /** Whether the caller may change or delete it: whoever added it, a manager or an admin. */
    private boolean canEdit;
    private LocalDateTime createdAt;

    /** Clients the partner sent. */
    private long referredClients;
    /** Won deals of those clients, rents and sales alike. */
    private long wonDeals;
    /** The referral fees on those deals under the partner's fee rule; zero without one. */
    private BigDecimal feesOwed;
    /**
     * Won deals whose fee cannot be worked out because the deal records no commission, and so are
     * left out of {@link #feesOwed}. Always zero for a fixed fee or none.
     */
    private long wonDealsWithoutCommission;
    /** Clients the agency sent to the partner, and how many of those are not done yet. */
    private long handoffs;
    private long openHandoffs;
}
