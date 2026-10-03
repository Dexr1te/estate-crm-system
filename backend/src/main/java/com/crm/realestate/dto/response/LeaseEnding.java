package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/** A won rent whose lease runs out soon, and the two people to call about it. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaseEnding {
    private Long dealId;
    private String dealTitle;
    private BigDecimal monthlyRent;
    private LocalDate leaseStart;
    /** The last day of the lease. */
    private LocalDate leaseEnd;
    /** Days from the caller's today to the last day; 0 on the day itself. */
    private int daysLeft;
    /** How many days before the end the agent asked to be reminded, the default filled in. */
    private int reminderDays;

    /** The deal's client: the one who lives there. */
    private Long tenantId;
    private String tenantName;
    private String tenantPhone;

    /** Who lets the place, when the deal names them; all null otherwise. */
    private Long landlordId;
    private String landlordName;
    private String landlordPhone;

    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;

    private Long agentId;
    private String agentName;
}
