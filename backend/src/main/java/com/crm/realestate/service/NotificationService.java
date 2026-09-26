package com.crm.realestate.service;

import com.crm.realestate.dto.response.NotificationResponse;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.NotificationRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;

/**
 * The caller's feed, and the one door every event goes through to reach somebody else's.
 *
 * <p>Two rules hold for every event. Nobody is told about what they did themselves. And telling
 * somebody is never allowed to undo the thing being told: a failure here is logged and swallowed,
 * so the task is still created and the deal still moves.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class NotificationService {

    /** Larger pages are cut down to this, like a hostile or careless client asking for everything. */
    static final int MAX_PAGE_SIZE = 50;

    private final NotificationRepository notificationRepository;
    private final NotificationWriter     writer;
    private final ObjectMapper           objectMapper;

    // Writing ---------------------------------------------------------------------------

    /**
     * Tells {@code recipient} something {@code actor} did. Silently does nothing when there is
     * nobody to tell or when they would be telling themselves, and never throws.
     */
    @Transactional
    public void notify(User recipient, User actor, Team team, NotificationType type, Long targetId,
                       Map<String, Object> params) {
        if (recipient == null || recipient.getId() == null || isSamePerson(recipient, actor)) {
            return;
        }
        try {
            writer.write(recipient, team, type, targetId, params);
        } catch (RuntimeException e) {
            log.warn("Could not notify user {} of {} (target {}): {}",
                    recipient.getId(), type, targetId, e.toString());
        }
    }

    /** Whether this person was already told this about this record, so it is not said twice. */
    public boolean alreadyTold(User recipient, NotificationType type, Long targetId) {
        try {
            return writer.exists(recipient.getId(), type, targetId);
        } catch (RuntimeException e) {
            log.warn("Could not check earlier notifications of user {}: {}", recipient.getId(), e.toString());
            return false;
        }
    }

    static boolean isSamePerson(User a, User b) {
        return a != null && b != null && a.getId() != null && Objects.equals(a.getId(), b.getId());
    }

    // Reading ---------------------------------------------------------------------------

    public Page<NotificationResponse> list(User me, boolean unreadOnly, int page, int size) {
        Pageable pageable = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), MAX_PAGE_SIZE));
        Page<Notification> rows = unreadOnly
                ? notificationRepository.findByRecipientIdAndReadAtIsNullOrderByCreatedAtDescIdDesc(me.getId(), pageable)
                : notificationRepository.findByRecipientIdOrderByCreatedAtDescIdDesc(me.getId(), pageable);
        return rows.map(this::toResponse);
    }

    public long unreadCount(User me) {
        return notificationRepository.countByRecipientIdAndReadAtIsNull(me.getId());
    }

    /** Somebody else's notification reads as missing, so its existence is not confirmed either. */
    @Transactional
    public NotificationResponse markRead(User me, Long id) {
        Notification notification = notificationRepository.findByIdAndRecipientId(id, me.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found with id: " + id));
        if (notification.getReadAt() == null) {
            notification.setReadAt(LocalDateTime.now());
        }
        return toResponse(notificationRepository.save(notification));
    }

    /** How many were unread until now. */
    @Transactional
    public int markAllRead(User me) {
        return notificationRepository.markAllRead(me.getId(), LocalDateTime.now());
    }

    private NotificationResponse toResponse(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .type(n.getType())
                .targetId(n.getTargetId())
                .params(readParams(n))
                .readAt(n.getReadAt())
                .createdAt(n.getCreatedAt())
                .build();
    }

    private Map<String, Object> readParams(Notification n) {
        if (n.getPayload() == null || n.getPayload().isBlank()) {
            return Map.of();
        }
        try {
            return objectMapper.readValue(n.getPayload(), new TypeReference<Map<String, Object>>() { });
        } catch (Exception e) {
            log.warn("Unreadable payload on notification {}: {}", n.getId(), e.toString());
            return Map.of();
        }
    }
}
