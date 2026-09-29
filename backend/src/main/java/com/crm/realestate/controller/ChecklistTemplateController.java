package com.crm.realestate.controller;

import com.crm.realestate.dto.request.ChecklistTemplateRequest;
import com.crm.realestate.dto.response.ChecklistItemResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.ChecklistTemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * The agency's deal checklist template. Everybody in the agency reads it; the manager rewrites it.
 * An admin, who runs no agency, names one with {@code teamId}.
 */
@RestController
@RequestMapping("/team/checklist-template")
@RequiredArgsConstructor
@Tag(name = "Team", description = "Manager team operations")
@SecurityRequirement(name = "bearerAuth")
public class ChecklistTemplateController {

    private final ChecklistTemplateService templateService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @Operation(summary = "The agency's deal checklist template, by stage and position")
    public ResponseEntity<List<ChecklistItemResponse>> get(@RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(templateService.get(securityUtils.getCurrentUser(), teamId));
    }

    @PutMapping
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Replace the template (order within a stage is the order given); new deals only")
    public ResponseEntity<List<ChecklistItemResponse>> replace(@RequestParam(required = false) Long teamId,
                                                               @Valid @RequestBody ChecklistTemplateRequest request) {
        return ResponseEntity.ok(templateService.replace(securityUtils.getCurrentUser(), teamId, request));
    }
}
