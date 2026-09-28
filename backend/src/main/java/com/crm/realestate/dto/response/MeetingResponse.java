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
    /** The listing's pin, so a day of viewings can be drawn as a route without a fetch per listing. */
    private Double propertyLatitude;
    private Double propertyLongitude;
    private Long agentId;
    private String agentName;
    private Long clientId;
    private String clientName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}