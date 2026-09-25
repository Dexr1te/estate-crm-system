package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DealStatus;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class DealRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private DealStatus status = DealStatus.LEAD;

    private BigDecimal dealPrice;

    private BigDecimal budget;

    @DecimalMin(value = "0", inclusive = false, message = "Commission must be above 0%")
    @DecimalMax(value = "100", message = "Commission cannot exceed 100%")
    @Digits(integer = 3, fraction = 2, message = "Commission takes at most two decimal places")
    private BigDecimal commissionPercent;

    private String notes;

    @NotNull(message = "Client ID is required")
    private Long clientId;


    private Long propertyId;

    @NotNull(message = "Agent ID is required")
    private Long agentId;
}