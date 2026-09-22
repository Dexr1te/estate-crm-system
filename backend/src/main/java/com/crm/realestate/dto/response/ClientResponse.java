package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ClientResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private ClientType type;
    private String notes;
    private Long agentId;
    private String agentName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private PropertyType wantedType;
    private String wantedCity;
    private BigDecimal budgetMin;
    private BigDecimal budgetMax;
    private Integer minRooms;
    private Double minAreaSqm;
}