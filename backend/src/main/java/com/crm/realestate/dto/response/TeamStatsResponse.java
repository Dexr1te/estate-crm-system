package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamStatsResponse {
    private Long teamId;
    private String teamName;
    private Long managerId;
    private String managerName;
    private Long totalAgents;
    private Long totalClients;
    private Long totalDeals;
    private Long activeDeals;
    private Long upcomingMeetings;
}
