package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

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

    /**
     * The tags the client should carry, as typed — normalised and limited by ClientTagService.
     * Null leaves an existing client's tags as they are, so an app that predates tags cannot wipe
     * them by saving; an empty list removes them all.
     */
    private List<String> tags;
}