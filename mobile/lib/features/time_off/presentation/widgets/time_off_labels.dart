import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String timeOffKindLabel(AppLocalizations l10n, TimeOffKind kind) {
  switch (kind) {
    case TimeOffKind.vacation:
      return l10n.timeOffKindVacation;
    case TimeOffKind.sickLeave:
      return l10n.timeOffKindSickLeave;
    case TimeOffKind.dayOff:
      return l10n.timeOffKindDayOff;
    case TimeOffKind.other:
      return l10n.timeOffKindOther;
  }
}

IconData timeOffKindIcon(TimeOffKind kind) {
  switch (kind) {
    case TimeOffKind.vacation:
      return Icons.beach_access_outlined;
    case TimeOffKind.sickLeave:
      return Icons.healing_outlined;
    case TimeOffKind.dayOff:
      return Icons.event_busy_outlined;
    case TimeOffKind.other:
      return Icons.schedule_outlined;
  }
}

/// A short date, with the year only when it is not this year's.
String timeOffDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// "12 Oct – 16 Oct", or one date when it is a single day.
String timeOffPeriodLabel(
    DateTime start, DateTime end, DateTime now, String locale) {
  final first = timeOffDateLabel(start, now, locale);
  final last = timeOffDateLabel(end, now, locale);
  return first == last ? first : '$first – $last';
}

/// "Covered by Timur", or that nobody covers.
String timeOffCoverLabel(AppLocalizations l10n, String? coverName) =>
    coverName == null || coverName.trim().isEmpty
        ? l10n.timeOffNobodyCovers
        : l10n.timeOffCoveredBy(coverName);

/// What the server says went wrong with an absence, in the reader's words.
String timeOffFailureLabel(AppLocalizations l10n, ApiFailure failure) {
  switch (failure.serverCode) {
    case 'TIME_OFF_OVERLAPS':
      return l10n.timeOffErrorOverlaps;
    case 'END_BEFORE_START':
      return l10n.timeOffEndBeforeStart;
    case 'TIME_OFF_TOO_LONG':
      return l10n.timeOffErrorTooLong;
    case 'COVER_IS_ABSENT_PERSON':
      return l10n.timeOffErrorCoverIsAbsent;
    case 'MANAGER_ONLY':
    case 'NOT_YOUR_TIME_OFF':
      return l10n.timeOffErrorNotYours;
  }
  return apiFailureLabel(l10n, failure);
}

/// An agent as a picker row, with "Away until 12 Oct" beside anybody away.
PickerItem agentPickerItem(BuildContext context, AgentOption agent) =>
    PickerItem(
      id: agent.id,
      title: agent.fullName,
      subtitle: agent.email,
      badge: agentAwayBadge(AppLocalizations.of(context), agent, AppClock.now(),
          Localizations.localeOf(context).toLanguageTag()),
    );

/// "Aigul is away that day: Vacation until 16 Oct", when the agent picked
/// for a meeting is away on its day; null otherwise.
String? agentAwayWarning(
    BuildContext context, AgentOption? agent, DateTime? day) {
  if (agent == null || day == null) return null;
  final away = agentAwayOn(agent, day);
  if (away == null) return null;
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return l10n.timeOffAwayOnDay(
    agent.fullName,
    timeOffKindLabel(l10n, away.kind),
    timeOffDateLabel(away.endDate, AppClock.now(), locale),
  );
}

/// The badge a picker shows next to somebody away today: "Away until 12 Oct".
String? agentAwayBadge(
    AppLocalizations l10n, AgentOption agent, DateTime now, String locale) {
  final until = agent.awayUntil;
  if (until == null) return null;
  return l10n.timeOffAwayUntil(timeOffDateLabel(until, now, locale));
}
