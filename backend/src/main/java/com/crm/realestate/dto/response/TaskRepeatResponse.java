package com.crm.realestate.dto.response;

import com.crm.realestate.enums.RepeatFrequency;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * The rule a repeating task follows. {@code anchorAt} is the due time the pattern counts from, so
 * an app can say "every month on the 31st" while this occurrence falls on the 30th.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskRepeatResponse {
    private RepeatFrequency frequency;
    /** WEEKLY only, Monday first; empty otherwise. */
    private List<DayOfWeek> weekdays;
    private LocalDate until;
    private Integer count;
    private LocalDateTime anchorAt;
}
