import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String partnerKindLabel(AppLocalizations l10n, PartnerKind kind) =>
    switch (kind) {
      PartnerKind.mortgageBroker => l10n.partnersKindMortgageBroker,
      PartnerKind.lawyer => l10n.partnersKindLawyer,
      PartnerKind.appraiser => l10n.partnersKindAppraiser,
      PartnerKind.developer => l10n.partnersKindDeveloper,
      PartnerKind.agency => l10n.partnersKindAgency,
      PartnerKind.other => l10n.partnersKindOther,
    };

String handoffStatusLabel(AppLocalizations l10n, PartnerHandoffStatus s) =>
    switch (s) {
      PartnerHandoffStatus.sent => l10n.partnersHandoffSent,
      PartnerHandoffStatus.inProgress => l10n.partnersHandoffInProgress,
      PartnerHandoffStatus.done => l10n.partnersHandoffDone,
    };

StatusHue handoffStatusHue(PartnerHandoffStatus s) => switch (s) {
      PartnerHandoffStatus.sent => StatusHue.neutral,
      PartnerHandoffStatus.inProgress => StatusHue.lead,
      PartnerHandoffStatus.done => StatusHue.positive,
    };

/// An amount in the agency's currency.
String partnerMoney(double amount) =>
    formatMoney(amount, AppCurrency.current, AppCurrency.locale);

/// "20% of commission", "$500 per deal", or that no fee was agreed.
String partnerFeeLabel(AppLocalizations l10n, Partner p) {
  final value = p.feeValue;
  return switch (p.feeType) {
    ReferralFeeType.percent when value != null =>
      l10n.partnersFeePercent(formatRate(value)),
    ReferralFeeType.fixed when value != null =>
      l10n.partnersFeeFixed(partnerMoney(value)),
    _ => l10n.partnersFeeNone,
  };
}

/// "Mortgage broker · Halyk Bank", or the kind alone.
String partnerSubtitle(AppLocalizations l10n, Partner p) {
  final company = p.company?.trim() ?? '';
  return company.isEmpty
      ? partnerKindLabel(l10n, p.kind)
      : '${partnerKindLabel(l10n, p.kind)} · $company';
}

/// The server's refusals this feature knows by name, in the app's language;
/// anything else as every other screen words it.
String partnerFailureLabel(AppLocalizations l10n, Object error) {
  final failure = ApiFailure.from(error);
  return switch (failure.serverCode) {
    'PARTNER_IN_USE' => l10n.partnersInUse,
    'INVALID_REFERRAL_FEE' => l10n.partnersInvalidFee,
    'PARTNER_REQUIRED' => l10n.partnersRequired,
    'SENT_ON_IN_FUTURE' => l10n.partnersSentOnFuture,
    _ => apiFailureLabel(l10n, failure),
  };
}
