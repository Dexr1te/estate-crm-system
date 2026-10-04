package com.crm.realestate.dto.request;

import com.crm.realestate.enums.TimeOffKind;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

/**
 * An absence: whose (the caller's own when left out; a manager may name a colleague), why, the
 * first and the last day away, both inclusive, and who covers. Changing an absence never changes
 * whose it is, so {@link #userId} is read only when one is written down.
 */
@Data
public class TimeOffRequest {

    private Long userId;

    @NotNull(message = "Say what kind of time off it is")
    private TimeOffKind kind;

    @NotNull(message = "The first day is required")
    private LocalDate startDate;

    @NotNull(message = "The last day is required")
    private LocalDate endDate;

    /** The colleague covering, or nobody. */
    private Long coverId;

    @Size(max = 1000, message = "Note must be at most 1000 characters")
    private String note;
}
