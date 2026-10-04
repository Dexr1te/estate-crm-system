package com.crm.realestate.service;

import com.crm.realestate.entity.TaskSeries;
import com.crm.realestate.enums.RepeatFrequency;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.EnumSet;
import java.util.Optional;
import java.util.Set;
import java.util.function.LongFunction;

/**
 * Where a repeat rule puts the next occurrence. Pure arithmetic over dates, no database.
 *
 * <p>A rule is a sequence of slots counted from its anchor: the anchor plus k days, k weeks, k
 * months, 3k months or 12k months, and for a weekly rule every chosen weekday from the anchor on,
 * at the anchor's time of day. Months are always added to the anchor, never to the previous slot,
 * so a series anchored on the 31st clamps to the last day of a shorter month and returns to the
 * 31st after it, and one anchored on 29 February falls on the 28th until the next leap year.
 *
 * <p>The next occurrence is the first slot after the completed one's scheduled due time, not
 * after the moment it was done: finishing Monday's weekly call on Wednesday still leaves next
 * Monday's in place. It is never in the past, though: when the slots after the due time have
 * already gone by (a daily task ticked off a week late), the series skips forward to the first
 * slot after now instead of writing a backlog of overdue copies. Skipped slots are not
 * occurrences and do not count towards an end "after N times".
 */
public final class RepeatSchedule {

    private RepeatSchedule() {
    }

    /**
     * The due time of the occurrence after {@code occurrence}, which was due {@code scheduled},
     * or empty when the series has ended by then.
     */
    public static Optional<LocalDateTime> nextDue(TaskSeries series, LocalDateTime scheduled, int occurrence,
                                                  LocalDateTime now) {
        int next = occurrence + 1;
        if (series.getMaxOccurrences() != null
                && next - series.getCountFrom() + 1 > series.getMaxOccurrences()) {
            return Optional.empty();
        }
        LocalDateTime after = scheduled.isAfter(now) ? scheduled : now;
        LocalDateTime slot = slotAfter(series.getFrequency(), weekdays(series.getWeekdays()),
                series.getAnchorAt(), after);
        if (series.getUntilDate() != null && slot.toLocalDate().isAfter(series.getUntilDate())) {
            return Optional.empty();
        }
        return Optional.of(slot);
    }

    /** The first slot of the rule strictly after {@code after}. */
    public static LocalDateTime slotAfter(RepeatFrequency frequency, Set<DayOfWeek> weekdays,
                                          LocalDateTime anchor, LocalDateTime after) {
        return switch (frequency) {
            case DAILY -> stepped(anchor, after, anchor::plusDays, ChronoUnit.DAYS.between(anchor, after));
            case WEEKLY -> weekly(weekdays, anchor, after);
            case MONTHLY -> stepped(anchor, after, anchor::plusMonths, ChronoUnit.MONTHS.between(anchor, after));
            case QUARTERLY -> stepped(anchor, after, k -> anchor.plusMonths(3 * k),
                    ChronoUnit.MONTHS.between(anchor, after) / 3);
            case YEARLY -> stepped(anchor, after, k -> anchor.plusMonths(12 * k),
                    ChronoUnit.MONTHS.between(anchor, after) / 12);
            case NONE -> throw new IllegalArgumentException("A task that does not repeat has no next slot");
        };
    }

    /** Slot k is {@code slot(k)}; {@code estimate} is about how many whole steps fit before {@code after}. */
    private static LocalDateTime stepped(LocalDateTime anchor, LocalDateTime after,
                                         LongFunction<LocalDateTime> slot, long estimate) {
        if (anchor.isAfter(after)) {
            return anchor;
        }
        long k = Math.max(0, estimate - 1);
        LocalDateTime candidate = slot.apply(k);
        while (!candidate.isAfter(after)) {
            candidate = slot.apply(++k);
        }
        return candidate;
    }

    private static LocalDateTime weekly(Set<DayOfWeek> weekdays, LocalDateTime anchor, LocalDateTime after) {
        Set<DayOfWeek> days = weekdays.isEmpty() ? EnumSet.of(anchor.getDayOfWeek()) : weekdays;
        LocalDate day = after.toLocalDate().isAfter(anchor.toLocalDate()) ? after.toLocalDate() : anchor.toLocalDate();
        while (true) {
            LocalDateTime candidate = day.atTime(anchor.toLocalTime());
            if (candidate.isAfter(after) && !candidate.isBefore(anchor) && days.contains(day.getDayOfWeek())) {
                return candidate;
            }
            day = day.plusDays(1);
        }
    }

    /** Monday = 1, Tuesday = 2 ... Sunday = 64. */
    public static int mask(Set<DayOfWeek> days) {
        int mask = 0;
        for (DayOfWeek day : days) {
            mask |= 1 << (day.getValue() - 1);
        }
        return mask;
    }

    public static Set<DayOfWeek> weekdays(Integer mask) {
        Set<DayOfWeek> days = EnumSet.noneOf(DayOfWeek.class);
        if (mask != null) {
            for (DayOfWeek day : DayOfWeek.values()) {
                if ((mask & (1 << (day.getValue() - 1))) != 0) {
                    days.add(day);
                }
            }
        }
        return days;
    }
}
