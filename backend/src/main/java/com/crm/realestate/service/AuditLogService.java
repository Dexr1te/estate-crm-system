package com.crm.realestate.service;

import com.crm.realestate.dto.response.AuditLogResponse;
import com.crm.realestate.entity.AuditLog;
import org.springframework.transaction.annotation.Transactional;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.AuditLogRepository;
import com.crm.realestate.specification.AuditLogSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    public List<AuditLogResponse> getAuditLogs(Long actorId, String entityType, LocalDate fromDate, LocalDate toDate) {
        LocalDateTime from = fromDate != null ? fromDate.atStartOfDay() : null;
        LocalDateTime to = toDate != null ? toDate.atTime(LocalTime.MAX) : null;
        return auditLogRepository.findAll(AuditLogSpecification.build(actorId, entityType, from, to))
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Writes one journal entry. Deliberately not @Async: an audit line that may or may not have
     * been written is worth less than no audit line at all.
     */
    @Transactional
    public void record(User actor, String action, String entityType, Long entityId,
                       String metadata) {
        auditLogRepository.save(AuditLog.builder()
                .actor(actor)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .metadata(metadata)
                .build());
    }

    private AuditLogResponse toResponse(AuditLog log) {
        return AuditLogResponse.builder()
                .id(log.getId())
                .actorId(log.getActor() == null ? null : log.getActor().getId())
                .actorEmail(log.getActor() == null ? "deleted user" : log.getActor().getEmail())
                .action(log.getAction())
                .entityType(log.getEntityType())
                .entityId(log.getEntityId())
                .metadata(log.getMetadata())
                .createdAt(log.getCreatedAt())
                .build();
    }
}
