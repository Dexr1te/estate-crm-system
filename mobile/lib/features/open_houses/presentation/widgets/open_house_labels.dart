import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Sat, 4 Oct · 12:00–15:00": the day once, then the hours.
String openHouseWhen(OpenHouse o, String locale) =>
    '${formatWeekdayDate(o.startsAt, locale)} · '
    '${formatTimeOfDay(o.startsAt)}–${formatTimeOfDay(o.endsAt)}';

String openHouseInterestLabel(
        AppLocalizations l10n, OpenHouseInterest interest) =>
    switch (interest) {
      OpenHouseInterest.interested => l10n.openHouseInterested,
      OpenHouseInterest.justLooking => l10n.openHouseJustLooking,
    };

/// The server's refusals this feature knows by name, in the app's language;
/// anything else as every other screen words it.
String openHouseFailureLabel(AppLocalizations l10n, Object error) {
  final failure = ApiFailure.from(error);
  return switch (failure.serverCode) {
    'ALREADY_SIGNED_IN' => l10n.openHouseAlreadySignedIn,
    'OPEN_HOUSE_HAS_VISITORS' => l10n.openHouseHasVisitors,
    'ENDS_BEFORE_START' => l10n.openHouseEndsBeforeStart,
    'OPEN_HOUSE_TOO_LONG' => l10n.openHouseTooLong,
    'INVALID_PHONE' => l10n.openHouseVisitorPhoneInvalid,
    _ => apiFailureLabel(l10n, failure),
  };
}
