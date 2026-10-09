import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A day, with the year only when it is not this year's.
String keysDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// "With Timur Aliev · until 12 Oct", or "With Timur Aliev" without a day.
String keysHolderLine(
    AppLocalizations l10n, KeyHandover h, DateTime now, String locale) {
  final due = h.dueBackAt;
  return due == null
      ? l10n.keysWithHolder(h.holderName)
      : l10n.keysWithHolderUntil(keysDateLabel(due, now, locale), h.holderName);
}

/// "Handed out 9 Oct by Aigul Bekova", or without the name once their
/// account is gone.
String keysHandedOutLine(
    AppLocalizations l10n, KeyHandover h, DateTime now, String locale) {
  final day = keysDateLabel(h.handedOutAt, now, locale);
  final by = h.handedOutByName?.trim() ?? '';
  return by.isEmpty ? l10n.keysHandedOutOn(day) : l10n.keysHandedOutBy(day, by);
}

/// "9 Oct – 11 Oct": from when the keys went out to when they came back.
String keysPeriodLabel(
    AppLocalizations l10n, KeyHandover h, DateTime now, String locale) {
  final back = h.returnedAt;
  final from = keysDateLabel(h.handedOutAt, now, locale);
  return back == null
      ? from
      : l10n.keysHistoryPeriod(from, keysDateLabel(back, now, locale));
}

/// The server's refusals this feature knows by name, in the app's language;
/// anything else as every other screen words it.
String keysFailureLabel(AppLocalizations l10n, ApiFailure failure) =>
    switch (failure.serverCode) {
      'KEY_ALREADY_OUT' => l10n.keysErrorAlreadyOut,
      'KEY_NOT_OUT' => l10n.keysErrorNotOut,
      'KEY_HOLDER_REQUIRED' => l10n.keysErrorHolderRequired,
      'KEY_DUE_IN_PAST' => l10n.keysErrorDueInPast,
      _ => apiFailureLabel(l10n, failure),
    };
