package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Marking a share of a deal's commission paid out, with a note if the manager wants one. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CommissionPayoutRequest {

    public static final int NOTE_MAX = 500;

    @Size(max = NOTE_MAX, message = "A payout note takes at most 500 characters")
    private String note;
}
