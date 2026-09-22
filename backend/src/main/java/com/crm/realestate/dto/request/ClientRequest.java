package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ClientRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    @Email(message = "Invalid email format")
    private String email;

    private String phone;

    @NotNull(message = "Client type is required")
    private ClientType type;   // BUYER or SELLER

    private String notes;

    private Long agentId;      // если ADMIN назначает агента вручную

    private PropertyType wantedType;

    private String wantedCity;

    @PositiveOrZero(message = "Budget cannot be negative")
    private BigDecimal budgetMin;

    @PositiveOrZero(message = "Budget cannot be negative")
    private BigDecimal budgetMax;

    @PositiveOrZero(message = "Rooms cannot be negative")
    private Integer minRooms;

    @PositiveOrZero(message = "Area cannot be negative")
    private Double minAreaSqm;
}