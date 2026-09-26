package com.crm.realestate.entity;

import com.crm.realestate.enums.DealStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

/**
 * One move of a deal between stages, or its creation ({@code fromStatus} null).
 *
 * <p>A deal only holds its current status, so without these rows nobody could tell whether a lost
 * deal ever got as far as negotiation, or how long a won one took. The row goes with its deal and
 * outlives whoever made the move.
 */
@Entity
@Table(name = "deal_status_changes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DealStatusChange {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deal_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Deal deal;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_status", length = 32)
    private DealStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_status", nullable = false, length = 32)
    private DealStatus toStatus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User changedBy;

    @Column(name = "changed_at", nullable = false, updatable = false)
    private LocalDateTime changedAt;

    @PrePersist
    void onCreate() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}
