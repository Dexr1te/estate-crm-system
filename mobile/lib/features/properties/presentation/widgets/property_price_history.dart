import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const priceReductionWindow = Duration(days: 30);

/// Whether the latest change of [p]'s price was a cut made within the last
/// [priceReductionWindow] of [now].
bool isRecentPriceReduction(PropertyResponse p, DateTime now) {
  final previous = p.previousPrice;
  final changedAt = p.priceChangedAt;
  if (previous == null || changedAt == null) return false;
  if (p.price >= previous) return false;
  return now.difference(changedAt) <= priceReductionWindow;
}

bool showsPriceReduced(PropertyResponse p) =>
    isRecentPriceReduction(p, AppClock.now());

bool isPriceReduced(PropertyResponse p) =>
    p.previousPrice != null && p.price < p.previousPrice!;

String formatPriceChangePercent(double oldPrice, double newPrice,
    [String locale = 'en']) {
  if (oldPrice <= 0) return '';
  final pct = (newPrice - oldPrice) / oldPrice * 100;
  final digits =
      NumberFormat('0.#', NumberFormat.localeExists(locale) ? locale : 'en')
          .format(pct.abs());
  if (digits == '0') return '0%';
  return '${pct < 0 ? '−' : '+'}$digits%';
}

class PriceReducedChip extends StatelessWidget {
  const PriceReducedChip({super.key});

  @override
  Widget build(BuildContext context) => StatusChip(
        label: AppLocalizations.of(context).propertiesPriceReduced,
        hue: StatusHue.lead,
      );
}

class PropertyPriceHistoryCard extends StatelessWidget {
  final List<PropertyPriceChange> changes;
  const PropertyPriceHistoryCard({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.propertiesPriceHistory)),
              Text('${changes.length}',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          for (var i = 0; i < changes.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _PriceChangeRow(change: changes[i]),
          ],
        ],
      ),
    );
  }
}

class _PriceChangeRow extends StatelessWidget {
  final PropertyPriceChange change;
  const _PriceChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).languageCode;
    final meta = [
      if (change.changedAt != null) formatFullDate(change.changedAt!, locale),
      if (change.changedByName != null && change.changedByName!.isNotEmpty)
        change.changedByName!,
    ].join(' · ');

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  '${formatPrice(change.oldPrice)} → '
                  '${formatPrice(change.newPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatPriceChangePercent(
                    change.oldPrice, change.newPrice, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textSecondary),
              ),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
