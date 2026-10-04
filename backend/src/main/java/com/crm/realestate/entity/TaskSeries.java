package com.crm.realestate.entity;

import com.crm.realestate.enums.RepeatFrequency;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * The rule a repeating task follows. It is reached only through its tasks, which carry the team
 * and the assignee, so it has neither of its own. See V52 for what each column means.
 */
@Entity
@Table(name = "task_series")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskSeries {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private RepeatFrequency frequency;

    /** WEEKLY only: a bit per day, Monday = 1 ... Sunday = 64. */
    @Column(name = "weekdays")
    private Integer weekdays;

    @Column(name = "anchor_at", nullable = false)
    private LocalDateTime anchorAt;

    /** The occurrence the end "after N times" counts from. */
    @Column(name = "count_from", nullable = false)
    @Builder.Default
    private Integer countFrom = 1;

    @Column(name = "until_date")
    private LocalDate untilDate;

    @Column(name = "max_occurrences")
    private Integer maxOccurrences;

    /** "Stop repeating": set, nothing more is written. */
    @Column(name = "stopped_at")
    private LocalDateTime stoppedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public boolean isActive() {
        return stoppedAt == null;
    }

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
