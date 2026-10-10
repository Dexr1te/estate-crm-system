package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ExpenseCategory;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/** Money spent on a listing, as recorded. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PropertyExpenseRequest {

    @NotNull(message = "Say what it was spent on")
    private ExpenseCategory category;

    /** In the agency's currency. */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0", inclusive = false, message = "An expense is more than zero")
    @Digits(integer = 12, fraction = 2, message = "Amount takes at most 12 digits and 2 decimals")
    private BigDecimal amount;

    /** The day it was paid; not after today (EXPENSE_DATE_IN_FUTURE). */
    @NotNull(message = "Say when it was paid")
    private LocalDate spentOn;

    @Size(max = 500, message = "A note takes at most 500 characters")
    private String note;
}
