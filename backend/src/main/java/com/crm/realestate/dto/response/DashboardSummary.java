package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummary {
    private long totalDeals;
    private long activeDeals;
    private long closedDeals;
    private long totalClients;
    private long upcomingMeetings;
    /** Commission on deals won since the first of this month; zero, never null. */
    private BigDecimal commissionThisMonth;
    /** Open tasks due between now and midnight. */
    private long tasksDueToday;
    /** Open tasks whose due time has passed. */
    private long tasksOverdue;
}