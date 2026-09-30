import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_price_history.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The seller report as plain text, for a message to the owner: one figure a
/// line, in the app's language, readable in any chat without formatting.
///
/// Counts only — no buyer is named — so it can go to the seller as it is.
String sellerReportText(SellerReport r, AppLocalizations l10n, String locale) {
  String line(String label, Object value) =>
      l10n.propertiesReportTextLine(label, '$value');
  String date(DateTime d) => formatFullDate(d.toLocal(), locale);

  final v = r.viewings;
  final price = r.price;
  final lines = <String>[
    l10n.propertiesReportTextHeading(r.title),
    if (r.address.isNotEmpty) r.address,
    if (r.generatedOn != null) l10n.propertiesReportAsOf(date(r.generatedOn!)),
    '',
    if (r.listedAt != null) l10n.propertiesReportListedOn(date(r.listedAt!)),
    if (r.soldAt != null) l10n.propertiesReportSoldOn(date(r.soldAt!)),
    line(l10n.propertiesReportDaysOnMarket, r.daysOnMarket),
    '',
    line(l10n.propertiesReportViewingsHeld, v.held),
    line(l10n.propertiesReportViewingsUpcoming, v.upcoming),
    if (v.total > 0) ...[
      for (final outcome in ViewingOutcome.values)
        if (v.count(outcome) > 0)
          '  ${line(viewingOutcomeLabel(l10n, outcome), v.count(outcome))}',
      if (v.awaitingOutcome > 0)
        '  ${line(l10n.propertiesReportAwaitingOutcome, v.awaitingOutcome)}',
    ],
    if (v.nextAt != null) l10n.propertiesReportNextViewing(date(v.nextAt!)),
    '',
    line(l10n.propertiesReportLinkViews, r.publicLink.views),
    line(l10n.propertiesReportLinkLeads, r.publicLink.leads),
    line(l10n.propertiesReportMatchingBuyers, r.matchingBuyers),
    '',
    if (price.changes.isEmpty) ...[
      line(l10n.propertiesReportPrice, formatPrice(price.current)),
      l10n.propertiesReportPriceUnchanged,
    ] else ...[
      line(l10n.propertiesReportOriginalPrice, formatPrice(price.original)),
      line(
          l10n.propertiesReportCurrentPrice,
          '${formatPrice(price.current)} '
          '(${formatPriceChangePercent(price.original, price.current, locale)})'),
      '${l10n.propertiesReportPriceChanges}:',
      for (final c in price.changes)
        '  ${c.changedAt != null ? '${date(c.changedAt!)}: ' : ''}'
            '${formatPrice(c.oldPrice)} → ${formatPrice(c.newPrice)}',
    ],
  ];
  return lines.join('\n').trim();
}
