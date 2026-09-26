package com.crm.realestate.controller;

import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.dto.response.TaskResponse;
import com.crm.realestate.service.TaskService;
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

@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
@Tag(name = "Tasks", description = "Follow-ups with a due time")
@SecurityRequirement(name = "bearerAuth")
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    @Operation(summary = "Tasks the caller may see: open soonest first by default, done, or all;"
            + " optionally only those due in [from, to)")
    public ResponseEntity<List<TaskResponse>> list(
            @RequestParam(required = false, defaultValue = "open") String status,
            @RequestParam(required = false) Long clientId,
            @RequestParam(required = false) Long dealId,
            @RequestParam(required = false) Long assigneeId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {
        return ResponseEntity.ok(taskService.list(status, clientId, dealId, assigneeId, from, to));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a task by ID")
    public ResponseEntity<TaskResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(taskService.get(id));
    }

    @PostMapping
    @Operation(summary = "Create a task; it goes to the caller unless a manager names someone")
    public ResponseEntity<TaskResponse> create(@Valid @RequestBody TaskRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(taskService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a task")
    public ResponseEntity<TaskResponse> update(@PathVariable Long id, @Valid @RequestBody TaskRequest request) {
        return ResponseEntity.ok(taskService.update(id, request));
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "Mark a task done")
    public ResponseEntity<TaskResponse> complete(@PathVariable Long id) {
        return ResponseEntity.ok(taskService.complete(id));
    }

    @PostMapping("/{id}/reopen")
    @Operation(summary = "Put a done task back on the list")
    public ResponseEntity<TaskResponse> reopen(@PathVariable Long id) {
        return ResponseEntity.ok(taskService.reopen(id));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a task")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        taskService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
