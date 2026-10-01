import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum TeamGoalsStatus { loading, loaded, error }

/// The first day of the month [at] falls in.
DateTime monthOf(DateTime at) => DateTime(at.year, at.month);

/// "2026-10", as the server writes a month.
String monthParam(DateTime month) => '${month.year.toString().padLeft(4, '0')}-'
    '${month.month.toString().padLeft(2, '0')}';

class TeamGoalsState {
  final TeamGoalsStatus status;

  /// The first day of the month on screen.
  final DateTime month;
  final TeamGoals? goals;
  final bool saving;
  final ApiFailure? loadFailure;
  final ActionOutcome? outcome;

  const TeamGoalsState({
    required this.month,
    this.status = TeamGoalsStatus.loading,
    this.goals,
    this.saving = false,
    this.loadFailure,
    this.outcome,
  });

  /// A month that is over keeps its targets: the server refuses to change
  /// them, so the screen does not offer to.
  bool get editable => !month.isBefore(monthOf(AppClock.now()));

  TeamGoalsState copyWith({
    TeamGoalsStatus? status,
    DateTime? month,
    TeamGoals? goals,
    bool clearGoals = false,
    bool? saving,
    ApiFailure? loadFailure,
    ActionOutcome? outcome,
  }) =>
      TeamGoalsState(
        status: status ?? this.status,
        month: month ?? this.month,
        goals: clearGoals ? null : goals ?? this.goals,
        saving: saving ?? this.saving,
        loadFailure: loadFailure,
        outcome: outcome,
      );
}

/// Last month's targets came over; [count] says how many.
class GoalsCopied with ActionOutcome {
  final int count;
  GoalsCopied(this.count);

  @override
  String text(AppLocalizations l10n) => l10n.goalsCopied(count);

  @override
  bool get isFailure => false;
}
