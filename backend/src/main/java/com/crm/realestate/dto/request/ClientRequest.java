package com.crm.realestate.dto.request;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.LeadSource;
import com.crm.realestate.enums.PropertyType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.Data;
import lombok.Setter;

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

    /**
     * How the client reached the agency. Like tags, a request without the field leaves the
     * client's source and its detail as they are, so an app that predates it cannot wipe them;
     * an explicit null clears both.
     */
    private LeadSource leadSource;

    /** Who referred them, which portal; kept only beside a source. */
    @Size(max = 255, message = "Lead source detail is at most 255 characters")
    private String leadSourceDetail;

    @Setter(AccessLevel.NONE)
    @JsonIgnore
    private boolean leadSourceSent;

    public void setLeadSource(LeadSource leadSource) {
        this.leadSource = leadSource;
        this.leadSourceSent = true;
    }
}