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

import java.time.LocalDate;
import java.util.Map;
import java.util.Optional;

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
        write(recipient, team, type, targetId, params, false);
    }

    /** The same, marked as a cover's copy of somebody else's notification when {@code covering}. */
    public void write(User recipient, Team team, NotificationType type, Long targetId,
                      Map<String, Object> params, boolean covering) {
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
                .covering(covering)
                .build());
    }

    /** Whether they were told this themselves; a copy they got as somebody's cover does not count. */
    public boolean exists(Long recipientId, NotificationType type, Long targetId) {
        Long count = entityManager.createQuery(
                        "SELECT COUNT(n) FROM Notification n WHERE n.recipient.id = :recipient"
                                + " AND n.type = :type AND n.targetId = :target AND n.covering = false",
                        Long.class)
                .setParameter("recipient", recipientId)
                .setParameter("type", type)
                .setParameter("target", targetId)
                .getSingleResult();
        return count > 0;
    }

    /**
     * Whoever covers for {@code absentId} in {@code teamId} on {@code day}: an active member of that
     * agency named on an absence of theirs there which takes in the day, or nobody. Read through the
     * entity manager for the same reason {@link #write} is.
     */
    public Optional<User> coverFor(Long absentId, Long teamId, LocalDate day) {
        return entityManager.createQuery(
                        "SELECT c FROM TimeOff t JOIN t.cover c JOIN t.user u"
                                + " WHERE u.id = :absent AND t.team.id = :team AND u.team.id = :team"
                                + " AND t.startDate <= :day AND t.endDate >= :day"
                                + " AND c.team.id = :team AND c.isActive = true",
                        User.class)
                .setParameter("absent", absentId)
                .setParameter("team", teamId)
                .setParameter("day", day)
                .setMaxResults(1)
                .getResultStream()
                .findFirst();
    }
}
