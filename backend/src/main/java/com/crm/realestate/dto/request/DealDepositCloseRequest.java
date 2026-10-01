package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DepositOutcome;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/** How a deposit ended, and on which day. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DealDepositCloseRequest {

    @NotNull(message = "Say how the deposit ended")
    private DepositOutcome outcome;

    @NotNull(message = "The day it ended is required")
    private LocalDate closedOn;
}
