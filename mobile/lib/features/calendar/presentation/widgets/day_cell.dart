import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool today;
  final List<CalendarMarker> markers;
  final int entries;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DayCell({
    super.key,
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.today,
    required this.markers,
    required this.entries,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = '${DateFormat.MMMMEEEEd(locale).format(day)}, '
        '${l10n.calendarDayEntries(entries)}';
    final numberColor = selected
        ? t.onPrimary
        : today
            ? t.primary
            : inMonth
                ? t.textPrimary
                : t.textHint;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('calendar-day-${day.year}-${day.month}-${day.day}'),
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: selected ? t.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: today && !selected
                        ? Border.all(color: t.primary, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    '${day.day}',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: selected || today
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: numberColor),
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < markers.length; i++) ...[
                        if (i > 0) const SizedBox(width: 2),
                        MarkerDot(marker: markers[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MarkerDot extends StatelessWidget {
  final CalendarMarker marker;
  final double size;
  const MarkerDot({super.key, required this.marker, this.size = 5});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isTask = marker == CalendarMarker.task ||
        marker == CalendarMarker.overdueTask ||
        marker == CalendarMarker.doneTask;
    final color = switch (marker) {
      CalendarMarker.meeting => t.primary,
      CalendarMarker.viewing => t.statusText(StatusHue.lead),
      CalendarMarker.task => t.textSecondary,
      CalendarMarker.overdueTask => t.statusText(StatusHue.danger),
      CalendarMarker.doneTask => t.textHint,
    };
    return Container(
      key: ValueKey('calendar-marker-${marker.name}'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: marker == CalendarMarker.doneTask ? null : color,
        border: marker == CalendarMarker.doneTask
            ? Border.all(color: color, width: 1)
            : null,
        shape: isTask ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isTask ? BorderRadius.circular(1.5) : null,
      ),
    );
  }
}
