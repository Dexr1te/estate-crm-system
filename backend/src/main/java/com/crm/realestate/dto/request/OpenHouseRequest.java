package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

/** When an open house runs, in the agency's wall-clock time, and anything to remember about it. */
@Data
public class OpenHouseRequest {

    @NotNull(message = "Start time is required")
    private LocalDateTime startsAt;

    @NotNull(message = "End time is required")
    private LocalDateTime endsAt;

    @Size(max = 1000, message = "Note must be at most 1000 characters")
    private String note;
}
