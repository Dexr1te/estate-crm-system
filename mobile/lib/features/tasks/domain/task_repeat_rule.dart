import 'package:real_estate_crm/core/models/models.dart';

/// The server's names for the days of the week, Monday first, so that
/// `weekdayNames[DateTime.monday - 1] == 'MONDAY'`.
const weekdayNames = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

/// [DateTime.monday] ... [DateTime.sunday] for the names a rule carries,
/// Monday first; names this build does not know are left out.
List<int> weekdayNumbers(List<String> names) {
  final numbers = <int>{
    for (final name in names)
      if (weekdayNames.contains(name.toUpperCase()))
        weekdayNames.indexOf(name.toUpperCase()) + 1,
  }.toList()
    ..sort();
  return numbers;
}

/// The days a weekly rule falls on: the ones it names, else the weekday of
/// [due], the way the server reads a weekly rule without days.
List<int> effectiveWeekdays(TaskRepeat repeat, DateTime due) {
  final days = weekdayNumbers(repeat.weekdays);
  return days.isEmpty ? [(repeat.anchorAt ?? due).weekday] : days;
}

/// The rule as the task form sends it: `{"frequency": "NONE"}` stops a
/// series; [until] goes as a calendar day.
Map<String, dynamic> repeatRequest(TaskRepeat? repeat) {
  if (repeat == null || repeat.frequency == RepeatFrequency.none) {
    return const {'frequency': 'NONE'};
  }
  final until = repeat.until;
  return {
    'frequency': repeat.frequency.name.toUpperCase(),
    if (repeat.frequency == RepeatFrequency.weekly)
      'weekdays': [
        for (final day in weekdayNumbers(repeat.weekdays))
          weekdayNames[day - 1],
      ],
    if (until != null)
      'until': '${until.year.toString().padLeft(4, '0')}-'
          '${until.month.toString().padLeft(2, '0')}-'
          '${until.day.toString().padLeft(2, '0')}',
    if (until == null && repeat.count != null) 'count': repeat.count,
  };
}

/// Whether a month-based rule anchored on [anchor] falls on a shorter
/// month's last day some of the time: the 31st every month, the 31st of
/// January every quarter (30 April), the 29th of February every year.
bool clampsInShortMonths(RepeatFrequency frequency, DateTime anchor) {
  final step = switch (frequency) {
    RepeatFrequency.monthly => 1,
    RepeatFrequency.quarterly => 3,
    RepeatFrequency.yearly => 12,
    _ => 0,
  };
  if (step == 0) return false;
  for (var k = 0; k < 12; k += step) {
    final month = (anchor.month - 1 + k) % 12 + 1;
    if (anchor.day > _shortestLength(month)) return true;
  }
  return false;
}

/// February counts as 28: most years it is.
int _shortestLength(int month) => switch (month) {
      DateTime.february => 28,
      DateTime.april ||
      DateTime.june ||
      DateTime.september ||
      DateTime.november =>
        30,
      _ => 31,
    };
