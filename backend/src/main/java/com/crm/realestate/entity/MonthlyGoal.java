package com.crm.realestate.entity;

import com.crm.realestate.enums.GoalSource;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * A month's target for one agent, or for the whole agency when {@link #agent} is null. Only the
 * target is stored; progress is counted from the deals won that month. See V43.
 */
@Entity
@Table(name = "monthly_goals",
        indexes = @Index(name = "idx_monthly_goals_team_month", columnList = "team_id, month_start"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MonthlyGoal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    /** Whose target it is; null for the agency-wide one. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User agent;

    /** The first day of the month. */
    @Column(name = "month_start", nullable = false)
    private LocalDate monthStart;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private GoalSource source;

    @Column(name = "commission_target", precision = 15, scale = 2)
    private BigDecimal commissionTarget;

    @Column(name = "deals_target")
    private Integer dealsTarget;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
