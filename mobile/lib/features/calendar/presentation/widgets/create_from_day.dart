import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum CalendarCreateKind { meeting, task }

/// `yyyy-MM-dd`, the `date` the meeting form reads from its route.
String calendarDateParam(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// A new task on [day]: this evening when it is today, else ten o'clock.
DateTime taskDueOn(DateTime day, DateTime now) {
  if (isSameDay(day, now)) {
    final evening = DateTime(now.year, now.month, now.day, 18);
    return evening.isAfter(now) ? evening : now.add(const Duration(hours: 1));
  }
  return DateTime(day.year, day.month, day.day, 10);
}

Future<CalendarCreateKind?> showCreateFromDaySheet(
    BuildContext context, DateTime day) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return showAppBottomSheet<CalendarCreateKind>(
    context,
    title: l10n.calendarAddTo(formatWeekdayDate(day, locale)),
    builder: (sheet) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Choice(
          key: const ValueKey('calendar-create-meeting'),
          icon: Icons.event_outlined,
          title: l10n.calendarAddMeeting,
          subtitle: l10n.calendarAddMeetingHint,
          onTap: () => Navigator.pop(sheet, CalendarCreateKind.meeting),
        ),
        const SizedBox(height: 9),
        _Choice(
          key: const ValueKey('calendar-create-task'),
          icon: Icons.task_alt_rounded,
          title: l10n.calendarAddTask,
          subtitle: l10n.calendarAddTaskHint,
          onTap: () => Navigator.pop(sheet, CalendarCreateKind.task),
        ),
      ],
    ),
  );
}

class _Choice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Choice({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: t.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        color: t.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: t.textHint),
        ],
      ),
    );
  }
}
