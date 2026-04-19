package com.crm.realestate.dto.response;

import com.crm.realestate.enums.DealStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class DealResponse {
    private Long id;
    private String title;
    private DealStatus status;
    private BigDecimal dealPrice;
    private BigDecimal budget;
    private String notes;

    private Long clientId;
    private String clientName;

    private Long propertyId;
    private String propertyTitle;
    private String propertyAddress;

    private Long agentId;
    private String agentName;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime closedAt;
}