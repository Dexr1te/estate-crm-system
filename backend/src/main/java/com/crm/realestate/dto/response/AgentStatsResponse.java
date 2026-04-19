package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentStatsResponse {
    private Long agentId;
    private String fullName;
    private String email;
    private boolean isActive;

    // Work statistics
    private long totalClients;
    private long totalDeals;
    private long activeDeals;      // LEAD + NEGOTIATION
    private long closedDeals;      // CLOSED_WON + CLOSED_LOST
    private long upcomingMeetings; // upcoming meetings
}