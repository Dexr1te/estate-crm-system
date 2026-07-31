import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Bottom sheet showing aggregated statistics for a team, as one metrics card
/// with hairline dividers — not tinted tiles.
void showTeamStatsSheet(BuildContext context, int teamId) {
  showAppBottomSheet(context, builder: (_) => _TeamStats(teamId: teamId));
}

class _TeamStats extends StatelessWidget {
  final int teamId;
  const _TeamStats({required this.teamId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return FutureBuilder<TeamStatsResponse>(
      future: Injector.teamsRepository.getTeamStats(teamId),
      builder: (ctx, snap) {
        final l10n = AppLocalizations.of(ctx);

        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
              height: 160, child: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || !snap.hasData) {
          return SizedBox(
            height: 160,
            child: Center(
              child: Text(
                l10n.teamsCouldNotLoadStats,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary),
              ),
            ),
          );
        }

        final s = snap.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: t.border, width: AppMetrics.borderWidth),
                  ),
                  child:
                      Icon(Icons.groups_outlined, size: 18, color: t.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary),
                      ),
                      if (s.managerName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          l10n.teamsManagerLabel(s.managerName!),
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
                ),
              ],
            ),
            SizedBox(height: AppMetrics.blockGap(context)),
            MetricsCard(metrics: [
              Metric(value: '${s.totalAgents}', caption: l10n.teamsAgents),
              Metric(value: '${s.totalClients}', caption: l10n.teamsClients),
              Metric(value: '${s.totalDeals}', caption: l10n.teamsDeals),
              Metric(value: '${s.activeDeals}', caption: l10n.teamsActive),
              Metric(
                  value: '${s.upcomingMeetings}', caption: l10n.teamsUpcoming),
            ]),
          ],
        );
      },
    );
  }
}
