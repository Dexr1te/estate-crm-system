package com.crm.realestate.controller;

import com.crm.realestate.dto.request.DealRequest;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.service.DealService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/deals")
@RequiredArgsConstructor
@Tag(name = "Deals", description = "Sales pipeline: LEAD → NEGOTIATION → CLOSED")
@SecurityRequirement(name = "bearerAuth")
public class DealController {

    private final DealService dealService;

    @GetMapping
    @Operation(summary = "Get all deals (optional filter by agent or status)")
    public ResponseEntity<List<DealResponse>> getAll(
            @RequestParam(required = false) Long agentId,
            @RequestParam(required = false) DealStatus status) {

        if (agentId != null) {
            return ResponseEntity.ok(dealService.getByAgent(agentId));
        }
        if (status != null) {
            return ResponseEntity.ok(dealService.getByStatus(status));
        }
        return ResponseEntity.ok(dealService.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get deal by ID")
    public ResponseEntity<DealResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(dealService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Create a new deal")
    public ResponseEntity<DealResponse> create(@Valid @RequestBody DealRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(dealService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update deal")
    public ResponseEntity<DealResponse> update(@PathVariable Long id,
                                                @Valid @RequestBody DealRequest request) {
        return ResponseEntity.ok(dealService.update(id, request));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Move deal to next stage")
    public ResponseEntity<DealResponse> updateStatus(@PathVariable Long id,
                                                      @RequestParam DealStatus status) {
        return ResponseEntity.ok(dealService.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete deal")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dealService.delete(id);
        return ResponseEntity.noContent().build();
    }
}