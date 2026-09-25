package com.crm.realestate.controller;

import com.crm.realestate.dto.request.PropertyRequest;
import com.crm.realestate.dto.response.PropertyResponse;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.dto.response.DocumentDownload;
import com.crm.realestate.dto.response.PropertyPhotoResponse;
import com.crm.realestate.dto.response.PropertyPriceChangeResponse;
import com.crm.realestate.service.PropertyPhotoService;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;
import com.crm.realestate.dto.request.PhotoOrderRequest;
import com.crm.realestate.dto.response.ClientMatch;
import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.service.MatchingService;
import com.crm.realestate.service.MeetingService;
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
    private final MatchingService matchingService;
    private final MeetingService  meetingService;
    private final PropertyPhotoService photoService;

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

    @GetMapping("/{id}/photos")
    @Operation(summary = "The photographs of this listing, in gallery order")
    public ResponseEntity<List<PropertyPhotoResponse>> photos(@PathVariable Long id) {
        return ResponseEntity.ok(photoService.getByProperty(id));
    }

    @PostMapping(value = "/{id}/photos", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Add a photograph to this listing")
    public ResponseEntity<PropertyPhotoResponse> addPhoto(
            @PathVariable Long id, @RequestParam("file") MultipartFile file) {
        return ResponseEntity.status(HttpStatus.CREATED).body(photoService.upload(id, file));
    }

    @GetMapping("/{id}/cover")
    @Operation(summary = "A small copy of this listing's first photograph, for a row in a list")
    public ResponseEntity<Resource> cover(@PathVariable Long id) {
        DocumentDownload cover = photoService.cover(id);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(cover.contentType()))
                .body(cover.resource());
    }

    @GetMapping("/{id}/photos/{photoId}/content")
    @Operation(summary = "The bytes of one photograph")
    public ResponseEntity<Resource> photoContent(
            @PathVariable Long id, @PathVariable Long photoId) {
        DocumentDownload photo = photoService.download(id, photoId);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(photo.contentType()))
                .body(photo.resource());
    }

    @PutMapping("/{id}/photos/order")
    @Operation(summary = "Put the gallery in this order; the first one is the cover")
    public ResponseEntity<List<PropertyPhotoResponse>> reorderPhotos(
            @PathVariable Long id, @Valid @RequestBody PhotoOrderRequest request) {
        return ResponseEntity.ok(photoService.reorder(id, request.getPhotoIds()));
    }

    @DeleteMapping("/{id}/photos/{photoId}")
    @Operation(summary = "Remove a photograph from this listing")
    public ResponseEntity<Void> deletePhoto(@PathVariable Long id, @PathVariable Long photoId) {
        photoService.delete(id, photoId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/price-history")
    @Operation(summary = "Every change of this listing's price, newest first")
    public ResponseEntity<List<PropertyPriceChangeResponse>> priceHistory(@PathVariable Long id) {
        return ResponseEntity.ok(propertyService.priceHistory(id));
    }

    @GetMapping("/{id}/viewings")
    @Operation(summary = "Every viewing booked for this listing, most recent first")
    public ResponseEntity<List<MeetingResponse>> viewings(@PathVariable Long id) {
        return ResponseEntity.ok(meetingService.getByProperty(id));
    }

    @GetMapping("/{id}/interested")
    @Operation(summary = "Buyers whose stated requirements this listing answers")
    public ResponseEntity<List<ClientMatch>> interested(@PathVariable Long id) {
        return ResponseEntity.ok(matchingService.buyersFor(id));
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