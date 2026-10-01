import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A client's birthday: a day and a month, and the year when it is known.
///
/// The API speaks ISO 8601 — `1990-05-14`, or `--05-14` without a year — and
/// refuses a day that does not exist, a 29 February in a year without one, and
/// a date in the future.
class ClientBirthday {
  final int month;
  final int day;
  final int? year;

  const ClientBirthday({required this.month, required this.day, this.year});

  static final _full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final _noYear = RegExp(r'^--(\d{2})-(\d{2})$');

  /// The API's text, or null when there is none or it cannot be read.
  static ClientBirthday? parse(String? raw) {
    final value = raw?.trim() ?? '';
    final full = _full.firstMatch(value);
    if (full != null) {
      return ClientBirthday(
        year: int.parse(full.group(1)!),
        month: int.parse(full.group(2)!),
        day: int.parse(full.group(3)!),
      );
    }
    final noYear = _noYear.firstMatch(value);
    if (noYear != null) {
      return ClientBirthday(
        month: int.parse(noYear.group(1)!),
        day: int.parse(noYear.group(2)!),
      );
    }
    return null;
  }

  /// The client's birthday, if one is recorded.
  static ClientBirthday? of(ClientResponse client) => parse(client.birthday);

  /// What the API is sent.
  String toApi() {
    final md = '${_two(month)}-${_two(day)}';
    final y = year;
    return y == null ? '--$md' : '${y.toString().padLeft(4, '0')}-$md';
  }

  ClientBirthday withoutYear() => ClientBirthday(month: month, day: day);

  /// A day to hand a date picker or a formatter. Without a year it sits in a
  /// leap year, so 29 February is a day like any other.
  DateTime get asDate => DateTime(year ?? 2000, month, day);

  /// How old the client is on [today], or null without a year.
  int? ageOn(DateTime today) {
    final y = year;
    if (y == null) return null;
    final hadBirthday =
        today.month > month || (today.month == month && today.day >= day);
    return today.year - y - (hadBirthday ? 0 : 1);
  }

  @override
  bool operator ==(Object other) =>
      other is ClientBirthday &&
      other.month == month &&
      other.day == day &&
      other.year == year;

  @override
  int get hashCode => Object.hash(month, day, year);

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// "14 May 1990", or "14 May" without a year, in the reader's language.
String clientBirthdayLabel(ClientBirthday birthday, String locale) =>
    birthday.year == null
        ? formatDayMonth(birthday.asDate, locale)
        : formatFullDate(birthday.asDate, locale);

/// When an upcoming date is, relative to today: "Today", "Tomorrow",
/// "In 5 days".
String clientDateWhenLabel(AppLocalizations l10n, int daysAway) =>
    switch (daysAway) {
      <= 0 => l10n.clientsDatesToday,
      1 => l10n.clientsDatesTomorrow,
      _ => l10n.clientsDatesInDays(daysAway),
    };

/// What the date is: "Birthday, turns 36", "Birthday", "3 years since the
/// purchase".
String clientDateWhatLabel(AppLocalizations l10n, UpcomingClientDate date) {
  final years = date.years;
  if (date.kind == ClientDateKind.purchaseAnniversary) {
    return l10n.clientsDatesAnniversary(years ?? 1);
  }
  return years == null
      ? l10n.clientsDatesBirthday
      : l10n.clientsDatesTurns(years);
}

/// Whether an agency template is a birthday greeting: the default one in any
/// of the three languages, or one a manager wrote with "birthday" in its
/// title.
bool isBirthdayGreeting(MessageTemplate template) {
  final title = template.title.toLowerCase();
  return title.contains('birthday') ||
      title.contains('рожден') ||
      title.contains('туған күн');
}
