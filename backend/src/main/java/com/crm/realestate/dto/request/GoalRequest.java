package com.crm.realestate.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * A month's target: commission in the agency's currency, deals won, or both. Neither is refused
 * with GOAL_TARGET_REQUIRED; taking a target off is a DELETE.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GoalRequest {

    @DecimalMin(value = "0", inclusive = false, message = "A commission target is above zero")
    @Digits(integer = 13, fraction = 2, message = "A commission target has at most two decimals")
    private BigDecimal commissionTarget;

    @Min(value = 1, message = "A deals target is at least one")
    @Max(value = 1000, message = "A deals target is at most a thousand")
    private Integer dealsTarget;
}
