package com.crm.realestate.controller;

import com.crm.realestate.dto.request.PartnerHandoffRequest;
import com.crm.realestate.dto.request.PartnerRequest;
import com.crm.realestate.dto.response.PartnerHandoffResponse;
import com.crm.realestate.dto.response.PartnerReferralResponse;
import com.crm.realestate.dto.response.PartnerResponse;
import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.service.PartnerHandoffService;
import com.crm.realestate.service.PartnerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * The agency's partners, what their referrals came to, and the clients sent to them. See
 * {@link PartnerService} and {@link PartnerHandoffService} for who may do what.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Partners", description = "Outside partners, the clients they refer and the clients sent to them")
@SecurityRequirement(name = "bearerAuth")
public class PartnerController {

    private final PartnerService partnerService;
    private final PartnerHandoffService handoffService;

    @GetMapping("/partners")
    @Operation(summary = "The agency's partners by name, with referred clients, won deals and fees owed")
    public ResponseEntity<List<PartnerResponse>> list(@RequestParam(required = false) PartnerKind kind,
                                                      @RequestParam(required = false) String search) {
        return ResponseEntity.ok(partnerService.list(kind, search));
    }

    @PostMapping("/partners")
    @Operation(summary = "Add a partner to the agency")
    public ResponseEntity<PartnerResponse> create(@Valid @RequestBody PartnerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(partnerService.create(request));
    }

    @GetMapping("/partners/{id}")
    @Operation(summary = "One partner with its numbers")
    public ResponseEntity<PartnerResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(partnerService.get(id));
    }

    @PutMapping("/partners/{id}")
    @Operation(summary = "Change a partner; whoever added it, a manager or an admin")
    public ResponseEntity<PartnerResponse> update(@PathVariable Long id, @Valid @RequestBody PartnerRequest request) {
        return ResponseEntity.ok(partnerService.update(id, request));
    }

    @DeleteMapping("/partners/{id}")
    @Operation(summary = "Delete a partner no client is linked to (409 PARTNER_IN_USE otherwise)")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        partnerService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/partners/{id}/referrals")
    @Operation(summary = "The clients the partner sent, newest first, with won deals and the fee on them")
    public ResponseEntity<List<PartnerReferralResponse>> referrals(@PathVariable Long id) {
        return ResponseEntity.ok(partnerService.referrals(id));
    }

    @GetMapping("/partners/{id}/handoffs")
    @Operation(summary = "The clients sent to the partner, the latest first")
    public ResponseEntity<List<PartnerHandoffResponse>> partnerHandoffs(@PathVariable Long id) {
        return ResponseEntity.ok(partnerService.handoffs(id));
    }

    @GetMapping("/clients/{clientId}/partner-handoffs")
    @Operation(summary = "The partners a client was sent to, the latest first")
    public ResponseEntity<List<PartnerHandoffResponse>> clientHandoffs(@PathVariable Long clientId) {
        return ResponseEntity.ok(handoffService.forClient(clientId));
    }

    @PostMapping("/clients/{clientId}/partner-handoffs")
    @Operation(summary = "Send a client to a partner")
    public ResponseEntity<PartnerHandoffResponse> createHandoff(@PathVariable Long clientId,
                                                                @Valid @RequestBody PartnerHandoffRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(handoffService.create(clientId, request));
    }

    @PutMapping("/clients/{clientId}/partner-handoffs/{handoffId}")
    @Operation(summary = "Move a hand-off along: its status, day or note")
    public ResponseEntity<PartnerHandoffResponse> updateHandoff(@PathVariable Long clientId,
                                                                @PathVariable Long handoffId,
                                                                @Valid @RequestBody PartnerHandoffRequest request) {
        return ResponseEntity.ok(handoffService.update(clientId, handoffId, request));
    }

    @DeleteMapping("/clients/{clientId}/partner-handoffs/{handoffId}")
    @Operation(summary = "Take a hand-off back off the client")
    public ResponseEntity<Void> deleteHandoff(@PathVariable Long clientId, @PathVariable Long handoffId) {
        handoffService.delete(clientId, handoffId);
        return ResponseEntity.noContent().build();
    }
}
