package com.crm.realestate.controller;

import com.crm.realestate.dto.request.KeyHandoverRequest;
import com.crm.realestate.dto.response.KeyHandoverResponse;
import com.crm.realestate.dto.response.PropertyKeysResponse;
import com.crm.realestate.service.PropertyKeyService;
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
 * Who has a listing's keys, handing them out and taking them back, and the agency's keys that are
 * out. See {@link PropertyKeyService} for the rules.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Keys", description = "Who has a listing's keys, and which keys are out")
@SecurityRequirement(name = "bearerAuth")
public class PropertyKeyController {

    private final PropertyKeyService keyService;

    @GetMapping("/properties/{propertyId}/keys")
    @Operation(summary = "Who has the listing's keys now, and the handovers that are over, the newest first (at most 50)")
    public ResponseEntity<PropertyKeysResponse> forProperty(@PathVariable Long propertyId) {
        return ResponseEntity.ok(keyService.forProperty(propertyId));
    }

    @PostMapping("/properties/{propertyId}/keys/handover")
    @Operation(summary = "Hand the listing's keys to a colleague or to somebody by name",
            description = "Exactly one of holderUserId and holderName (400 KEY_HOLDER_REQUIRED); a colleague "
                    + "is an active member of the agency (another agency's: 404); dueBackAt not past "
                    + "(400 KEY_DUE_IN_PAST); the keys are in the office (409 KEY_ALREADY_OUT). "
                    + "Answers with the listing's keys as they are now")
    public ResponseEntity<PropertyKeysResponse> handOut(@PathVariable Long propertyId,
                                                        @Valid @RequestBody KeyHandoverRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(keyService.handOut(propertyId, request));
    }

    @PostMapping("/properties/{propertyId}/keys/return")
    @Operation(summary = "Take the listing's keys back (409 KEY_NOT_OUT when they are in the office)",
            description = "Answers with the listing's keys as they are now")
    public ResponseEntity<PropertyKeysResponse> giveBack(@PathVariable Long propertyId) {
        return ResponseEntity.ok(keyService.giveBack(propertyId));
    }

    @GetMapping("/keys/out")
    @Operation(summary = "Every key out of a listing the caller can see: overdue first, then by the day "
            + "they are due back, the ones without a day last")
    public ResponseEntity<List<KeyHandoverResponse>> out() {
        return ResponseEntity.ok(keyService.out());
    }
}
