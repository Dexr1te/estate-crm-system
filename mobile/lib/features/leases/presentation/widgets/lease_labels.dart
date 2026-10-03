import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String dealKindLabel(AppLocalizations l10n, DealKind kind) {
  switch (kind) {
    case DealKind.sale:
      return l10n.dealsKindSale;
    case DealKind.rent:
      return l10n.dealsKindRent;
  }
}

/// A short date, with the year only when it is not this year's.
String leaseDateLabel(DateTime date, DateTime now, String locale) =>
    date.year == now.year
        ? formatDayMonth(date, locale)
        : formatFullDate(date, locale);

/// "12 Jan 2026 – 11 Jan 2027": the lease from its first to its last day.
String leasePeriodLabel(DateTime start, DateTime end, String locale) =>
    '${formatFullDate(start, locale)} – ${formatFullDate(end, locale)}';

/// "Lease ends in 5 days", "Lease ends today", "Lease ended 3 days ago".
String leaseTimeLeftLabel(AppLocalizations l10n, int daysLeft) {
  if (daysLeft == 0) return l10n.leasesEndsToday;
  if (daysLeft == 1) return l10n.leasesEndsTomorrow;
  if (daysLeft == -1) return l10n.leasesEndedYesterday;
  return daysLeft > 0
      ? l10n.leasesEndsIn(daysLeft)
      : l10n.leasesEndedAgo(-daysLeft);
}

/// A rent's amount as a monthly figure: "$1,200 a month".
String leaseRentLabel(AppLocalizations l10n, double monthlyRent) =>
    l10n.leasesPerMonth(formatPrice(monthlyRent));
