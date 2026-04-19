package com.crm.realestate.dto.request;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PropertyRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotBlank(message = "Address is required")
    private String address;

    private String city;

    @NotNull(message = "Property type is required")
    private PropertyType type;

    private PropertyStatus status = PropertyStatus.AVAILABLE;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be positive")
    private BigDecimal price;

    private Double areaSqm;
    private Integer rooms;
    private Integer floor;
    private Integer totalFloors;

    private Long agentId;
}