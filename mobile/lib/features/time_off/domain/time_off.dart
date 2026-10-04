import 'package:real_estate_crm/core/models/models.dart';

/// How far ahead the team's "who's out" list looks.
const kTimeOffTeamWindowDays = 90;

/// How far back "my time off" shows what is over, and how far ahead it looks;
/// together within the year the server answers for at once.
const kTimeOffPastDays = 60;
const kTimeOffAheadDays = 300;

/// The longest absence the server takes, in days, first and last included.
const kTimeOffMaxDays = 366;

/// A date as the server takes it: "2026-10-12".
String timeOffDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The calendar date of [d], at midnight.
DateTime timeOffDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whether [day] is one of the days from [start] to [end], both inclusive.
bool timeOffTakesIn(DateTime start, DateTime end, DateTime day) {
  final d = timeOffDay(day);
  return !d.isBefore(timeOffDay(start)) && !d.isAfter(timeOffDay(end));
}

/// The stretch of time off [agent] is on that takes in [day], if any.
AgentAway? agentAwayOn(AgentOption agent, DateTime day) {
  for (final away in agent.timeOff) {
    if (timeOffTakesIn(away.startDate, away.endDate, day)) return away;
  }
  return null;
}

/// Days from [start] to [end], both included.
int timeOffLength(DateTime start, DateTime end) =>
    DateTime.utc(end.year, end.month, end.day)
        .difference(DateTime.utc(start.year, start.month, start.day))
        .inDays +
    1;

/// Where an absence stands next to today.
enum TimeOffWhen { today, thisWeek, later, past }

/// Out today; starting within the next seven days; later; or over.
TimeOffWhen timeOffWhen(TimeOff t, DateTime now) {
  final today = timeOffDay(now);
  if (timeOffDay(t.endDate).isBefore(today)) return TimeOffWhen.past;
  if (timeOffTakesIn(t.startDate, t.endDate, today)) return TimeOffWhen.today;
  final weekEnd = today.add(const Duration(days: 7));
  return timeOffDay(t.startDate).isBefore(weekEnd)
      ? TimeOffWhen.thisWeek
      : TimeOffWhen.later;
}

/// What the app sends to write down or change an absence. [userId] is read
/// only when one is written down: null means the signed-in user's own.
class TimeOffDraft {
  final int? userId;
  final TimeOffKind kind;
  final DateTime startDate;
  final DateTime endDate;
  final int? coverId;
  final String? note;

  const TimeOffDraft({
    this.userId,
    required this.kind,
    required this.startDate,
    required this.endDate,
    this.coverId,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        if (userId != null) 'userId': userId,
        'kind': timeOffKindParam(kind),
        'startDate': timeOffDateParam(startDate),
        'endDate': timeOffDateParam(endDate),
        if (coverId != null) 'coverId': coverId,
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      };
}

/// The kind as the server spells it.
String timeOffKindParam(TimeOffKind kind) {
  switch (kind) {
    case TimeOffKind.vacation:
      return 'VACATION';
    case TimeOffKind.sickLeave:
      return 'SICK_LEAVE';
    case TimeOffKind.dayOff:
      return 'DAY_OFF';
    case TimeOffKind.other:
      return 'OTHER';
  }
}
