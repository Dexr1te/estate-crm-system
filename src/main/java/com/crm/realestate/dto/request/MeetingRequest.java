package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MeetingRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotNull(message = "Scheduled time is required")
    @Future(message = "Meeting must be scheduled in the future")
    private LocalDateTime scheduledAt;

    private String location;

    private Long dealId;      // опционально

    @NotNull(message = "Agent ID is required")
    private Long agentId;

    @NotNull(message = "Client ID is required")
    private Long clientId;
}