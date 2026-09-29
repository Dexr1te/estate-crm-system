import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/price_comparables_sheet.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/price_range_bar.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Whether an insight has anything to say about a listing at all.
bool hasPriceCheck(PriceInsight? insight) =>
    insight != null &&
    insight.count > 0 &&
    (insight.active.medianPerSqm != null || insight.sold.medianPerSqm != null);

/// "12% above", "8% below" or "at the median", from a signed percentage.
String priceDifferenceLabel(AppLocalizations l10n, double percent) {
  final rounded = percent.abs().round();
  if (rounded == 0) return l10n.propertiesPriceCheckAtMedian;
  return percent > 0
      ? l10n.propertiesPriceCheckAbove('$rounded')
      : l10n.propertiesPriceCheckBelow('$rounded');
}

class PropertyPriceCheckCard extends StatelessWidget {
  final PriceInsight insight;
  const PropertyPriceCheckCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final active = insight.active;
    final sold = insight.sold;
    final position = insight.position;
    final median = active.medianPerSqm;
    final city = insight.criteria.city ?? '';

    String? headline;
    if (position != null && median != null) {
      headline = l10n.propertiesPriceCheckVsMedian(
        formatPrice(position.pricePerSqm),
        formatPrice(median),
        priceDifferenceLabel(l10n, position.vsMedianPercent ?? 0),
      );
    } else if (median != null) {
      headline = l10n.propertiesPricePerSqm(formatPrice(median));
    }

    final soldLine = sold.medianPerSqm == null
        ? null
        : [
            l10n.propertiesPriceCheckSold(
                l10n.propertiesPricePerSqm(formatPrice(sold.medianPerSqm!))),
            if (sold.medianDaysOnMarket != null)
              l10n.propertiesPriceCheckDaysOnMarket(sold.medianDaysOnMarket!),
          ].join(' · ');

    TextStyle muted(double size) => TextStyle(
        fontFamily: AppFonts.sans, fontSize: size, color: t.textSecondary);

    return AppCard(
      key: const ValueKey('property-price-check'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesPriceCheck),
          if (headline != null) ...[
            const SizedBox(height: 10),
            Text(
              headline,
              key: const ValueKey('price-check-headline'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: t.textPrimary),
            ),
          ],
          if (active.p25PerSqm != null &&
              active.p75PerSqm != null &&
              median != null) ...[
            const SizedBox(height: 12),
            PriceRangeBar(
              low: active.p25PerSqm!,
              median: median,
              high: active.p75PerSqm!,
              marker: position?.pricePerSqm,
            ),
          ],
          if (insight.lowConfidence) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 15, color: t.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.propertiesPriceCheckLowConfidence,
                    key: const ValueKey('price-check-low-confidence'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: muted(12),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            l10n.propertiesPriceCheckBasedOn(insight.count, city),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: muted(12),
          ),
          if (soldLine != null) ...[
            const SizedBox(height: 4),
            Text(
              soldLine,
              key: const ValueKey('price-check-sold'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: muted(12),
            ),
          ],
          if (insight.comparables.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('price-check-comparables'),
              label: l10n.propertiesPriceCheckSeeComparables,
              height: AppMetrics.buttonHeightInline,
              onPressed: () => showPriceComparablesSheet(context, insight),
            ),
          ],
        ],
      ),
    );
  }
}
