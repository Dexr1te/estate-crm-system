package com.crm.realestate.dto.response;

import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PropertyResponse {
    private Long id;
    private String title;
    private String description;
    private String address;
    private String city;
    private PropertyType type;
    private PropertyStatus status;
    private BigDecimal price;
    private Double areaSqm;
    private Integer rooms;
    private Integer floor;
    private Integer totalFloors;
    private Long agentId;
    private String agentName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}