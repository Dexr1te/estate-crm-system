package com.crm.realestate.dto.request;

import com.crm.realestate.enums.DealStatus;
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

    private String notes;

    @NotNull(message = "Client ID is required")
    private Long clientId;

    @NotNull(message = "Property ID is required")
    private Long propertyId;

    @NotNull(message = "Agent ID is required")
    private Long agentId;
}