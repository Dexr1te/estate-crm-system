package com.crm.realestate.service;

import com.crm.realestate.entity.TaskSeries;
import com.crm.realestate.enums.RepeatFrequency;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Where a repeat rule puts the next occurrence: the calendar's awkward corners, with "now" held
 * fixed so that "never in the past" can be pinned down.
 */
class RepeatScheduleTest {

    /** Long before every due time below, so the scheduled due time decides. */
    private static final LocalDateTime LONG_AGO = LocalDateTime.of(2000, 1, 1, 0, 0);

    @Test
    @DisplayName("every month from the 31st: the last day of a shorter month, then the 31st again")
    void monthlyFromThe31st() {
        TaskSeries series = series(RepeatFrequency.MONTHLY, at(2031, 1, 31));

        assertThat(run(series, 5)).containsExactly(
                at(2031, 1, 31), at(2031, 2, 28), at(2031, 3, 31), at(2031, 4, 30), at(2031, 5, 31));
    }

    @Test
    @DisplayName("every month from 31 January in a leap year lands on 29 February")
    void monthlyLeapFebruary() {
        TaskSeries series = series(RepeatFrequency.MONTHLY, at(2032, 1, 31));

        assertThat(run(series, 3)).containsExactly(at(2032, 1, 31), at(2032, 2, 29), at(2032, 3, 31));
    }

    @Test
    @DisplayName("every year from 29 February: the 28th in ordinary years, the 29th in the next leap year")
    void yearlyFromLeapDay() {
        TaskSeries series = series(RepeatFrequency.YEARLY, at(2032, 2, 29));

        assertThat(run(series, 5)).containsExactly(
                at(2032, 2, 29), at(2033, 2, 28), at(2034, 2, 28), at(2035, 2, 28), at(2036, 2, 29));
    }

    @Test
    @DisplayName("every quarter from 30 November: 28 February, 30 May, 30 August")
    void quarterly() {
        TaskSeries series = series(RepeatFrequency.QUARTERLY, at(2030, 11, 30));

        assertThat(run(series, 4)).containsExactly(
                at(2030, 11, 30), at(2031, 2, 28), at(2031, 5, 30), at(2031, 8, 30));
    }

    @Test
    @DisplayName("every week on Monday and Thursday, from a Monday")
    void weeklyOnSeveralDays() {
        // 2031-03-03 is a Monday.
        TaskSeries series = series(RepeatFrequency.WEEKLY, at(2031, 3, 3));
        series.setWeekdays(RepeatSchedule.mask(EnumSet.of(DayOfWeek.MONDAY, DayOfWeek.THURSDAY)));

        assertThat(run(series, 5)).containsExactly(
                at(2031, 3, 3), at(2031, 3, 6), at(2031, 3, 10), at(2031, 3, 13), at(2031, 3, 17));
    }

    @Test
    @DisplayName("a weekly rule started on a day it does not name goes on to the first day it does")
    void weeklyFromAnOffDay() {
        // 2031-03-05 is a Wednesday.
        TaskSeries series = series(RepeatFrequency.WEEKLY, at(2031, 3, 5));
        series.setWeekdays(RepeatSchedule.mask(EnumSet.of(DayOfWeek.MONDAY)));

        assertThat(next(series, at(2031, 3, 5), 1, LONG_AGO)).contains(at(2031, 3, 10));
    }

    @Test
    @DisplayName("every day, keeping the time of day")
    void daily() {
        TaskSeries series = series(RepeatFrequency.DAILY, at(2031, 12, 31));

        assertThat(run(series, 3)).containsExactly(at(2031, 12, 31), at(2032, 1, 1), at(2032, 1, 2));
    }

    @Test
    @DisplayName("the next is counted from the due time, not from when it was done, but never falls in the past")
    void neverInThePast() {
        TaskSeries series = series(RepeatFrequency.DAILY, at(2031, 3, 3));

        // Done early: tomorrow's slot after the due time, not after the moment it was ticked.
        assertThat(next(series, at(2031, 3, 3), 1, LocalDateTime.of(2031, 3, 1, 8, 0)))
                .contains(at(2031, 3, 4));
        // Done a week late: the first slot after now, not seven overdue copies.
        assertThat(next(series, at(2031, 3, 3), 1, LocalDateTime.of(2031, 3, 10, 11, 0)))
                .contains(at(2031, 3, 11));
        // Done late the same day, before the next slot: that slot still stands.
        assertThat(next(series, at(2031, 3, 3), 1, LocalDateTime.of(2031, 3, 3, 18, 0)))
                .contains(at(2031, 3, 4));
    }

    @Test
    @DisplayName("an end after N times counts from where it was set; skipped slots do not count")
    void endsAfterCount() {
        TaskSeries series = series(RepeatFrequency.WEEKLY, at(2031, 3, 3));
        series.setWeekdays(RepeatSchedule.mask(EnumSet.of(DayOfWeek.MONDAY)));
        series.setMaxOccurrences(3);

        assertThat(run(series, 10)).hasSize(3);

        series.setCountFrom(4);
        assertThat(next(series, at(2031, 3, 3), 5, LONG_AGO)).isPresent();
        assertThat(next(series, at(2031, 3, 3), 6, LONG_AGO)).isEmpty();
    }

    @Test
    @DisplayName("an end on a day takes the occurrence on that day and nothing after it")
    void endsOnADay() {
        TaskSeries series = series(RepeatFrequency.DAILY, at(2031, 3, 3));
        series.setUntilDate(LocalDate.of(2031, 3, 5));

        assertThat(run(series, 10)).containsExactly(at(2031, 3, 3), at(2031, 3, 4), at(2031, 3, 5));
    }

    @Test
    @DisplayName("weekday masks go both ways, Monday first")
    void masks() {
        EnumSet<DayOfWeek> days = EnumSet.of(DayOfWeek.MONDAY, DayOfWeek.THURSDAY, DayOfWeek.SUNDAY);

        assertThat(RepeatSchedule.mask(days)).isEqualTo(1 + 8 + 64);
        assertThat(RepeatSchedule.weekdays(73)).containsExactly(
                DayOfWeek.MONDAY, DayOfWeek.THURSDAY, DayOfWeek.SUNDAY);
        assertThat(RepeatSchedule.weekdays(null)).isEmpty();
    }

    private static List<LocalDateTime> run(TaskSeries series, int max) {
        List<LocalDateTime> dues = new ArrayList<>();
        LocalDateTime due = series.getAnchorAt();
        int occurrence = 1;
        dues.add(due);
        while (dues.size() < max) {
            Optional<LocalDateTime> next = next(series, due, occurrence, LONG_AGO);
            if (next.isEmpty()) {
                break;
            }
            due = next.get();
            occurrence++;
            dues.add(due);
        }
        return dues;
    }

    private static Optional<LocalDateTime> next(TaskSeries series, LocalDateTime due, int occurrence,
                                                LocalDateTime now) {
        return RepeatSchedule.nextDue(series, due, occurrence, now);
    }

    private static TaskSeries series(RepeatFrequency frequency, LocalDateTime anchor) {
        return TaskSeries.builder().frequency(frequency).anchorAt(anchor).countFrom(1).build();
    }

    private static LocalDateTime at(int year, int month, int day) {
        return LocalDateTime.of(year, month, day, 9, 30);
    }
}
