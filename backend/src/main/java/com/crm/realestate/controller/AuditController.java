package com.crm.realestate.controller;

import com.crm.realestate.dto.response.RecordChangeResponse;
import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.ChangeHistoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

/**
 * The agency's change log: every listing, deal and client created, edited or deleted, newest
 * first. A record's own history is {@code GET /properties|deals|clients/{id}/changes}.
 */
@RestController
@RequestMapping("/audit")
@RequiredArgsConstructor
@Tag(name = "Audit", description = "Who changed what on the agency's listings, deals and clients")
@SecurityRequirement(name = "bearerAuth")
public class AuditController {

    private final ChangeHistoryService changeHistoryService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "The agency's changes, newest first; filter by record type, who, kind of change "
            + "and days (from/to included). An admin may name the agency with teamId.")
    public ResponseEntity<Page<RecordChangeResponse>> feed(
            @RequestParam(required = false) ChangeEntityType entityType,
            @RequestParam(required = false) Long actorId,
            @RequestParam(required = false) ChangeAction action,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long teamId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "30") int size) {
        return ResponseEntity.ok(changeHistoryService.feed(securityUtils.getCurrentUser(), teamId,
                entityType, actorId, action, from, to, page, size));
    }
}
