package com.crm.realestate.entity;

import com.crm.realestate.enums.PartnerHandoffStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * A client the agency sent to one of its partners: to a broker for a mortgage, to a notary for the
 * papers. It belongs to the client and goes with the card; a partner with hand-offs cannot be
 * deleted (V53).
 */
@Entity
@Table(name = "partner_handoffs",
        indexes = {
                @Index(name = "idx_partner_handoffs_client", columnList = "client_id"),
                @Index(name = "idx_partner_handoffs_partner", columnList = "partner_id")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerHandoff {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "partner_id", nullable = false)
    private Partner partner;

    /** Who sent them; forgotten with their account. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sent_by_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User sentBy;

    @Column(name = "sent_on", nullable = false)
    private LocalDate sentOn;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    @Builder.Default
    private PartnerHandoffStatus status = PartnerHandoffStatus.SENT;

    @Column(length = 500)
    private String note;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (status == null) {
            status = PartnerHandoffStatus.SENT;
        }
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
