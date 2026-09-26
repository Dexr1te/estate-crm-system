import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/analytics_bar.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class FunnelCard extends StatelessWidget {
  final DealFunnel funnel;
  const FunnelCard({super.key, required this.funnel});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final none = l10n.analyticsNoValue;
    final total = funnel.created == 0 ? 1 : funnel.created;
    final won = StatusPalette.resolve(t, StatusHue.positive).label;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.analyticsFunnel),
          const SizedBox(height: 14),
          AnalyticsBarRow(
            key: const ValueKey('funnel-lead'),
            label: dealStatusLabel(l10n, DealStatus.LEAD),
            value: '${funnel.created}',
            fraction: 1,
            color: t.textSecondary,
          ),
          const SizedBox(height: 14),
          AnalyticsBarRow(
            key: const ValueKey('funnel-negotiation'),
            label: dealStatusLabel(l10n, DealStatus.NEGOTIATION),
            value: '${funnel.reachedNegotiation}',
            fraction: funnel.reachedNegotiation / total,
            color: t.textSecondary,
            caption: l10n.analyticsOfPrevious(
                percentLabel(funnel.leadToNegotiationRate, none)),
          ),
          const SizedBox(height: 14),
          AnalyticsBarRow(
            key: const ValueKey('funnel-won'),
            label: dealStatusLabel(l10n, DealStatus.CLOSED_WON),
            value: '${funnel.won}',
            fraction: funnel.won / total,
            color: won,
            caption: l10n.analyticsOfPrevious(
                percentLabel(funnel.negotiationToWonRate, none)),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: t.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.analyticsWonLost(funnel.lost, funnel.won),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${l10n.analyticsLeadToWon} '
                  '${percentLabel(funnel.leadToWonRate, none)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
