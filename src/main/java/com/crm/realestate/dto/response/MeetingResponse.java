package com.crm.realestate.dto.response;

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
    private Long agentId;
    private String agentName;
    private Long clientId;
    private String clientName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}