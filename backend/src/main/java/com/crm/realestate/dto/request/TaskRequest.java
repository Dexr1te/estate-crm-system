package com.crm.realestate.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * A task to create or change. The assignee defaults to whoever writes it; only a manager or an
 * admin may name somebody else.
 */
@Data
public class TaskRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must be at most 200 characters")
    private String title;

    @Size(max = 2000, message = "Note must be at most 2000 characters")
    private String note;

    @NotNull(message = "Due time is required")
    private LocalDateTime dueAt;

    private Long clientId;

    private Long dealId;

    private Long assigneeId;
}
