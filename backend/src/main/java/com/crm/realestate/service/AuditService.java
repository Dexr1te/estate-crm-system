package com.crm.realestate.service;

import com.crm.realestate.entity.AuditLog;
import com.crm.realestate.entity.User;
import com.crm.realestate.repository.AuditLogRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public void log(User actor, String action, String entityType, Long entityId, Object metadata) {
        String metadataJson = null;
        if (metadata != null) {
            try {
                metadataJson = objectMapper.writeValueAsString(metadata);
            } catch (JsonProcessingException e) {
                metadataJson = String.valueOf(metadata);
            }
        }
        AuditLog log = AuditLog.builder()
                .actor(actor)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .metadata(metadataJson)
                .build();
        auditLogRepository.save(log);
    }
}
