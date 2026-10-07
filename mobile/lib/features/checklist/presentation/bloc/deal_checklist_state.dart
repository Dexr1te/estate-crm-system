import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

enum DealChecklistStatus { loading, loaded, error }

class DealChecklistState {
  final DealChecklistStatus status;

  /// By stage, then position — the order the server keeps.
  final List<ChecklistItem> items;

  /// Lines with a write on its way.
  final Set<int> busyIds;
  final bool adding;
  final ApiFailure? loadFailure;

  /// What the last write came to, for a snackbar; each one is a new object.
  final ActionOutcome? outcome;

  const DealChecklistState({
    this.status = DealChecklistStatus.loading,
    this.items = const [],
    this.busyIds = const {},
    this.adding = false,
    this.loadFailure,
    this.outcome,
  });

  List<ChecklistItem> itemsOf(ChecklistStage stage) =>
      items.where((i) => i.stage == stage).toList();

  DealChecklistState copyWith({
    DealChecklistStatus? status,
    List<ChecklistItem>? items,
    Set<int>? busyIds,
    bool? adding,
    ApiFailure? loadFailure,
    ActionOutcome? outcome,
  }) =>
      DealChecklistState(
        status: status ?? this.status,
        items: items ?? this.items,
        busyIds: busyIds ?? this.busyIds,
        adding: adding ?? this.adding,
        loadFailure: loadFailure,
        outcome: outcome,
      );
}

class DealChecklistWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  DealChecklistWriteFailed(this.failure);
}
