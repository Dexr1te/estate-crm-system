import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Bottom sheet showing a single agent's work statistics, as one metrics card
/// with hairline dividers — not tinted tiles.
void showUserStatsSheet(BuildContext context, int userId) {
  showAppBottomSheet(
    context,
    builder: (_) => _UserStats(userId: userId),
  );
}

class _UserStats extends StatelessWidget {
  final int userId;
  const _UserStats({required this.userId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return FutureBuilder<AgentStatsResponse>(
      future: Injector.adminRepository.getUserStats(userId),
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
                l10n.adminCouldNotLoadStats,
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
                InitialAvatar(name: s.fullName, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppMetrics.blockGap(context)),
            MetricsCard(metrics: [
              Metric(
                  value: '${s.totalClients}', caption: l10n.adminStatClients),
              Metric(value: '${s.totalDeals}', caption: l10n.adminStatDeals),
              Metric(value: '${s.activeDeals}', caption: l10n.adminStatActive),
              Metric(value: '${s.closedDeals}', caption: l10n.adminStatClosed),
              Metric(
                  value: '${s.upcomingMeetings}',
                  caption: l10n.adminStatUpcoming),
            ]),
          ],
        );
      },
    );
  }
}
