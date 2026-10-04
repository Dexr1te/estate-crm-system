package com.crm.realestate.entity;

import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.enums.ReferralFeeType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Someone outside the agency it works with: a mortgage broker, a notary, an appraiser, a developer,
 * another agency. The whole agency shares its partners; whoever added one, a manager or an admin
 * may change it. See {@code V53__partners.sql}.
 *
 * <p>The referral fee is optional, and both halves come together: a type and a value. It is what
 * the agency owes the partner on each won deal of a client the partner sent (see
 * {@code ReferralFee}).
 */
@Entity
@Table(name = "partners",
        indexes = @Index(name = "idx_partners_team_name", columnList = "team_id, name"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@org.hibernate.annotations.BatchSize(size = 100)
public class Partner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    /** Who added it; forgotten with their account when nobody takes their records over. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User createdBy;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(length = 120)
    private String company;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PartnerKind kind;

    @Column(length = 40)
    private String phone;

    @Column(length = 255)
    private String email;

    @Column(length = 1000)
    private String note;

    @Enumerated(EnumType.STRING)
    @Column(name = "fee_type", length = 10)
    private ReferralFeeType feeType;

    /** A percentage of the commission for {@code PERCENT}, an amount for {@code FIXED}. */
    @Column(name = "fee_value", precision = 15, scale = 2)
    private BigDecimal feeValue;

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
