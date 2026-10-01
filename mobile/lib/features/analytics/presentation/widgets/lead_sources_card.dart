import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/analytics_bar.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/lead_source.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Where clients come from": each channel's share of the period's new
/// clients, and how many of them have a won deal.
class LeadSourcesCard extends StatelessWidget {
  final LeadSourceBreakdown breakdown;
  const LeadSourcesCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final rows = breakdown.sources;
    final total = breakdown.clients;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.analyticsLeadSources),
          const SizedBox(height: 6),
          Text(
            rows.isEmpty
                ? l10n.analyticsNoClients
                : l10n.analyticsLeadSourcesHint,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.35,
                color: t.textSecondary),
          ),
          for (final row in rows) ...[
            const SizedBox(height: 14),
            AnalyticsBarRow(
              key: ValueKey('lead-source-${row.source}'),
              label: leadSourceLabel(l10n, leadSourceFromName(row.source)),
              value: '${row.clients}',
              caption: l10n.analyticsLeadSourceWon(row.won,
                  percentLabel(row.conversionRate, l10n.analyticsNoValue)),
              fraction: total == 0 ? 0 : row.clients / total,
              color: t.primary,
            ),
          ],
        ],
      ),
    );
  }
}
