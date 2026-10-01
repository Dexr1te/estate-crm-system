package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DepositHolder;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/** A deposit as recorded or corrected: everything about it but how it ended. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DealDepositRequest {

    /** In the agency's currency. */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "A deposit is more than zero")
    @Digits(integer = 13, fraction = 2, message = "Amount takes at most 13 digits and 2 decimals")
    private BigDecimal amount;

    @NotNull(message = "The day the deposit came in is required")
    private LocalDate receivedOn;

    /** The last day the listing is held for this buyer; not before {@link #receivedOn}. */
    @NotNull(message = "The day the hold ends is required")
    private LocalDate holdUntil;

    @NotNull(message = "Say who holds the deposit")
    private DepositHolder holder;

    @Size(max = 500, message = "A note takes at most 500 characters")
    private String note;
}
