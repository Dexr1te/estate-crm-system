package com.crm.realestate.controller;

import com.crm.realestate.dto.request.DealChecklistItemRequest;
import com.crm.realestate.dto.request.DealChecklistPatchRequest;
import com.crm.realestate.dto.response.ChecklistItemResponse;
import com.crm.realestate.service.DealChecklistService;
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
@RequestMapping("/deals/{dealId}/checklist")
@RequiredArgsConstructor
@Tag(name = "Deal checklist", description = "What a deal still needs, stage by stage")
@SecurityRequirement(name = "bearerAuth")
public class DealChecklistController {

    private final DealChecklistService checklistService;

    @GetMapping
    @Operation(summary = "The deal's checklist, by stage and position (copied from the template on first read)")
    public ResponseEntity<List<ChecklistItemResponse>> list(@PathVariable Long dealId) {
        return ResponseEntity.ok(checklistService.list(dealId));
    }

    @PostMapping
    @Operation(summary = "Add an item of this deal's own (the deal's agent or a manager)")
    public ResponseEntity<ChecklistItemResponse> add(@PathVariable Long dealId,
                                                     @Valid @RequestBody DealChecklistItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(checklistService.add(dealId, request));
    }

    @PatchMapping("/{itemId}")
    @Operation(summary = "Tick or un-tick an item; link or unlink one of the deal's documents")
    public ResponseEntity<ChecklistItemResponse> update(@PathVariable Long dealId, @PathVariable Long itemId,
                                                        @RequestBody DealChecklistPatchRequest request) {
        return ResponseEntity.ok(checklistService.update(dealId, itemId, request));
    }

    @DeleteMapping("/{itemId}")
    @Operation(summary = "Delete an item added on this deal (the deal's agent or a manager)")
    public ResponseEntity<Void> delete(@PathVariable Long dealId, @PathVariable Long itemId) {
        checklistService.delete(dealId, itemId);
        return ResponseEntity.noContent().build();
    }
}
