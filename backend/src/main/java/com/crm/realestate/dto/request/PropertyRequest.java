package com.crm.realestate.dto.request;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.DecimalMax;
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

    /** Where it stands, in degrees (WGS 84). Both or neither; sending neither clears the pin. */
    @DecimalMin(value = "-90.0", message = "Latitude must be between -90 and 90")
    @DecimalMax(value = "90.0", message = "Latitude must be between -90 and 90")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "Longitude must be between -180 and 180")
    @DecimalMax(value = "180.0", message = "Longitude must be between -180 and 180")
    private Double longitude;

    /** A point needs both halves; one without the other would put the flat nowhere. */
    @JsonIgnore
    @AssertTrue(message = "Latitude and longitude go together: send both or neither")
    public boolean isLocationComplete() {
        return (latitude == null) == (longitude == null);
    }
}