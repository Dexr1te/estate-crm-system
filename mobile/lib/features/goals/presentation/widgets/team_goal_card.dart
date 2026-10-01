import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/goals/domain/goal_pace.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One line of the manager's month: a member's (or the agency's, under
/// [title]) target, what the month's won deals have brought against it, and
/// the pace still needed. Tapping it edits the manager's target.
class TeamGoalCard extends StatelessWidget {
  final GoalProgress goal;
  final String title;

  /// Whether the month can still change; a month gone shows no pace.
  final bool current;
  final VoidCallback? onTap;

  const TeamGoalCard({
    super.key,
    required this.goal,
    required this.title,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final commissionTarget = goal.commissionTarget;
    final dealsTarget = goal.dealsTarget;
    final label = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12, color: t.textSecondary);
    final value = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: t.textPrimary);

    Widget line(String name, String figure, Key key) => Row(
          children: [
            Expanded(
              child: Text(name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: label),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Text(figure,
                  key: key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: value),
            ),
          ],
        );

    String? pace;
    if (goal.hasTarget) {
      if (goalReached(goal)) {
        pace = l10n.goalsReached;
      } else if (current) {
        pace = goalPace(l10n, goal);
      }
    }

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              if (goal.source == 'PERSONAL') ...[
                const SizedBox(width: 8),
                Flexible(
                  child: StatusChip(
                      label: l10n.goalsAgentOwn, hue: StatusHue.neutral),
                ),
              ] else if (!goal.hasTarget) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.goalsNoTarget,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textHint),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          line(
            l10n.goalsCommissionLabel,
            commissionTarget != null
                ? l10n.goalsCommissionOf(formatPrice(goal.commissionAchieved),
                    formatPrice(commissionTarget))
                : formatPrice(goal.commissionAchieved),
            ValueKey('goal-commission-${goal.agentId ?? 'agency'}'),
          ),
          if (commissionTarget != null) ...[
            const SizedBox(height: 6),
            GoalBar(fraction: (goal.commissionPercent ?? 0) / 100),
          ],
          const SizedBox(height: 8),
          line(
            l10n.goalsDealsLabel,
            dealsTarget != null
                ? '${goal.dealsWon} / $dealsTarget'
                : '${goal.dealsWon}',
            ValueKey('goal-deals-${goal.agentId ?? 'agency'}'),
          ),
          if (dealsTarget != null) ...[
            const SizedBox(height: 6),
            GoalBar(fraction: (goal.dealsPercent ?? 0) / 100),
          ],
          if (pace != null) ...[
            const SizedBox(height: 10),
            Text(
              pace,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  height: 1.35,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// A thin bar for how much of a target is done; full once it is met.
class GoalBar extends StatelessWidget {
  final double fraction;
  const GoalBar({super.key, required this.fraction});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final done = fraction.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: t.chartTrack)),
            FractionallySizedBox(
              widthFactor: done,
              heightFactor: 1,
              child: ColoredBox(color: done >= 1 ? t.chartWon : t.primary),
            ),
          ],
        ),
      ),
    );
  }
}
