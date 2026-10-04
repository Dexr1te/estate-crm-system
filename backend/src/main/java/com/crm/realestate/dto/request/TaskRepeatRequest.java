package com.crm.realestate.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * How a task repeats. {@code frequency} is NONE, DAILY, WEEKLY, MONTHLY, QUARTERLY or YEARLY;
 * {@code weekdays} (MONDAY ... SUNDAY) counts for WEEKLY only and defaults to the due day's
 * weekday. At most one end: the last day an occurrence may fall on, or how many there are.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskRepeatRequest {

    private String frequency;

    private List<String> weekdays;

    private LocalDate until;

    private Integer count;
}
