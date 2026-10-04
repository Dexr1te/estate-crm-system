package com.crm.realestate.dto.response;

import com.crm.realestate.enums.TimeOffKind;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgentOptionResponse {
    private Long id;
    private String fullName;

    /**
     * The last day of the time off this person is on today, or null when they are in. Only on the
     * agency's own list of agents, so a picker can say who is away.
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private LocalDate awayUntil;

    /**
     * Their time off that has not ended yet, soonest first, so a form can warn about a day they
     * are away. Only on the agency's own list of agents.
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<Away> timeOff;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Away {
        private TimeOffKind kind;
        private LocalDate startDate;
        private LocalDate endDate;
    }
}
