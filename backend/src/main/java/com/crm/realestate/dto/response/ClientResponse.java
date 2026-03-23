package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import lombok.Data;

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
}