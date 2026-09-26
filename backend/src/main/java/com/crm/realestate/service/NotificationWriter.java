package com.crm.realestate.service;

import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.NotificationType;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Puts one notification row in the current transaction.
 *
 * <p>It goes through the entity manager rather than a repository on purpose: a repository call is
 * itself transactional, and one failing inside the business action's transaction would mark that
 * whole transaction for rollback even though {@link NotificationService} catches the exception.
 */
@Component
@RequiredArgsConstructor
public class NotificationWriter {

    private final ObjectMapper objectMapper;

    @PersistenceContext
    private EntityManager entityManager;

    public void write(User recipient, Team team, NotificationType type, Long targetId,
                      Map<String, Object> params) {
        String payload;
        try {
            payload = params == null || params.isEmpty() ? null : objectMapper.writeValueAsString(params);
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException("Notification params cannot be written as JSON", e);
        }
        entityManager.persist(Notification.builder()
                .recipient(recipient)
                .team(team)
                .type(type)
                .targetId(targetId)
                .payload(payload)
                .build());
    }

    public boolean exists(Long recipientId, NotificationType type, Long targetId) {
        Long count = entityManager.createQuery(
                        "SELECT COUNT(n) FROM Notification n WHERE n.recipient.id = :recipient"
                                + " AND n.type = :type AND n.targetId = :target", Long.class)
                .setParameter("recipient", recipientId)
                .setParameter("type", type)
                .setParameter("target", targetId)
                .getSingleResult();
        return count > 0;
    }
}
