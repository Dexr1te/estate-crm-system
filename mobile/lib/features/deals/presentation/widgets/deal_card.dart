import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onTap;

  static const staleAfter = Duration(days: 5);

  const DealCard({super.key, required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    final meta = [
      if (deal.clientName.isNotEmpty) deal.clientName,
      if (deal.agentName.isNotEmpty) l10n.dealsAgentValue(deal.agentName),
    ].join(' · ');

    final stale = staleDays(deal);
    final amount = deal.dealPrice ?? deal.budget ?? 0;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              DealStatusChip(status: deal.status),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 6),
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
          Padding(
            padding: const EdgeInsets.only(top: 11, bottom: 10),
            child: Container(height: 1, color: t.border),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatPrice(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stale != null
                      ? l10n.dealsStaleWarning(stale)
                      : (deal.budget != null
                          ? l10n.dealsBudgetValue(formatPrice(deal.budget!))
                          : ''),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    fontWeight:
                        stale != null ? FontWeight.w600 : FontWeight.w400,
                    color: stale != null ? t.dangerText : t.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// How long a deal has sat untouched, or null when it is closed or still
  /// fresh. The board reads it too, so the two views call the same deal stale.
  static int? staleDays(DealResponse deal) {
    if (deal.status == DealStatus.CLOSED_WON ||
        deal.status == DealStatus.CLOSED_LOST) {
      return null;
    }
    final last = deal.updatedAt ?? deal.createdAt;
    if (last == null) return null;
    final days = AppClock.now().difference(last).inDays;
    return days >= staleAfter.inDays ? days : null;
  }
}

/// The placeholder a [DealCard] leaves: a two-line title with its status chip,
/// the client and agent under it, then the price across the rule.
///
/// The chip keeps its corner. It is the first thing read on a board of deals,
/// and a skeleton that leaves it out lets the title stretch the full width and
/// then snap back when the real card arrives.
class DealCardBone extends StatelessWidget {
  const DealCardBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerBar(widthFactor: 0.94, height: 12),
                      SizedBox(height: 7),
                      ShimmerBar(widthFactor: 0.52, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ShimmerBox(width: 64, height: 22, radius: 11),
              ],
            ),
            SizedBox(height: 9),
            ShimmerBar(widthFactor: 0.66, height: 10),
            Padding(
              padding: EdgeInsets.only(top: 11, bottom: 10),
              child: ShimmerBox(width: double.infinity, height: 1, radius: 0.5),
            ),
            Row(
              children: [
                ShimmerBox(width: 92, height: 15, radius: 7),
                Spacer(),
                ShimmerBox(width: 54, height: 10, radius: 5),
              ],
            ),
          ],
        ),
      );
}
