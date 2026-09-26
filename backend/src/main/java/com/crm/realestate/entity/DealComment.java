package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One line in the discussion of a deal, and who wrote it.
 *
 * <p>The discussion belongs to the deal, so it goes when the deal goes. It does not belong to the
 * person who wrote it: when an account is closed the comment stays, forgets the account and keeps
 * the name it was written under — the same rule as a client's history.
 *
 * <p>Both rules are declared here as well as in V34 so a schema generated from the entities — the
 * test database is one — behaves the way the migrated one does.
 */
@Entity
@Table(name = "deal_comments",
        indexes = @Index(name = "idx_deal_comments_deal", columnList = "deal_id, id"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DealComment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Deal deal;

    // The agency this record belongs to — always the deal's. Access is decided by the deal.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User author;

    /** Who wrote it, as they were called at the time — what is left once the account is gone. */
    @Column(name = "author_name")
    private String authorName;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /** Null until the author corrects the text. */
    @Column(name = "edited_at")
    private LocalDateTime editedAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
