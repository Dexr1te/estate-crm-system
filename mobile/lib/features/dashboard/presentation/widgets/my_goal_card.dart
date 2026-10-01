import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/goal_ring_card.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_bloc.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_event.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_state.dart';
import 'package:real_estate_crm/features/goals/presentation/widgets/goal_target_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The signed-in person's month on the dashboard, from [MyGoalBloc]. A
/// skeleton while it loads and a failure kept inside the card. Tapping it
/// sets the person's own target, unless the manager's is the one that counts.
class MyGoalCard extends StatelessWidget {
  const MyGoalCard({super.key});

  Future<void> _edit(BuildContext context, GoalProgress goal) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MyGoalBloc>();
    final own = goal.source == 'PERSONAL';
    final draft = await showGoalTargetSheet(
      context,
      title: l10n.goalsSheetTitle,
      subtitle: '${l10n.goalsSheetHint} ${l10n.goalsSheetOwnHint}',
      commissionTarget: own ? goal.commissionTarget : null,
      dealsTarget: own ? goal.dealsTarget : null,
      canRemove: own,
    );
    if (draft == null || bloc.isClosed) return;
    bloc.add(draft.remove
        ? MyGoalClearEvent()
        : MyGoalSaveEvent(
            commissionTarget: draft.commissionTarget,
            dealsTarget: draft.dealsTarget));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyGoalBloc, MyGoalState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final goal = state.goal;
        if (goal != null) {
          return GoalRingCard(
            goal: goal,
            onTap: goal.personalEditable && !state.saving
                ? () => _edit(context, goal)
                : null,
          );
        }
        if (state.status == MyGoalStatus.error) {
          return _GoalFailed(
            onRetry: () => context.read<MyGoalBloc>().add(MyGoalLoadEvent()),
          );
        }
        return const GoalRingCardBone();
      },
    );
  }
}

class _GoalFailed extends StatelessWidget {
  final VoidCallback onRetry;
  const _GoalFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return AppCard(
      key: const ValueKey('goal-failed'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.goalsCardTitle),
          const SizedBox(height: 8),
          Text(
            l10n.goalsLoadFailed,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
          const SizedBox(height: 10),
          AppGhostButton(
            label: l10n.coreRetry,
            onPressed: onRetry,
            height: AppMetrics.buttonHeightInline,
          ),
        ],
      ),
    );
  }
}
