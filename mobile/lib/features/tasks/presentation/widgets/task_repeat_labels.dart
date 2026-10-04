import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/tasks/domain/task_repeat_rule.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The name of a frequency as the picker offers it.
String repeatOptionLabel(AppLocalizations l10n, RepeatFrequency frequency) {
  switch (frequency) {
    case RepeatFrequency.none:
      return l10n.tasksRepeatNone;
    case RepeatFrequency.daily:
      return l10n.tasksRepeatOptionDaily;
    case RepeatFrequency.weekly:
      return l10n.tasksRepeatOptionWeekly;
    case RepeatFrequency.monthly:
      return l10n.tasksRepeatOptionMonthly;
    case RepeatFrequency.quarterly:
      return l10n.tasksRepeatOptionQuarterly;
    case RepeatFrequency.yearly:
      return l10n.tasksRepeatOptionYearly;
  }
}

/// The short name of a weekday (1 = Monday) in [locale]: "Mon", "пн", "дс".
String weekdayShort(int weekday, String locale) {
  final resolved = DateFormat.localeExists(locale) ? locale : 'en';
  // 2024-01-01 was a Monday.
  return DateFormat.E(resolved).format(DateTime(2024, 1, weekday));
}

/// The rule in words: "Every week on Mon, Thu", "Every month on the 31st
/// (last day in shorter months)", "Every day, until 30 Oct". [due] stands in
/// for the anchor when the rule has none yet, as in the form before saving.
String repeatLabel(
  AppLocalizations l10n,
  TaskRepeat repeat,
  DateTime due,
  String locale,
) {
  final anchor = repeat.anchorAt ?? due;
  final resolved = DateFormat.localeExists(locale) ? locale : 'en';
  String rule;
  switch (repeat.frequency) {
    case RepeatFrequency.none:
      return l10n.tasksRepeatNone;
    case RepeatFrequency.daily:
      rule = l10n.tasksRepeatDaily;
    case RepeatFrequency.weekly:
      rule = l10n.tasksRepeatWeekly([
        for (final day in effectiveWeekdays(repeat, due))
          weekdayShort(day, locale),
      ].join(', '));
    case RepeatFrequency.monthly:
      rule = l10n.tasksRepeatMonthly(_ordinal(l10n, anchor.day));
    case RepeatFrequency.quarterly:
      rule = l10n.tasksRepeatQuarterly(_ordinal(l10n, anchor.day));
    case RepeatFrequency.yearly:
      rule = l10n.tasksRepeatYearly(DateFormat.MMMMd(resolved).format(anchor));
  }
  if (clampsInShortMonths(repeat.frequency, anchor)) {
    rule = repeat.frequency == RepeatFrequency.yearly
        ? l10n.tasksRepeatLeapYear(rule)
        : l10n.tasksRepeatShortMonths(rule);
  }
  final until = repeat.until;
  if (until != null) {
    return l10n.tasksRepeatUntil(DateFormat.MMMd(resolved).format(until), rule);
  }
  final count = repeat.count;
  if (count != null) return l10n.tasksRepeatTimes(count, rule);
  return rule;
}

/// 1st, 2nd, 3rd, 4th ... 11th, 12th, 13th ... 21st: English needs the
/// suffix; the other languages' strings leave it out.
String _ordinal(AppLocalizations l10n, int day) {
  final suffix = day % 100 >= 11 && day % 100 <= 13
      ? 'th'
      : switch (day % 10) {
          1 => 'st',
          2 => 'nd',
          3 => 'rd',
          _ => 'th',
        };
  return l10n.tasksRepeatDayOrdinal(day, suffix);
}
