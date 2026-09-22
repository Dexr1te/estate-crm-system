package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ViewingOutcome;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingResponse {
    private Long id;
    private String title;
    private String description;
    private LocalDateTime scheduledAt;
    private String location;
    private boolean completed;
    private Long dealId;
    private String dealTitle;
    private ViewingOutcome outcome;
    private String outcomeNote;
    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;
    private Long agentId;
    private String agentName;
    private Long clientId;
    private String clientName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}