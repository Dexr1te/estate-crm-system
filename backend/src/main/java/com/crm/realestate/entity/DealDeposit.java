package com.crm.realestate.entity;

import com.crm.realestate.enums.DepositHolder;
import com.crm.realestate.enums.DepositOutcome;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Money a buyer put down on a deal, who keeps it, how long the listing is held for them, and how it
 * ended. Active while {@link #outcome} is null (V46). The cascade rules are declared here as well so
 * a schema generated from the entities — the test database is one — behaves like the migrated one.
 */
@Entity
@Table(name = "deal_deposits", indexes = {
        @Index(name = "idx_deal_deposits_deal", columnList = "deal_id, outcome"),
        @Index(name = "idx_deal_deposits_hold", columnList = "team_id, hold_until")})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DealDeposit {

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

    /** In the agency's currency. */
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "received_on", nullable = false)
    private LocalDate receivedOn;

    /** The last day the listing is held for this buyer. */
    @Column(name = "hold_until", nullable = false)
    private LocalDate holdUntil;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private DepositHolder holder;

    @Column(length = 500)
    private String note;

    /** Null while the deposit is active. */
    @Enumerated(EnumType.STRING)
    @Column(length = 16)
    private DepositOutcome outcome;

    /** The day it ended; set exactly when {@link #outcome} is. */
    @Column(name = "closed_on")
    private LocalDate closedOn;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recorded_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User recordedBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public boolean isActive() {
        return outcome == null;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
