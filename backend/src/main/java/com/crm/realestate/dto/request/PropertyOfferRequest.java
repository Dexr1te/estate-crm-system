package com.crm.realestate.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/** A buyer's offer as first recorded on a listing. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PropertyOfferRequest {

    @NotNull(message = "Say whose offer it is")
    private Long clientId;

    /** In the agency's currency. */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "An offer is more than zero")
    @Digits(integer = 13, fraction = 2, message = "Amount takes at most 13 digits and 2 decimals")
    private BigDecimal amount;

    @Size(max = 1000, message = "A note takes at most 1000 characters")
    private String note;

    /** The last day the offer stands; none when it was given no deadline. Not in the past. */
    private LocalDate expiresOn;
}
