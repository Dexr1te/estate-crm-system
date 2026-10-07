import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum MyGoalStatus { loading, loaded, error }

class MyGoalState {
  final MyGoalStatus status;
  final GoalProgress? goal;
  final bool saving;
  final ActionOutcome? outcome;

  const MyGoalState({
    this.status = MyGoalStatus.loading,
    this.goal,
    this.saving = false,
    this.outcome,
  });

  MyGoalState copyWith({
    MyGoalStatus? status,
    GoalProgress? goal,
    bool? saving,
    ActionOutcome? outcome,
  }) =>
      MyGoalState(
        status: status ?? this.status,
        goal: goal ?? this.goal,
        saving: saving ?? this.saving,
        outcome: outcome,
      );
}

/// A target was saved or taken off.
class GoalSaved with ActionOutcome {
  final bool removed;
  GoalSaved({this.removed = false});

  @override
  String text(AppLocalizations l10n) =>
      removed ? l10n.goalsRemoved : l10n.goalsSaved;

  @override
  bool get isFailure => false;
}

class GoalWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  GoalWriteFailed(this.failure);
}
