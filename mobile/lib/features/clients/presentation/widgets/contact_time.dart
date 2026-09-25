import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

int _daysBetween(DateTime at, DateTime now) {
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(at.year, at.month, at.day))
      .inDays;
  return days < 0 ? 0 : days;
}

String activityTimeLabel(
    AppLocalizations l10n, DateTime at, DateTime now, String locale) {
  final time = formatTimeOfDay(at);
  switch (_daysBetween(at, now)) {
    case 0:
      return l10n.clientsActivityToday(time);
    case 1:
      return l10n.clientsActivityYesterday(time);
  }
  if (at.year == now.year) return '${formatDayMonth(at, locale)}, $time';
  return formatFullDate(at, locale);
}

String lastContactLabel(
    AppLocalizations l10n, DateTime at, DateTime now, String locale) {
  final days = _daysBetween(at, now);
  if (days == 0) return l10n.clientsContactedToday;
  if (days == 1) return l10n.clientsContactedYesterday;
  if (days <= 30) return l10n.clientsContactedDaysAgo(days);
  return l10n.clientsContactedOn(at.year == now.year
      ? formatDayMonth(at, locale)
      : formatFullDate(at, locale));
}

String activityTypeLabel(AppLocalizations l10n, ActivityType type) {
  switch (type) {
    case ActivityType.CALL:
      return l10n.clientsActivityCall;
    case ActivityType.MESSAGE:
      return l10n.clientsActivityMessage;
    case ActivityType.EMAIL:
      return l10n.clientsActivityEmail;
    case ActivityType.NOTE:
      return l10n.clientsActivityNote;
  }
}

IconData activityTypeIcon(ActivityType type) {
  switch (type) {
    case ActivityType.CALL:
      return Icons.call_outlined;
    case ActivityType.MESSAGE:
      return Icons.chat_bubble_outline_rounded;
    case ActivityType.EMAIL:
      return Icons.mail_outline_rounded;
    case ActivityType.NOTE:
      return Icons.sticky_note_2_outlined;
  }
}
