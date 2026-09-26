package com.crm.realestate.controller;

import com.crm.realestate.dto.response.NotificationResponse;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * The caller's own feed, and nobody else's.
 *
 * <p>Deliberately outside the team-required paths in {@code WebConfig}: an invitation to join an
 * agency reaches somebody who is not in one yet.
 */
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "What happened that the caller did not do themselves")
@SecurityRequirement(name = "bearerAuth")
public class NotificationController {

    private final NotificationService notificationService;
    private final SecurityUtils       securityUtils;

    @GetMapping
    @Operation(summary = "The caller's notifications, newest first, a page at a time")
    public ResponseEntity<Page<NotificationResponse>> list(
            @RequestParam(defaultValue = "false") boolean unreadOnly,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(notificationService.list(securityUtils.getCurrentUser(), unreadOnly, page, size));
    }

    @GetMapping("/unread-count")
    @Operation(summary = "How many of the caller's notifications are unread")
    public ResponseEntity<Map<String, Long>> unreadCount() {
        return ResponseEntity.ok(Map.of("count", notificationService.unreadCount(securityUtils.getCurrentUser())));
    }

    @PostMapping("/{id}/read")
    @Operation(summary = "Mark one of the caller's notifications read")
    public ResponseEntity<NotificationResponse> markRead(@PathVariable Long id) {
        return ResponseEntity.ok(notificationService.markRead(securityUtils.getCurrentUser(), id));
    }

    @PostMapping("/read-all")
    @Operation(summary = "Mark every one of the caller's notifications read")
    public ResponseEntity<Map<String, Integer>> markAllRead() {
        return ResponseEntity.ok(Map.of("updated", notificationService.markAllRead(securityUtils.getCurrentUser())));
    }
}
