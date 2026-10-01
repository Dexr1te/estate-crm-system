package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * One person's month, or the agency's: the target that counts, what the deals won that month
 * have brought, and what is still needed for each day left.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GoalProgressResponse {
    /** "2026-10". */
    private String month;
    /** The agency's currency code; amounts carry none of their own. */
    private String currency;

    /** Null on the agency-wide line. */
    private Long agentId;
    private String agentName;

    /** MANAGER or PERSONAL: who set the target that counts; null when there is none. */
    private String source;
    private BigDecimal commissionTarget;
    private Integer dealsTarget;

    /** The agent's own target while the manager's overrides it; null otherwise. */
    private BigDecimal personalCommissionTarget;
    private Integer personalDealsTarget;

    /** Commission on deals won this month: price × rate, deals without either count nothing. */
    private BigDecimal commissionAchieved;
    private long dealsWon;

    /** Achieved over target, rounded down, not capped at 100; null without that target. */
    private Integer commissionPercent;
    private Integer dealsPercent;

    /** Days of the month still to come, today included; 0 for a month gone. */
    private int daysLeft;
    /** What is still needed divided by the days left, rounded up; null once reached or out of days. */
    private BigDecimal commissionPerDay;
    private BigDecimal dealsPerDay;

    /** Whether the agent may set or take off their own target: not while the manager's counts. */
    private boolean personalEditable;
}
