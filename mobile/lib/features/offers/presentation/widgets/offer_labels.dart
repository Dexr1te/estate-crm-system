import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String offerStatusLabel(AppLocalizations l10n, OfferStatus status) =>
    switch (status) {
      OfferStatus.isNew => l10n.offersStatusNew,
      OfferStatus.countered => l10n.offersStatusCountered,
      OfferStatus.accepted => l10n.offersStatusAccepted,
      OfferStatus.rejected => l10n.offersStatusRejected,
      OfferStatus.withdrawn => l10n.offersStatusWithdrawn,
      OfferStatus.expired => l10n.offersStatusExpired,
    };

StatusHue offerStatusHue(OfferStatus status) => switch (status) {
      OfferStatus.isNew => StatusHue.lead,
      OfferStatus.countered => StatusHue.negotiation,
      OfferStatus.accepted => StatusHue.positive,
      OfferStatus.rejected => StatusHue.danger,
      OfferStatus.withdrawn || OfferStatus.expired => StatusHue.neutral,
    };

String offerPartyLabel(AppLocalizations l10n, OfferParty party) =>
    switch (party) {
      OfferParty.buyer => l10n.offersPartyBuyer,
      OfferParty.seller => l10n.offersPartySeller,
    };

/// Whose figure is on the table, as the offer's hero says it.
String offerFigureLabel(AppLocalizations l10n, OfferParty party) =>
    switch (party) {
      OfferParty.buyer => l10n.offersFigureBuyer,
      OfferParty.seller => l10n.offersFigureSeller,
    };

/// One step of the negotiation, as its history lists it.
String offerStepLabel(AppLocalizations l10n, OfferStep step) =>
    switch (step.action) {
      OfferAction.offered => l10n.offersStepOffered,
      OfferAction.countered => step.party == OfferParty.seller
          ? l10n.offersStepCounteredSeller
          : l10n.offersStepCounteredBuyer,
      OfferAction.accepted => l10n.offersStepAccepted,
      OfferAction.rejected => l10n.offersStepRejected,
      OfferAction.withdrawn => l10n.offersStepWithdrawn,
      null => l10n.offersStepOther,
    };

/// Who made the offer: the buyer by name when the user may open their card,
/// otherwise the colleague who holds it.
String offerBuyerLabel(AppLocalizations l10n, PropertyOffer o) {
  final name = o.clientName?.trim() ?? '';
  if (o.clientVisible && name.isNotEmpty) return name;
  final colleague = o.clientAgentName?.trim() ?? '';
  return colleague.isEmpty
      ? l10n.offersHiddenBuyer
      : l10n.offersColleagueBuyer(colleague);
}

/// The offer as a whole percent of the asking price, or null without one.
int? offerPercentOfAsking(PropertyOffer o) {
  final asking = o.propertyPrice;
  if (asking == null || asking <= 0) return null;
  return (o.amount / asking * 100).round();
}

/// A day, with the year only when it is not this year's.
String offerDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// The server's refusals this feature knows by name, in the app's language;
/// anything else as every other screen words it.
String offerFailureLabel(AppLocalizations l10n, Object error) {
  final failure = ApiFailure.from(error);
  return switch (failure.serverCode) {
    'CLIENT_NOT_BUYER' => l10n.offersClientNotBuyer,
    'OFFER_ALREADY_OPEN' => l10n.offersAlreadyOpen,
    'OFFER_EXPIRY_PAST' => l10n.offersExpiryPast,
    'PROPERTY_SOLD' => l10n.offersPropertySold,
    'OFFER_CLOSED' => l10n.offersNoLongerOpen,
    'OFFER_ALREADY_ACCEPTED' => l10n.offersAlreadyAccepted,
    _ => apiFailureLabel(l10n, failure),
  };
}
