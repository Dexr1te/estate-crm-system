package com.crm.realestate.controller;

import com.crm.realestate.dto.request.CommissionSplitRequest;
import com.crm.realestate.dto.response.CommissionSplitResponse;
import com.crm.realestate.service.CommissionSplitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/deals")
@RequiredArgsConstructor
@Tag(name = "Commission split", description = "Who gets what share of a deal's commission")
@SecurityRequirement(name = "bearerAuth")
public class CommissionSplitController {

    private final CommissionSplitService splitService;

    @GetMapping("/{dealId}/commission-split")
    @Operation(summary = "Who gets what of the deal's commission: its agent first, then the shares",
            description = "With the colleagues who may be given a share when the caller may edit")
    public ResponseEntity<CommissionSplitResponse> get(@PathVariable Long dealId) {
        return ResponseEntity.ok(splitService.get(dealId));
    }

    @PutMapping("/{dealId}/commission-split")
    @Operation(summary = "Replace the split (the deal's agent, a manager or an admin)",
            description = "Shares total exactly 100 (400 SPLIT_TOTAL_NOT_100); each goes to a colleague or "
                    + "a co-broker by name (400 SPLIT_PARTY_REQUIRED), each person once "
                    + "(400 SPLIT_DUPLICATE_PERSON); a colleague is an active member of the deal's agency "
                    + "(400 SPLIT_COLLEAGUE_INACTIVE, another agency's: 404)")
    public ResponseEntity<CommissionSplitResponse> replace(@PathVariable Long dealId,
                                                           @Valid @RequestBody CommissionSplitRequest request) {
        return ResponseEntity.ok(splitService.replace(dealId, request));
    }

    @DeleteMapping("/{dealId}/commission-split")
    @Operation(summary = "Give the whole commission back to the deal's agent")
    public ResponseEntity<CommissionSplitResponse> clear(@PathVariable Long dealId) {
        return ResponseEntity.ok(splitService.clear(dealId));
    }
}
