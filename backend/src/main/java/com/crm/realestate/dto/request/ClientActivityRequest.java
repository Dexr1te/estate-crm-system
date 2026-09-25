package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ActivityType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

/** A touch to log against a client. When it happened defaults to now. */
@Data
public class ClientActivityRequest {

    @NotNull(message = "Type is required")
    private ActivityType type;

    @Size(max = 2000, message = "Note must be at most 2000 characters")
    private String note;

    private LocalDateTime occurredAt;
}
