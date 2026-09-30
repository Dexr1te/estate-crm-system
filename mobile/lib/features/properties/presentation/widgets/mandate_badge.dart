import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/domain/mandate.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String mandateTypeLabel(AppLocalizations l10n, MandateType? type) {
  switch (type) {
    case MandateType.EXCLUSIVE:
      return l10n.propertiesMandateExclusive;
    case MandateType.OPEN:
      return l10n.propertiesMandateOpen;
    case null:
      return l10n.propertiesMandateNone;
  }
}

/// The agreement's last day as a short date, with the year only when it is
/// not this year's.
String mandateDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// "Exclusive until 12 Oct", "Open agreement", "Agreement ended 3 Sep"; null
/// when the listing has no agreement.
String? mandateBadgeLabel(
    AppLocalizations l10n, PropertyResponse p, DateTime now, String locale) {
  final type = p.mandateType;
  if (type == null) return null;
  final end = p.mandateEndDate;
  final exclusive = type == MandateType.EXCLUSIVE;
  if (end == null) {
    return exclusive
        ? l10n.propertiesMandateExclusive
        : l10n.propertiesMandateOpenBadge;
  }
  final date = mandateDateLabel(end, now, locale);
  if (mandateUrgency(p, now) == MandateUrgency.ended) {
    return exclusive
        ? l10n.propertiesMandateExclusiveEnded(date)
        : l10n.propertiesMandateOpenEnded(date);
  }
  return exclusive
      ? l10n.propertiesMandateExclusiveUntil(date)
      : l10n.propertiesMandateOpenUntil(date);
}

/// "Ends in 5 days", "Ends today", "Ended 3 days ago", from whole days left.
String mandateTimeLeftLabel(AppLocalizations l10n, int daysLeft) {
  if (daysLeft == 0) return l10n.propertiesMandateEndsToday;
  if (daysLeft == 1) return l10n.propertiesMandateEndsTomorrow;
  if (daysLeft == -1) return l10n.propertiesMandateEndedYesterday;
  return daysLeft > 0
      ? l10n.propertiesMandateEndsIn(daysLeft)
      : l10n.propertiesMandateEndedAgo(-daysLeft);
}

/// The seller agreement as a chip. Quiet while it holds; the warning hue once
/// it ends within two weeks or has ended on a listing still for sale.
/// Nothing at all when no agreement is recorded.
class MandateBadge extends StatelessWidget {
  final PropertyResponse property;
  const MandateBadge({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = mandateBadgeLabel(l10n, property, now, locale);
    if (label == null) return const SizedBox.shrink();
    final warning = mandateNeedsAttention(property, now);
    return StatusChip(
      key: ValueKey('mandate-badge-${property.id}${warning ? '-warning' : ''}'),
      label: label,
      hue: warning ? StatusHue.danger : StatusHue.neutral,
    );
  }
}
