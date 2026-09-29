import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<void> showPriceComparablesSheet(
    BuildContext context, PriceInsight insight) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context,
    title: l10n.propertiesPriceCheckComparables,
    subtitle: l10n.propertiesPriceCheckBasedOn(
        insight.count, insight.criteria.city ?? ''),
    builder: (_) => PriceComparablesList(comparables: insight.comparables),
  );
}

class PriceComparablesList extends StatelessWidget {
  final List<PriceComparable> comparables;
  const PriceComparablesList({super.key, required this.comparables});

  void _open(BuildContext context, int id) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/properties/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < comparables.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ComparableRow(
            comparable: comparables[i],
            onTap: () => _open(context, comparables[i].id),
          ),
        ],
      ],
    );
  }
}

class _ComparableRow extends StatelessWidget {
  final PriceComparable comparable;
  final VoidCallback onTap;
  const _ComparableRow({required this.comparable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final status = comparable.sold ? PropertyStatus.SOLD : comparable.status;

    return AppCard(
      key: ValueKey('price-comparable-${comparable.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comparable.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${formatPrice(comparable.price)} · '
                        '${l10n.propertiesPricePerSqm(formatPrice(comparable.pricePerSqm))}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PropertyStatusChip(status: status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
