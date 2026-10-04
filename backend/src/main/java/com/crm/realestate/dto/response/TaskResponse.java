package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private Long id;
    private String title;
    private String note;
    private LocalDateTime dueAt;
    /** Null while the task is open. */
    private LocalDateTime completedAt;
    private Long assigneeId;
    private String assigneeName;
    /** Null once the author's account is closed. */
    private Long createdById;
    private String createdByName;
    private Long clientId;
    private String clientName;
    private Long dealId;
    private String dealTitle;
    /** The series this task is an occurrence of, kept after the series is stopped; null otherwise. */
    private Long seriesId;
    /** 1, 2, 3 ... within the series. */
    private Integer occurrence;
    /** How it repeats; null when it does not, or no longer does. */
    private TaskRepeatResponse repeat;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
