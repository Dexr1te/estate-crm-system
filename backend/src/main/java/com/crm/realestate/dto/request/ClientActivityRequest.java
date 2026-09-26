package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ActivityType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/** A touch to log against a client. When it happened defaults to now. */
@Data
public class ClientActivityRequest {

    @NotNull(message = "Type is required")
    private ActivityType type;

    @Size(max = 2000, message = "Note must be at most 2000 characters")
    private String note;

    private LocalDateTime occurredAt;

    /**
     * The listings this was about, if any — the ones sent in a message. Each must be one the caller
     * can see, in the client's agency. On an edit, null leaves the links as they are.
     */
    @Size(max = 50, message = "At most 50 listings per entry")
    private List<Long> propertyIds;
}
