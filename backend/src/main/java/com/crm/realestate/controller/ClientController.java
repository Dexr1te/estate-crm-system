package com.crm.realestate.controller;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.response.ClientListItem;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.service.ClientService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/clients")
@RequiredArgsConstructor
@Tag(name = "Clients", description = "Manage buyers and sellers")
@SecurityRequirement(name = "bearerAuth")
public class ClientController {

    private final ClientService clientService;

    @GetMapping
    @Operation(summary = "Get all clients (supports pagination, sorting, and filters). Backward-compatible: returns legacy list when no paging/filters provided.")
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) ClientType type,
            @RequestParam(required = false) Long agentId,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String createdFrom,
            @RequestParam(required = false) String createdTo,
            org.springframework.data.domain.Pageable pageable,
            jakarta.servlet.http.HttpServletRequest request) {

        boolean hasPageParams = request.getParameterMap().containsKey("page")
                || request.getParameterMap().containsKey("size")
                || request.getParameterMap().containsKey("sort");

        boolean hasAnyFilter = type != null || agentId != null || (search != null && !search.isBlank())
                || createdFrom != null || createdTo != null;

        if (!hasPageParams && !hasAnyFilter) {
            // Legacy behavior
            return ResponseEntity.ok(clientService.getAll());
        }

        // Parse createdFrom / createdTo as LocalDate if provided
        java.time.LocalDate fromDate = null;
        java.time.LocalDate toDate = null;
        try {
            if (createdFrom != null && !createdFrom.isBlank()) {
                fromDate = java.time.LocalDate.parse(createdFrom);
            }
            if (createdTo != null && !createdTo.isBlank()) {
                toDate = java.time.LocalDate.parse(createdTo);
            }
        } catch (java.time.format.DateTimeParseException ex) {
            return ResponseEntity.badRequest().body("Invalid date format for createdFrom/createdTo. Use ISO format: yyyy-MM-dd");
        }

        // Enforce maximum page size to protect from large requests
        final int MAX_PAGE_SIZE = 100;
        final int DEFAULT_PAGE_SIZE = 20;
        org.springframework.data.domain.Pageable effectivePageable = pageable;
        if (pageable.getPageSize() <= 0) {
            effectivePageable = org.springframework.data.domain.PageRequest.of(pageable.getPageNumber(), DEFAULT_PAGE_SIZE, pageable.getSort());
        } else if (pageable.getPageSize() > MAX_PAGE_SIZE) {
            effectivePageable = org.springframework.data.domain.PageRequest.of(pageable.getPageNumber(), MAX_PAGE_SIZE, pageable.getSort());
        }

        org.springframework.data.domain.Page<com.crm.realestate.dto.response.ClientResponse> page = clientService.search(
                type, agentId, fromDate, toDate, search, effectivePageable);

        return ResponseEntity.ok(page);
    }

    @GetMapping("/with-details")
    @Operation(summary = "Get clients with deal status, property and next meeting - for frontend table")
    public ResponseEntity<List<ClientListItem>> getWithDetails() {
        return ResponseEntity.ok(clientService.getClientsWithDetails());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get client by ID")
    public ResponseEntity<ClientResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(clientService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Create a new client")
    public ResponseEntity<ClientResponse> create(@Valid @RequestBody ClientRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(clientService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update client")
    public ResponseEntity<ClientResponse> update(@PathVariable Long id,
                                                  @Valid @RequestBody ClientRequest request) {
        return ResponseEntity.ok(clientService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')") 
    @Operation(summary = "Delete client")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        clientService.delete(id);
        return ResponseEntity.noContent().build();
    }
}