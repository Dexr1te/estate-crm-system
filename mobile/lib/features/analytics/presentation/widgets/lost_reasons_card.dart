import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/analytics_bar.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class LostReasonsCard extends StatelessWidget {
  final List<FunnelLostReason> reasons;
  const LostReasonsCard({super.key, required this.reasons});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final lost = StatusPalette.resolve(t, StatusHue.danger).label;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.analyticsLostReasons),
          const SizedBox(height: 14),
          if (reasons.isEmpty)
            Text(
              l10n.analyticsNoLost,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            )
          else
            for (var i = 0; i < reasons.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              AnalyticsBarRow(
                key: ValueKey('lost-${reasons[i].reason}'),
                label: dealLostReasonLabel(
                    l10n, dealLostReasonFromName(reasons[i].reason)),
                value: '${reasons[i].count} · '
                    '${percentLabel(reasons[i].share, l10n.analyticsNoValue)}',
                fraction: reasons[i].share,
                color: lost,
              ),
            ],
        ],
      ),
    );
  }
}
