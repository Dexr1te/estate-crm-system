package com.crm.realestate.entity;

import com.crm.realestate.enums.ActivityType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One touch with a client — a call, a message, an email or a note — and who made it.
 *
 * <p>The history belongs to the client, so it goes when the client goes. It does not belong to the
 * person who wrote it: when an account is closed the entry stays, forgets the account, and keeps
 * the name it was written under. Handing it to a successor, as deals and meetings are, would put
 * words in the successor's mouth.
 *
 * <p>Both rules are declared here as well as in V25 so a schema generated from the entities — the
 * test database is one — behaves the way the migrated one does.
 */
@Entity
@Table(name = "client_activities",
        indexes = @Index(name = "idx_client_activities_client", columnList = "client_id, occurred_at DESC"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Client client;

    // The agency this record belongs to — always the client's. Access is decided by the client.
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ActivityType type;

    @Column(columnDefinition = "TEXT")
    private String note;

    /** When the call or message happened, which is not always when it was written down. */
    @Column(name = "occurred_at", nullable = false)
    private LocalDateTime occurredAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        if (occurredAt == null) {
            occurredAt = createdAt;
        }
    }
}
