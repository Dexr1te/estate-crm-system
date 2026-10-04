import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/split_labels.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/team_goals_bloc.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/team_goals_event.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/team_goals_state.dart';
import 'package:real_estate_crm/features/goals/presentation/widgets/goal_target_sheet.dart';
import 'package:real_estate_crm/features/goals/presentation/widgets/team_goal_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager sets each member's monthly target and the agency's, sees how
/// far everybody has got, and brings last month's targets forward.
class TeamGoalsScreen extends StatelessWidget {
  const TeamGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            TeamGoalsBloc(Injector.goalsRepository)..add(TeamGoalsLoadEvent()),
        child: const _TeamGoalsView(),
      );
}

/// "October 2026", the way the reader's language names a month on its own.
String goalMonthLabel(DateTime month, String locale) {
  final resolved = DateFormat.localeExists(locale) ? locale : 'en';
  final text = DateFormat('LLLL y', resolved).format(month);
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

class _TeamGoalsView extends StatelessWidget {
  const _TeamGoalsView();

  /// How far ahead the manager can plan: next month, no further.
  static bool _canGoForward(DateTime month) =>
      month.isBefore(DateTime(AppClock.now().year, AppClock.now().month + 1));

  Future<void> _edit(BuildContext context, GoalProgress goal, String name,
      {required bool agency}) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TeamGoalsBloc>();
    final managers = goal.source == 'MANAGER';
    final draft = await showGoalTargetSheet(
      context,
      title: agency ? l10n.goalsAgency : l10n.goalsSheetFor(name),
      subtitle: agency
          ? l10n.goalsSheetHint
          : '${l10n.goalsSheetHint} ${l10n.goalsTeamOverrideHint}',
      commissionTarget: managers ? goal.commissionTarget : null,
      dealsTarget: managers ? goal.dealsTarget : null,
      canRemove: managers,
    );
    if (draft == null || bloc.isClosed) return;
    bloc.add(draft.remove
        ? TeamGoalsClearEvent(agentId: goal.agentId)
        : TeamGoalsSaveEvent(
            agentId: goal.agentId,
            commissionTarget: draft.commissionTarget,
            dealsTarget: draft.dealsTarget));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamGoalsBloc, TeamGoalsState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final t = context.tokens;
        final bloc = context.read<TeamGoalsBloc>();
        final goals = state.goals;
        final loaded = state.status == TeamGoalsStatus.loaded && goals != null;
        final editable = state.editable && !state.saving;
        final locale = Localizations.localeOf(context).toLanguageTag();

        return DetailScaffold(
          title: l10n.goalsTeamTitle,
          onRefresh: () async => bloc.add(TeamGoalsLoadEvent()),
          bottomAction: loaded && state.editable
              ? AppGhostButton(
                  key: const Key('goals-copy'),
                  label: l10n.goalsCopyPrevious,
                  icon: Icons.content_copy_rounded,
                  onPressed: state.saving
                      ? null
                      : () => bloc.add(TeamGoalsCopyPreviousEvent()),
                )
              : null,
          children: [
            Text(
              l10n.goalsTeamIntro,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.textSecondary),
            ),
            _MonthSwitcher(
              label: goalMonthLabel(state.month, locale),
              detail: loaded && state.editable
                  ? l10n.goalsDaysLeft(goals.daysLeft)
                  : null,
              onPrevious: () => bloc.add(TeamGoalsMonthEvent(-1)),
              onNext: _canGoForward(state.month)
                  ? () => bloc.add(TeamGoalsMonthEvent(1))
                  : null,
              previousTooltip: l10n.goalsPreviousMonth,
              nextTooltip: l10n.goalsNextMonth,
            ),
            if (!state.editable)
              Text(
                l10n.goalsMonthOver,
                key: const Key('goals-month-over'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans, fontSize: 12, color: t.textHint),
              ),
            if (state.status == TeamGoalsStatus.loading) const _GoalBones(),
            if (state.status == TeamGoalsStatus.error)
              EmptyState(
                icon: Icons.flag_outlined,
                title: l10n.goalsLoadFailed,
                action: AppGhostButton(
                  label: l10n.coreRetry,
                  onPressed: () => bloc.add(TeamGoalsLoadEvent()),
                ),
              ),
            if (loaded) ...[
              TeamGoalCard(
                key: const ValueKey('goal-agency'),
                goal: goals.agency,
                title: l10n.goalsAgency,
                current: state.editable,
                onTap: editable
                    ? () => _edit(context, goals.agency, l10n.goalsAgency,
                        agency: true)
                    : null,
              ),
              const CommissionShareNote(),
              SectionHeader(title: l10n.teamsMembers),
              if (goals.agents.isEmpty)
                EmptyState(
                    icon: Icons.groups_outlined, title: l10n.goalsTeamEmpty),
              for (final agent in goals.agents)
                TeamGoalCard(
                  key: ValueKey('goal-agent-${agent.agentId}'),
                  goal: agent,
                  title: agent.agentName ?? '',
                  current: state.editable,
                  onTap: editable
                      ? () => _edit(context, agent, agent.agentName ?? '',
                          agency: false)
                      : null,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  final String label;
  final String? detail;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  const _MonthSwitcher({
    required this.label,
    required this.detail,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final next = onNext;
    return Row(
      children: [
        AppIconTile(
          key: const Key('goals-month-previous'),
          icon: Icons.chevron_left_rounded,
          tooltip: previousTooltip,
          onPressed: onPrevious,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                label,
                key: const Key('goals-month'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  detail!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (next != null)
          AppIconTile(
            key: const Key('goals-month-next'),
            icon: Icons.chevron_right_rounded,
            tooltip: nextTooltip,
            onPressed: next,
          )
        else
          const SizedBox(width: AppMetrics.minHitTarget),
      ],
    );
  }
}

class _GoalBones extends StatelessWidget {
  const _GoalBones();

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Bone(),
            SizedBox(height: 14),
            _Bone(),
            SizedBox(height: 14),
            _Bone(),
          ],
        ),
      );
}

class _Bone extends StatelessWidget {
  const _Bone();

  @override
  Widget build(BuildContext context) => const ShimmerCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBar(widthFactor: 0.45, height: 13),
            SizedBox(height: 12),
            ShimmerBar(widthFactor: 0.9),
            SizedBox(height: 8),
            ShimmerBar(widthFactor: 0.7),
          ],
        ),
      );
}
