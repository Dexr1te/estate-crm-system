package com.crm.realestate.entity;

import com.crm.realestate.enums.ExpenseCategory;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Money the agency spent on one listing: the photographer, an ad, staging (V59).
 *
 * <p>It lives in the listing's agency and is seen as the listing is. The cascades are declared
 * here as well as in V59 so the schema generated for tests behaves the way the migrated one does.
 */
@Entity
@Table(name = "property_expenses",
        indexes = {
                @Index(name = "idx_property_expenses_property", columnList = "property_id, spent_on"),
                @Index(name = "idx_property_expenses_team_spent", columnList = "team_id, spent_on")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyExpense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Property property;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ExpenseCategory category;

    /** In the agency's currency, above zero. */
    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    /** The day it was paid, in the agency's calendar. */
    @Column(name = "spent_on", nullable = false)
    private LocalDate spentOn;

    @Column(length = 500)
    private String note;

    /** Who recorded it; null once their account is gone. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User createdBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
