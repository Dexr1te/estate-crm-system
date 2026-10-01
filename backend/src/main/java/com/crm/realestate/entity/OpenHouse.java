package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * A listing held open for a few hours, and the agent holding it.
 *
 * <p>It belongs to the listing and goes with it. It lives in the listing's agency, and the whole
 * agency sees it as it sees the listing; the calendar narrows it by data scope like any meeting.
 * The cascades are declared here as well as in V44 so the schema generated for tests behaves the
 * way the migrated one does.
 */
@Entity
@Table(name = "open_houses",
        indexes = {
                @Index(name = "idx_open_houses_property", columnList = "property_id, starts_at"),
                @Index(name = "idx_open_houses_team_start", columnList = "team_id, starts_at")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OpenHouse {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    /** Who holds it. Named {@code agent} so the shared scope rules apply as they are. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User agent;

    @Column(name = "starts_at", nullable = false)
    private LocalDateTime startsAt;

    @Column(name = "ends_at", nullable = false)
    private LocalDateTime endsAt;

    @Column(length = 1000)
    private String note;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
