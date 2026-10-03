package com.crm.realestate.entity;

import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One line of a record's change log: a listing, deal or client was created, deleted, or one of its
 * fields moved from one value to another. See V49.
 *
 * <p>The record is named by type and id rather than a foreign key, because the line saying it was
 * deleted has to outlive it. Who made the change is kept twice: as a reference, cleared when the
 * person's account goes, and as the name they had then, which stays.
 */
@Entity
@Table(name = "record_changes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecordChange {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    @Enumerated(EnumType.STRING)
    @Column(name = "entity_type", nullable = false, length = 16)
    private ChangeEntityType entityType;

    @Column(name = "entity_id", nullable = false)
    private Long entityId;

    @Column(name = "entity_label")
    private String entityLabel;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User actor;

    @Column(name = "actor_name")
    private String actorName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ChangeAction action;

    @Column(length = 40)
    private String field;

    @Column(name = "old_value", columnDefinition = "TEXT")
    private String oldValue;

    @Column(name = "new_value", columnDefinition = "TEXT")
    private String newValue;

    @Column(name = "changed_at", nullable = false, updatable = false)
    private LocalDateTime changedAt;

    @PrePersist
    void onCreate() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}
