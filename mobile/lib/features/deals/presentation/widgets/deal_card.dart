import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A deal in the list: title with its stage chip, the client/agent line, a
/// hairline divider, then the amount with right-hand context — budget, or a
/// red staleness warning when the deal has gone quiet.
class DealCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onTap;

  /// A deal untouched for this long is called out in red.
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

    final staleDays = _staleDays(deal);
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
                  staleDays != null
                      ? l10n.dealsStaleWarning(staleDays)
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
                        staleDays != null ? FontWeight.w600 : FontWeight.w400,
                    color: staleDays != null
                        ? t.dangerText
                        : t.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Days since the deal last moved — null when it is closed or still fresh.
  static int? _staleDays(DealResponse deal) {
    if (deal.status == DealStatus.CLOSED_WON ||
        deal.status == DealStatus.CLOSED_LOST) {
      return null;
    }
    final last = deal.updatedAt ?? deal.createdAt;
    if (last == null) return null;
    final days = DateTime.now().difference(last).inDays;
    return days >= staleAfter.inDays ? days : null;
  }
}

/// Skeleton matching [DealCard]'s footprint.
class DealCardBone extends StatelessWidget {
  const DealCardBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerBox(
      width: double.infinity, height: 116, radius: AppMetrics.radiusMd);
}
