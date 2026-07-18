import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

/// Bottom sheet showing aggregated statistics for a team.
void showTeamStatsSheet(BuildContext context, int teamId) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => FutureBuilder<TeamStatsResponse>(
      future: Injector.teamsRepository.getTeamStats(teamId),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
              height: 180, child: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || !snap.hasData) {
          return const SizedBox(
              height: 180,
              child: Center(child: Text('Could not load stats')));
        }
        final s = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.teamName, style: Theme.of(ctx).textTheme.titleLarge),
              if (s.managerName != null)
                Text('Manager: ${s.managerName}',
                    style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _Stat('Agents', s.totalAgents, Icons.badge_outlined,
                      AppColors.info),
                  _Stat('Clients', s.totalClients, Icons.people_outline,
                      AppColors.accent),
                  _Stat('Deals', s.totalDeals, Icons.handshake_outlined,
                      AppColors.warning),
                  _Stat('Active', s.activeDeals, Icons.trending_up,
                      AppColors.success),
                  _Stat('Upcoming', s.upcomingMeetings,
                      Icons.calendar_today_outlined, AppColors.lead),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: tt.bodySmall),
          ],
        ),
      ]),
    );
  }
}
