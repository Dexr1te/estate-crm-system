package com.crm.realestate.controller;

import com.crm.realestate.dto.request.OpenHouseRequest;
import com.crm.realestate.dto.request.OpenHouseVisitorRequest;
import com.crm.realestate.dto.response.OpenHouseResponse;
import com.crm.realestate.dto.response.OpenHouseVisitorResponse;
import com.crm.realestate.service.OpenHouseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Open houses: scheduled on a listing, read one at a time or as a calendar window, and the
 * sign-in sheet that fills during one. See {@link OpenHouseService} for who may do what.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Open houses", description = "Open houses on a listing and their sign-in sheets")
@SecurityRequirement(name = "bearerAuth")
public class OpenHouseController {

    private final OpenHouseService openHouseService;

    @GetMapping("/properties/{propertyId}/open-houses")
    @Operation(summary = "A listing's open houses, the latest first, each with visitors, new clients and interested")
    public ResponseEntity<List<OpenHouseResponse>> forProperty(@PathVariable Long propertyId) {
        return ResponseEntity.ok(openHouseService.forProperty(propertyId));
    }

    @PostMapping("/properties/{propertyId}/open-houses")
    @Operation(summary = "Schedule an open house on a listing; the caller holds it")
    public ResponseEntity<OpenHouseResponse> create(@PathVariable Long propertyId,
                                                    @Valid @RequestBody OpenHouseRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(openHouseService.create(propertyId, request));
    }

    @GetMapping("/open-houses")
    @Operation(summary = "Open houses overlapping [from, to) within the caller's data scope, for the calendar")
    public ResponseEntity<List<OpenHouseResponse>> inRange(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ResponseEntity.ok(openHouseService.inRange(from, to));
    }

    @GetMapping("/open-houses/{id}")
    @Operation(summary = "One open house with its sign-in sheet, latest arrival first")
    public ResponseEntity<OpenHouseResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(openHouseService.get(id));
    }

    @PutMapping("/open-houses/{id}")
    @Operation(summary = "Move an open house or change its note; the host, a manager or an admin")
    public ResponseEntity<OpenHouseResponse> update(@PathVariable Long id,
                                                    @Valid @RequestBody OpenHouseRequest request) {
        return ResponseEntity.ok(openHouseService.update(id, request));
    }

    @DeleteMapping("/open-houses/{id}")
    @Operation(summary = "Cancel an open house nobody has signed in at (409 OPEN_HOUSE_HAS_VISITORS otherwise)")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        openHouseService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/open-houses/{id}/visitors")
    @Operation(summary = "Sign a visitor in: matched to the agency's clients by phone, or a new buyer")
    public ResponseEntity<OpenHouseVisitorResponse> signIn(@PathVariable Long id,
                                                           @Valid @RequestBody OpenHouseVisitorRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(openHouseService.signIn(id, request));
    }

    @DeleteMapping("/open-houses/{id}/visitors/{visitorId}")
    @Operation(summary = "Take a visitor off the sheet, and the visit out of the client's history")
    public ResponseEntity<Void> removeVisitor(@PathVariable Long id, @PathVariable Long visitorId) {
        openHouseService.removeVisitor(id, visitorId);
        return ResponseEntity.noContent().build();
    }
}
