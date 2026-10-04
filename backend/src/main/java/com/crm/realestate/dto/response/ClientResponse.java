package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
public class ClientResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private ClientType type;
    private com.crm.realestate.enums.ClientSource source;
    /** How the client reached the agency; null when not recorded. */
    private com.crm.realestate.enums.LeadSource leadSource;
    private String leadSourceDetail;
    /** The partner who sent them, when the lead source is PARTNER. */
    private Long referredByPartnerId;
    private String referredByPartnerName;
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

    /** The agency's tags on this client, in name order; empty when none. */
    private List<String> tags = new ArrayList<>();

    /** {@code 1990-05-14}, {@code --05-14} when the year is not known, or null. */
    private String birthday;
}