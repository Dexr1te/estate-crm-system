package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ViewingOutcome;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/** The verdict after a showing, and what the buyer said about it. */
@Data
public class ViewingOutcomeRequest {

    @NotNull(message = "Outcome is required")
    private ViewingOutcome outcome;

    private String note;
}
