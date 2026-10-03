package com.crm.realestate.controller;

import com.crm.realestate.dto.request.HandoverRequest;
import com.crm.realestate.dto.response.HandoverResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.WorkHandoverService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * A manager hands an agent's work to a colleague, both staying in the agency. An admin names the
 * agency with {@code teamId}.
 */
@RestController
@RequestMapping("/handovers")
@RequiredArgsConstructor
@Tag(name = "Handovers", description = "Hand an agent's clients, listings, deals and meetings to a colleague")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('ADMIN','MANAGER')")
public class HandoverController {

    private final WorkHandoverService handoverService;
    private final SecurityUtils securityUtils;

    @PostMapping("/preview")
    @Operation(summary = "How many clients, listings, deals, meetings and tasks the handover would move")
    public ResponseEntity<HandoverResponse> preview(@RequestParam(required = false) Long teamId,
                                                    @Valid @RequestBody HandoverRequest request) {
        return ResponseEntity.ok(handoverService.preview(securityUtils.getCurrentUser(), teamId, request));
    }

    @PostMapping
    @Operation(summary = "Hand the work over; each client moved gets a line in its history")
    public ResponseEntity<HandoverResponse> handOver(@RequestParam(required = false) Long teamId,
                                                     @Valid @RequestBody HandoverRequest request) {
        return ResponseEntity.ok(handoverService.handOver(securityUtils.getCurrentUser(), teamId, request));
    }
}
