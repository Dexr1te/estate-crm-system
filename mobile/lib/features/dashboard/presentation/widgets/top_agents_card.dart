import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class TopAgentsCard extends StatelessWidget {
  final List<AgentTotal> agents;
  const TopAgentsCard({super.key, required this.agents});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final peak = agents.isEmpty ? 0.0 : agents.first.value;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dashboardTopAgents),
          const SizedBox(height: 14),
          for (var i = 0; i < agents.length; i++) ...[
            if (i > 0) const SizedBox(height: 11),
            _AgentRow(agent: agents[i], peak: peak, rank: i),
          ],
        ],
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  final AgentTotal agent;
  final double peak;
  final int rank;
  const _AgentRow(
      {required this.agent, required this.peak, required this.rank});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final fraction = peak <= 0 ? 0.0 : (agent.value / peak).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InitialAvatar(name: agent.name, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                agent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: t.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                formatPrice(agent.value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: t.chartTrack)),
                      FractionallySizedBox(
                        widthFactor: fraction.clamp(0.04, 1.0),
                        child: ColoredBox(
                            color: rank == 0 ? t.chartWon : t.chartLead),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.dashboardAgentDeals(agent.deals),
              maxLines: 1,
              style: TextStyle(
                  fontFamily: AppFonts.sans, fontSize: 10.5, color: t.textHint),
            ),
          ],
        ),
      ],
    );
  }
}
