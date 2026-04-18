package com.crm.realestate.controller;

import com.crm.realestate.dto.request.MeetingRequest;
import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.service.MeetingService;
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
@RequestMapping("/meetings")
@RequiredArgsConstructor
@Tag(name = "Meetings", description = "Schedule and manage meetings")
@SecurityRequirement(name = "bearerAuth")
public class MeetingController {

    private final MeetingService meetingService;

    @GetMapping
    @Operation(summary = "Get all meetings (optional filter by agent)")
    public ResponseEntity<List<MeetingResponse>> getAll(
            @RequestParam(required = false) Long agentId) {
        if (agentId != null) {
            return ResponseEntity.ok(meetingService.getByAgent(agentId));
        }
        return ResponseEntity.ok(meetingService.getAll());
    }

<<<<<<< Updated upstream
    @GetMapping("/upcoming")
    @Operation(summary = "Get upcoming meetings for an agent (next 7 days)")
    public ResponseEntity<List<MeetingResponse>> getUpcoming(@RequestParam Long agentId) {
=======


    @GetMapping("/upcoming/agent/{agentId}")
    @Operation(summary = "Get all upcoming meetings")
    public ResponseEntity<List<MeetingResponse>> getUpcoming(@PathVariable Long agentId) {
>>>>>>> Stashed changes
        return ResponseEntity.ok(meetingService.getUpcoming(agentId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get meeting by ID")
    public ResponseEntity<MeetingResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(meetingService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Create a new meeting")
    public ResponseEntity<MeetingResponse> create(@Valid @RequestBody MeetingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(meetingService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update meeting")
    public ResponseEntity<MeetingResponse> update(@PathVariable Long id,
                                                   @Valid @RequestBody MeetingRequest request) {
        return ResponseEntity.ok(meetingService.update(id, request));
    }

    @PatchMapping("/{id}/complete")
    @Operation(summary = "Mark meeting as completed")
    public ResponseEntity<MeetingResponse> markCompleted(@PathVariable Long id) {
        return ResponseEntity.ok(meetingService.markCompleted(id));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete meeting")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        meetingService.delete(id);
        return ResponseEntity.noContent().build();
    }
}