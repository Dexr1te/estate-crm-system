package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuditLogResponse {
    private Long id;
    private Long actorId;
    private String actorEmail;
    private String action;
    private String entityType;
    private Long entityId;
    private String metadata;
    private LocalDateTime createdAt;
}
