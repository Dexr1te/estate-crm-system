package com.crm.realestate.dto.request;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Accepting, rejecting or withdrawing an offer, with an optional word on why. The body may be left out. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OfferDecisionRequest {

    @Size(max = 1000, message = "A note takes at most 1000 characters")
    private String note;
}
