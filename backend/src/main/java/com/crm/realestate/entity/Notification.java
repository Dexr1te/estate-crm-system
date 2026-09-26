package com.crm.realestate.entity;

import com.crm.realestate.enums.NotificationType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * Something that happened which the recipient did not do themselves.
 *
 * <p>No sentence is kept: the app renders one in the reader's language from {@link #type} and the
 * values in {@link #payload}. The delete rules are declared here as well as in V30 so a schema
 * generated from the entities — the test database is one — behaves the way the migrated one does.
 */
@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipient_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User recipient;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private NotificationType type;

    /** The task, deal, listing, request or agent it is about, read according to {@link #type}. */
    @Column(name = "target_id")
    private Long targetId;

    /** A small JSON object of the names, counts and prices the sentence needs. */
    @Column(columnDefinition = "TEXT")
    private String payload;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
