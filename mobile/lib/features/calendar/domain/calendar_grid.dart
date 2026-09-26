import 'package:real_estate_crm/core/models/models.dart';

DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Where [day] falls in a week that starts on [firstDayOfWeekIndex], counted
/// the way `MaterialLocalizations.firstDayOfWeekIndex` counts: 0 is Sunday.
int weekColumn(DateTime day, int firstDayOfWeekIndex) =>
    (day.weekday % 7 - firstDayOfWeekIndex + 7) % 7;

/// The days a month page shows: whole weeks, from the one holding the 1st to
/// the one holding the last day, so four to six rows. Built from calendar
/// fields rather than by adding durations, so a daylight-saving change never
/// shifts a day.
List<DateTime> monthGridDays(DateTime month, int firstDayOfWeekIndex) {
  final first = DateTime(month.year, month.month);
  final lead = weekColumn(first, firstDayOfWeekIndex);
  final length = DateTime(month.year, month.month + 1, 0).day;
  final cells = ((lead + length) / 7).ceil() * 7;
  return [
    for (var i = 0; i < cells; i++)
      DateTime(first.year, first.month, 1 - lead + i),
  ];
}

/// The seven days of the week holding [day].
List<DateTime> weekDays(DateTime day, int firstDayOfWeekIndex) {
  final start = day.day - weekColumn(day, firstDayOfWeekIndex);
  return [
    for (var i = 0; i < 7; i++) DateTime(day.year, day.month, start + i),
  ];
}

/// The `[from, to)` a month page asks the server for: the whole grid, so the
/// spill-over days from the months either side carry their markers too.
(DateTime, DateTime) monthGridRange(DateTime month, int firstDayOfWeekIndex) {
  final days = monthGridDays(month, firstDayOfWeekIndex);
  final last = days.last;
  return (days.first, DateTime(last.year, last.month, last.day + 1));
}

enum CalendarMarker { meeting, viewing, task, overdueTask, doneTask }

/// One month page of meetings and tasks, read once and kept.
class CalendarPage {
  final List<MeetingResponse> meetings;
  final List<TaskResponse> tasks;

  const CalendarPage({this.meetings = const [], this.tasks = const []});

  List<MeetingResponse> meetingsOn(DateTime day) =>
      meetings.where((m) => _same(m.scheduledAt, day)).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<TaskResponse> tasksOn(DateTime day) =>
      tasks.where((t) => _same(t.dueAt, day)).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  int countOn(DateTime day) => meetingsOn(day).length + tasksOn(day).length;

  /// At most three markers, in the order things happen that day.
  List<CalendarMarker> markersOn(DateTime day, DateTime now) {
    final timed = <(DateTime, CalendarMarker)>[
      for (final m in meetingsOn(day))
        (
          m.scheduledAt,
          m.propertyId != null ? CalendarMarker.viewing : CalendarMarker.meeting
        ),
      for (final t in tasksOn(day))
        (
          t.dueAt,
          t.isDone
              ? CalendarMarker.doneTask
              : t.dueAt.isBefore(now)
                  ? CalendarMarker.overdueTask
                  : CalendarMarker.task
        ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return timed.take(3).map((e) => e.$2).toList();
  }

  CalendarPage replaceTask(TaskResponse task) => CalendarPage(
        meetings: meetings,
        tasks: [for (final t in tasks) t.id == task.id ? task : t],
      );

  static bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
