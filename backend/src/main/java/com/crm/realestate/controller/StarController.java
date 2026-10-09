package com.crm.realestate.controller;

import com.crm.realestate.dto.response.StarResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.StarService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * The caller's starred records. {@code type} is CLIENT, PROPERTY or DEAL; see {@link StarService}
 * for what may be starred and what the list shows.
 */
@RestController
@RequestMapping("/stars")
@RequiredArgsConstructor
@Tag(name = "Stars", description = "The clients, listings and deals each person keeps one tap away")
@SecurityRequirement(name = "bearerAuth")
public class StarController {

    private final StarService starService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @Operation(summary = "The caller's starred records they can still see, newest first")
    public ResponseEntity<List<StarResponse>> list() {
        return ResponseEntity.ok(starService.list(securityUtils.getCurrentUser()));
    }

    @PutMapping("/{type}/{id}")
    @Operation(summary = "Star a record the caller can see; starring it again answers with the same star")
    public ResponseEntity<StarResponse> star(@PathVariable String type, @PathVariable Long id) {
        return ResponseEntity.ok(starService.star(securityUtils.getCurrentUser(), type, id));
    }

    @DeleteMapping("/{type}/{id}")
    @Operation(summary = "Take the caller's star off a record; no star there is not an error")
    public ResponseEntity<Void> unstar(@PathVariable String type, @PathVariable Long id) {
        starService.unstar(securityUtils.getCurrentUser(), type, id);
        return ResponseEntity.noContent().build();
    }
}
