package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/** The manager's view of a month: the agency's own line and one per member, by name. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamGoalsResponse {
    private String month;
    private String currency;
    private int daysLeft;
    private GoalProgressResponse agency;
    private List<GoalProgressResponse> agents;
    /** How many targets a copy from the month before brought over; null on every other answer. */
    private Integer copied;
}
