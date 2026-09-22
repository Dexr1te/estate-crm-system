package com.crm.realestate.entity;

import jakarta.persistence.*;
import com.crm.realestate.enums.ViewingOutcome;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Entity
@Table(name = "meetings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Meeting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String description;

    @Column(nullable = false)
    private LocalDateTime scheduledAt;

    private String location;

    private boolean completed;

    /** How the showing went, once somebody has said. Null until then. */
    @Enumerated(EnumType.STRING)
    @Column(name = "outcome", length = 20)
    private ViewingOutcome outcome;

    /** What the buyer said in their own words — "too dark", "the road is loud". */
    @Column(name = "outcome_note", columnDefinition = "TEXT")
    private String outcomeNote;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id")
    private Deal deal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private User agent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    /**
     * The listing being shown, when this meeting is a viewing.
     *
     * <p>The showing outlives the listing: {@code SET NULL} rather than a cascade, so taking a
     * flat off the books does not erase the record of having shown it. Declared here as well as in
     * V20 so a schema generated from the entities — the test database is one — behaves the way the
     * migrated one does.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private Property property;

    // The agency this record belongs to. See ScopeService for what it decides.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}