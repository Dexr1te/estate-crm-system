package com.crm.realestate.service;

import com.crm.realestate.dto.response.AuditLogResponse;
import com.crm.realestate.entity.AuditLog;
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

    private AuditLogResponse toResponse(AuditLog log) {
        return AuditLogResponse.builder()
                .id(log.getId())
                .actorId(log.getActor().getId())
                .actorEmail(log.getActor().getEmail())
                .action(log.getAction())
                .entityType(log.getEntityType())
                .entityId(log.getEntityId())
                .metadata(log.getMetadata())
                .createdAt(log.getCreatedAt())
                .build();
    }
}
