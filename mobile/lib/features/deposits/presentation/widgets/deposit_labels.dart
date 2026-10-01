import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String depositHolderLabel(AppLocalizations l10n, DepositHolder holder) {
  switch (holder) {
    case DepositHolder.AGENCY:
      return l10n.depositsHolderAgency;
    case DepositHolder.SELLER:
      return l10n.depositsHolderSeller;
    case DepositHolder.NOTARY:
      return l10n.depositsHolderNotary;
  }
}

String depositOutcomeLabel(AppLocalizations l10n, DepositOutcome outcome) {
  switch (outcome) {
    case DepositOutcome.APPLIED:
      return l10n.depositsOutcomeApplied;
    case DepositOutcome.REFUNDED:
      return l10n.depositsOutcomeRefunded;
    case DepositOutcome.FORFEITED:
      return l10n.depositsOutcomeForfeited;
  }
}

/// A short date, with the year only when it is not this year's.
String depositDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// "Hold ends in 5 days", "Hold ends today", "Hold ended 3 days ago".
String depositTimeLeftLabel(AppLocalizations l10n, int daysLeft) {
  if (daysLeft == 0) return l10n.depositsHoldEndsToday;
  if (daysLeft == 1) return l10n.depositsHoldEndsTomorrow;
  if (daysLeft == -1) return l10n.depositsHoldEndedYesterday;
  return daysLeft > 0
      ? l10n.depositsHoldEndsIn(daysLeft)
      : l10n.depositsHoldEndedAgo(-daysLeft);
}

/// A listing a buyer's deposit holds, as a chip: "Reserved until 12 Oct".
/// The warning hue once the hold ends within a week or has ended. Nothing at
/// all when no deposit holds it.
class DepositBadge extends StatelessWidget {
  final PropertyResponse property;
  const DepositBadge({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final until = property.depositHoldUntil;
    if (until == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final warning = depositHoldEnding(property, now);
    return StatusChip(
      key: ValueKey('deposit-badge-${property.id}${warning ? '-warning' : ''}'),
      label: l10n.depositsReservedUntil(depositDateLabel(until, now, locale)),
      hue: warning ? StatusHue.danger : StatusHue.negotiation,
    );
  }
}
