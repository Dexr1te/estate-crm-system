package com.crm.realestate.controller;

import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.service.PropertyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/properties")
@RequiredArgsConstructor
@Tag(name = "Properties", description = "Manage real estate listings")
@SecurityRequirement(name = "bearerAuth")
public class PropertyController {

    private final PropertyService propertyService;

    @GetMapping
    @Operation(summary = "Get all properties (with optional filters). Supports pagination & sorting via Pageable (page, size, sort)")
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) PropertyStatus status,
            @RequestParam(required = false) PropertyType type,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Integer rooms,
            @RequestParam(required = false) Long agentId,
            @RequestParam(required = false) String search,
            org.springframework.data.domain.Pageable pageable,
            jakarta.servlet.http.HttpServletRequest request) {

        // Preserve backward compatibility: if no pagination params were provided and no filters/search used,
        // return previous behavior (full list) as JSON array to avoid breaking existing clients.
        boolean hasPageParams = request.getParameterMap().containsKey("page")
                || request.getParameterMap().containsKey("size")
                || request.getParameterMap().containsKey("sort");

        boolean hasAnyFilter = status != null || type != null || city != null || minPrice != null
                || maxPrice != null || rooms != null || agentId != null || (search != null && !search.isBlank());

        if (!hasPageParams && !hasAnyFilter) {
            // legacy behavior
            return ResponseEntity.ok(propertyService.getAll());
        }

        org.springframework.data.domain.Page<PropertyResponse> page = propertyService.search(
                status, type, city, minPrice, maxPrice, rooms, agentId, search, pageable);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get property by ID")
    public ResponseEntity<PropertyResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(propertyService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Create a new property listing")
    public ResponseEntity<PropertyResponse> create(@Valid @RequestBody PropertyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(propertyService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update property")
    public ResponseEntity<PropertyResponse> update(@PathVariable Long id,
                                                    @Valid @RequestBody PropertyRequest request) {
        return ResponseEntity.ok(propertyService.update(id, request));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update property status (AVAILABLE / RESERVED / SOLD)")
    public ResponseEntity<PropertyResponse> updateStatus(@PathVariable Long id,
                                                          @RequestParam PropertyStatus status) {
        return ResponseEntity.ok(propertyService.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete property")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        propertyService.delete(id);
        return ResponseEntity.noContent().build();
    }
}