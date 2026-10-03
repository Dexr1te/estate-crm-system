package com.crm.realestate.dto.request;

import com.crm.realestate.enums.OfferParty;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/** A new figure on the table: the seller's counter, or the buyer's answer to one. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OfferCounterRequest {

    /** In the agency's currency. */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "A counter-offer is more than zero")
    @Digits(integer = 13, fraction = 2, message = "Amount takes at most 13 digits and 2 decimals")
    private BigDecimal amount;

    @NotNull(message = "Say whose figure it is")
    private OfferParty party;

    @Size(max = 1000, message = "A note takes at most 1000 characters")
    private String note;

    /** A new last day for the offer; left out, the old one stands. Not in the past. */
    private LocalDate expiresOn;
}
