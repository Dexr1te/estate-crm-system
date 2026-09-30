package com.crm.realestate.controller;

import com.crm.realestate.dto.request.MessageTemplateRequest;
import com.crm.realestate.dto.response.MessageTemplateResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.MessageTemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * The agency's message templates. Everybody in the agency reads them; the manager writes them.
 * An admin, who runs no agency, names one with {@code teamId}.
 */
@RestController
@RequestMapping("/team/message-templates")
@RequiredArgsConstructor
@Tag(name = "Team", description = "Manager team operations")
@SecurityRequirement(name = "bearerAuth")
public class MessageTemplateController {

    private final MessageTemplateService templateService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @Operation(summary = "The agency's message templates, placeholders unfilled, oldest first")
    public ResponseEntity<List<MessageTemplateResponse>> list(@RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(templateService.list(securityUtils.getCurrentUser(), teamId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Add a template; placeholders: {client} {agent} {listing} {price} {address} {link}")
    public ResponseEntity<MessageTemplateResponse> create(@RequestParam(required = false) Long teamId,
                                                          @Valid @RequestBody MessageTemplateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(templateService.create(securityUtils.getCurrentUser(), teamId, request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Rewrite a template")
    public ResponseEntity<MessageTemplateResponse> update(@PathVariable Long id,
                                                          @RequestParam(required = false) Long teamId,
                                                          @Valid @RequestBody MessageTemplateRequest request) {
        return ResponseEntity.ok(templateService.update(securityUtils.getCurrentUser(), teamId, id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
    @Operation(summary = "Delete a template")
    public ResponseEntity<Void> delete(@PathVariable Long id, @RequestParam(required = false) Long teamId) {
        templateService.delete(securityUtils.getCurrentUser(), teamId, id);
        return ResponseEntity.noContent().build();
    }
}
