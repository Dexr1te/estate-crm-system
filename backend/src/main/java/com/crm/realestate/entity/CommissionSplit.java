package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Someone the deal's agent shares the commission with: a colleague from the deal's agency, or an
 * outside co-broker known only by name (V55). The deal's agent has no row and holds whatever the
 * rows leave. Once the deal is won the agency pays the share out, and says so here (V58). The
 * cascade rules are declared here as well so a schema generated from the entities — the test
 * database is one — behaves like the migrated one.
 */
@Entity
@Table(name = "commission_splits",
        uniqueConstraints = @UniqueConstraint(name = "uq_commission_splits_person",
                columnNames = {"deal_id", "user_id"}),
        indexes = {
                @Index(name = "idx_commission_splits_deal", columnList = "deal_id"),
                @Index(name = "idx_commission_splits_user", columnList = "user_id"),
                @Index(name = "idx_commission_splits_paid_by", columnList = "paid_by")})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommissionSplit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Deal deal;

    /** A colleague; null for an outside co-broker. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;

    @Column(name = "co_broker_name")
    private String coBrokerName;

    @Column(name = "co_broker_agency")
    private String coBrokerAgency;

    /** Of the deal's commission, above 0 and at most 100. */
    @Column(name = "share_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal sharePercent;

    @Column(nullable = false)
    private int position;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /** When the agency paid the share out; null while it is still owed (V58). */
    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    /** Who marked it paid; null once that account is closed. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paid_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User paidBy;

    /** What the manager wrote down with the payout, at most 500 characters. */
    @Column(name = "payout_note", length = 500)
    private String payoutNote;

    public boolean isPaid() {
        return paidAt != null;
    }

    /** Back to owed: no payout, nobody who made it, no note. */
    public void clearPayout() {
        paidAt = null;
        paidBy = null;
        payoutNote = null;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
