import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/day_cell.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final DateTime now;
  final int firstDayOfWeekIndex;
  final bool collapsed;
  final CalendarPage? page;
  final ValueChanged<DateTime> onTap;
  final ValueChanged<DateTime> onLongPress;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.now,
    required this.firstDayOfWeekIndex,
    required this.page,
    required this.onTap,
    required this.onLongPress,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = collapsed
        ? weekDays(selectedDay, firstDayOfWeekIndex)
        : monthGridDays(month, firstDayOfWeekIndex);
    final names = DateFormat.E(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final d in days.take(7))
              Expanded(
                child: Text(
                  names.format(d),
                  key: const ValueKey('calendar-weekday'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textHint),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var row = 0; row < days.length ~/ 7; row++)
          Row(
            children: [
              for (final d in days.skip(row * 7).take(7))
                Expanded(
                  child: DayCell(
                    day: d,
                    inMonth: collapsed || d.month == month.month,
                    selected: isSameDay(d, selectedDay),
                    today: isSameDay(d, now),
                    markers: page?.markersOn(d, now) ?? const [],
                    entries: page?.countOn(d) ?? 0,
                    onTap: () => onTap(d),
                    onLongPress: () => onLongPress(d),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final items = [
      (CalendarMarker.meeting, l10n.calendarLegendMeeting),
      (CalendarMarker.viewing, l10n.calendarLegendViewing),
      (CalendarMarker.task, l10n.calendarLegendTask),
      (CalendarMarker.overdueTask, l10n.calendarLegendOverdue),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (marker, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MarkerDot(marker: marker, size: 7),
              const SizedBox(width: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    color: t.textSecondary),
              ),
            ],
          ),
      ],
    );
  }
}
