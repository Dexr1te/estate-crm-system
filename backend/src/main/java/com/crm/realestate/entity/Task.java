package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * Something somebody has to do by a certain time, optionally about a client or a deal.
 *
 * <p>The delete rules are declared here as well as in V27 so a schema generated from the
 * entities — the test database is one — behaves the way the migrated one does.
 */
@Entity
@Table(name = "tasks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // The agency this record belongs to. See ScopeService for what it decides.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignee_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User assignee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User createdBy;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "due_at", nullable = false)
    private LocalDateTime dueAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Deal deal;

    /** The repeat rule this task is an occurrence of; null when it does not repeat. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "series_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private TaskSeries series;

    /** 1, 2, 3 ... within the series; null outside one. */
    @Column(name = "occurrence")
    private Integer occurrence;

    /** This occurrence already wrote the one after it, so completing it again writes nothing. */
    @Column(name = "next_created", nullable = false)
    private boolean nextCreated;

    /** When it was done; null while it is still open. */
    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
