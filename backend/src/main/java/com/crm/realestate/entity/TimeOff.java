package com.crm.realestate.entity;

import com.crm.realestate.enums.TimeOffKind;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Somebody away from the agency for a few days, and the colleague covering for them.
 *
 * <p>The days are calendar dates in the agency's zone, the first and the last both inclusive. The
 * delete rules are declared here as well as in V54 so the schema generated for tests behaves the
 * way the migrated one does.
 */
@Entity
@Table(name = "time_off",
        indexes = {
                @Index(name = "idx_time_off_team_dates", columnList = "team_id, start_date, end_date"),
                @Index(name = "idx_time_off_user_dates", columnList = "user_id, start_date, end_date")
        })
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TimeOff {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Team team;

    /** Who is away. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;

    /** Who covers for them, or nobody. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cover_id")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User cover;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TimeOffKind kind;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(length = 1000)
    private String note;

    /** Who wrote it down: the person, or a manager on their behalf. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    @OnDelete(action = OnDeleteAction.SET_NULL)
    private User createdBy;

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

    /** Whether {@code day} is one of the days away. */
    public boolean covers(LocalDate day) {
        return !day.isBefore(startDate) && !day.isAfter(endDate);
    }
}
