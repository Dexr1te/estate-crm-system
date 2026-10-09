package com.crm.realestate.entity;

import com.crm.realestate.enums.StarType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * One person's star on a client, a listing or a deal they are working on right now.
 *
 * <p>The record is named by type and id rather than by a foreign key, since it lives in one of
 * three tables; whatever deletes a record takes its stars with it ({@link
 * com.crm.realestate.service.StarStore}). The delete rule on the person and the one star per
 * record are declared here as well as in V57 so the schema generated for tests behaves the way the
 * migrated one does.
 */
@Entity
@Table(name = "stars",
        uniqueConstraints = @UniqueConstraint(name = "uq_stars_user_entity",
                columnNames = {"user_id", "entity_type", "entity_id"}),
        indexes = @Index(name = "idx_stars_entity", columnList = "entity_type, entity_id"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Star {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Whose star. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "entity_type", nullable = false, length = 10)
    private StarType entityType;

    @Column(name = "entity_id", nullable = false)
    private Long entityId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * To the microsecond, as the column keeps it, so the answer to a star and a later read of it
     * name the same moment.
     */
    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now().truncatedTo(ChronoUnit.MICROS);
        }
    }
}
