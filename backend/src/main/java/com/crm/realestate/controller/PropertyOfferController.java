package com.crm.realestate.controller;

import com.crm.realestate.dto.request.OfferCounterRequest;
import com.crm.realestate.dto.request.OfferDecisionRequest;
import com.crm.realestate.dto.request.PropertyOfferRequest;
import com.crm.realestate.dto.response.PropertyOfferResponse;
import com.crm.realestate.service.PropertyOfferService;
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
 * Buyers' offers on a listing and the negotiation on each. See {@link PropertyOfferService} for
 * who may do what, and what accepting one does to the others.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Offers", description = "Buyers' offers on a listing, counters and decisions")
@SecurityRequirement(name = "bearerAuth")
public class PropertyOfferController {

    private final PropertyOfferService offerService;

    @GetMapping("/properties/{propertyId}/offers")
    @Operation(summary = "A listing's offers, the highest first")
    public ResponseEntity<List<PropertyOfferResponse>> forProperty(@PathVariable Long propertyId) {
        return ResponseEntity.ok(offerService.forProperty(propertyId));
    }

    @PostMapping("/properties/{propertyId}/offers")
    @Operation(summary = "Record a buyer's offer on a listing; the caller follows it up")
    public ResponseEntity<PropertyOfferResponse> create(@PathVariable Long propertyId,
                                                        @Valid @RequestBody PropertyOfferRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(offerService.create(propertyId, request));
    }

    @GetMapping("/clients/{clientId}/offers")
    @Operation(summary = "A buyer's offers, the latest first")
    public ResponseEntity<List<PropertyOfferResponse>> forClient(@PathVariable Long clientId) {
        return ResponseEntity.ok(offerService.forClient(clientId));
    }

    @GetMapping("/offers/{id}")
    @Operation(summary = "One offer with its negotiation, the first step first")
    public ResponseEntity<PropertyOfferResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(offerService.get(id));
    }

    @PostMapping("/offers/{id}/counter")
    @Operation(summary = "Put a new figure on the table, from the buyer or the seller")
    public ResponseEntity<PropertyOfferResponse> counter(@PathVariable Long id,
                                                         @Valid @RequestBody OfferCounterRequest request) {
        return ResponseEntity.ok(offerService.counter(id, request));
    }

    @PostMapping("/offers/{id}/accept")
    @Operation(summary = "Accept the figure on the table (409 OFFER_ALREADY_ACCEPTED if another is)")
    public ResponseEntity<PropertyOfferResponse> accept(@PathVariable Long id,
                                                        @Valid @RequestBody(required = false) OfferDecisionRequest request) {
        return ResponseEntity.ok(offerService.accept(id, request));
    }

    @PostMapping("/offers/{id}/reject")
    @Operation(summary = "Reject an open offer")
    public ResponseEntity<PropertyOfferResponse> reject(@PathVariable Long id,
                                                        @Valid @RequestBody(required = false) OfferDecisionRequest request) {
        return ResponseEntity.ok(offerService.reject(id, request));
    }

    @PostMapping("/offers/{id}/withdraw")
    @Operation(summary = "The buyer withdraws an open or accepted offer")
    public ResponseEntity<PropertyOfferResponse> withdraw(@PathVariable Long id,
                                                          @Valid @RequestBody(required = false) OfferDecisionRequest request) {
        return ResponseEntity.ok(offerService.withdraw(id, request));
    }
}
