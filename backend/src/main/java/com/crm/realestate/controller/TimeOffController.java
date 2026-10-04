package com.crm.realestate.controller;

import com.crm.realestate.dto.request.TimeOffRequest;
import com.crm.realestate.dto.response.TimeOffResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.TimeOffService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Agents' time off and who covers for them. See {@link TimeOffService} for who may do what. An
 * admin names the agency with {@code teamId}.
 */
@RestController
@RequestMapping("/time-off")
@RequiredArgsConstructor
@Tag(name = "Time off", description = "Who is away, when, and who covers for them")
@SecurityRequirement(name = "bearerAuth")
public class TimeOffController {

    private final TimeOffService timeOffService;
    private final SecurityUtils securityUtils;

    @GetMapping
    @Operation(summary = "The agency's time off taking in any day of [from, to], soonest first; "
            + "from today and 90 days on unless told, one person's with userId")
    public ResponseEntity<List<TimeOffResponse>> list(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long teamId) {
        return ResponseEntity.ok(timeOffService.list(securityUtils.getCurrentUser(), teamId, from, to, userId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "One absence, with the meetings the absent person still has on those days")
    public ResponseEntity<TimeOffResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(timeOffService.get(securityUtils.getCurrentUser(), id));
    }

    @PostMapping
    @Operation(summary = "Write down time off: the caller's own, or a colleague's for a manager")
    public ResponseEntity<TimeOffResponse> create(@RequestParam(required = false) Long teamId,
                                                  @Valid @RequestBody TimeOffRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(timeOffService.create(securityUtils.getCurrentUser(), teamId, request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Change the kind, the days, the cover or the note; whose it is stays")
    public ResponseEntity<TimeOffResponse> update(@PathVariable Long id,
                                                  @Valid @RequestBody TimeOffRequest request) {
        return ResponseEntity.ok(timeOffService.update(securityUtils.getCurrentUser(), id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Cancel time off")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        timeOffService.delete(securityUtils.getCurrentUser(), id);
        return ResponseEntity.noContent().build();
    }
}
