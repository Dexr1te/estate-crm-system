package com.crm.realestate.controller;

import com.crm.realestate.dto.request.DealDepositCloseRequest;
import com.crm.realestate.dto.request.DealDepositRequest;
import com.crm.realestate.dto.response.DealDepositResponse;
import com.crm.realestate.service.DealDepositService;
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
@Tag(name = "Deal deposits", description = "The deposit a buyer puts down, and the listing it holds")
@SecurityRequirement(name = "bearerAuth")
public class DealDepositController {

    private final DealDepositService depositService;

    @GetMapping("/deposits-ending")
    @Operation(summary = "Active deposits whose hold ends within 7 days or has ended; soonest first")
    public ResponseEntity<List<DealDepositResponse>> ending() {
        return ResponseEntity.ok(depositService.ending());
    }

    @GetMapping("/{dealId}/deposits")
    @Operation(summary = "The deal's deposits, the latest first")
    public ResponseEntity<List<DealDepositResponse>> list(@PathVariable Long dealId) {
        return ResponseEntity.ok(depositService.list(dealId));
    }

    @PostMapping("/{dealId}/deposits")
    @Operation(summary = "Record a deposit (the deal's agent or a manager); one active at a time")
    public ResponseEntity<DealDepositResponse> record(@PathVariable Long dealId,
                                                      @Valid @RequestBody DealDepositRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(depositService.record(dealId, request));
    }

    @PutMapping("/{dealId}/deposits/{depositId}")
    @Operation(summary = "Correct an active deposit")
    public ResponseEntity<DealDepositResponse> update(@PathVariable Long dealId, @PathVariable Long depositId,
                                                      @Valid @RequestBody DealDepositRequest request) {
        return ResponseEntity.ok(depositService.update(dealId, depositId, request));
    }

    @PostMapping("/{dealId}/deposits/{depositId}/close")
    @Operation(summary = "End a deposit: applied to the purchase, refunded or forfeited, on a day")
    public ResponseEntity<DealDepositResponse> close(@PathVariable Long dealId, @PathVariable Long depositId,
                                                     @Valid @RequestBody DealDepositCloseRequest request) {
        return ResponseEntity.ok(depositService.close(dealId, depositId, request));
    }
}
