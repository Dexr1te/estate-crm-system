import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum TaskQuickDue { todayEvening, tomorrowMorning, inThreeDays }

DateTime quickDueAt(TaskQuickDue quick, DateTime now) {
  switch (quick) {
    case TaskQuickDue.todayEvening:
      final evening = DateTime(now.year, now.month, now.day, 18);
      return evening.isAfter(now) ? evening : now.add(const Duration(hours: 1));
    case TaskQuickDue.tomorrowMorning:
      return DateTime(now.year, now.month, now.day + 1, 9);
    case TaskQuickDue.inThreeDays:
      return DateTime(now.year, now.month, now.day + 3, 10);
  }
}

String quickDueLabel(AppLocalizations l10n, TaskQuickDue quick) {
  switch (quick) {
    case TaskQuickDue.todayEvening:
      return l10n.tasksQuickTodayEvening;
    case TaskQuickDue.tomorrowMorning:
      return l10n.tasksQuickTomorrowMorning;
    case TaskQuickDue.inThreeDays:
      return l10n.tasksQuickInThreeDays;
  }
}

bool isOverdue(TaskResponse task, DateTime now) =>
    !task.isDone && task.dueAt.isBefore(now);

String dueLabel(
    AppLocalizations l10n, DateTime due, DateTime now, String locale) {
  final time = formatTimeOfDay(due);
  final day = DateTime(due.year, due.month, due.day);
  final today = DateTime(now.year, now.month, now.day);
  final offset = day.difference(today).inDays;
  if (offset == 0) return l10n.tasksDueToday(time);
  if (offset == 1) return l10n.tasksDueTomorrow(time);
  return '${formatDayMonth(due, locale)}, $time';
}
