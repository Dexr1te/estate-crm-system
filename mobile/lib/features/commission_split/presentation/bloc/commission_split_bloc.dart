import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';
import 'package:real_estate_crm/features/commission_split/domain/repositories/commission_split_repository.dart';

abstract class CommissionSplitEvent {}

/// Loads, or reloads, the deal's split.
class CommissionSplitLoadEvent extends CommissionSplitEvent {}

class CommissionSplitSaveEvent extends CommissionSplitEvent {
  final CommissionSplitDraft draft;
  CommissionSplitSaveEvent(this.draft);
}

/// Back to the whole commission for the deal's agent.
class CommissionSplitClearEvent extends CommissionSplitEvent {}

enum CommissionSplitStatus { loading, loaded, error }

/// A write the server refused; the split stays as it was.
class CommissionSplitWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  CommissionSplitWriteFailed(this.failure);
}

class CommissionSplitState {
  final CommissionSplitStatus status;
  final CommissionSplit? split;
  final bool saving;

  /// Bumped on every write the server took, so the screen can refresh what
  /// the write touched (the deal's change history).
  final int saved;
  final ApiFailure? loadFailure;
  final CommissionSplitWriteFailed? outcome;

  const CommissionSplitState({
    this.status = CommissionSplitStatus.loading,
    this.split,
    this.saving = false,
    this.saved = 0,
    this.loadFailure,
    this.outcome,
  });

  CommissionSplitState copyWith({
    CommissionSplitStatus? status,
    CommissionSplit? split,
    bool? saving,
    int? saved,
    ApiFailure? loadFailure,
    CommissionSplitWriteFailed? outcome,
  }) =>
      CommissionSplitState(
        status: status ?? this.status,
        split: split ?? this.split,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        loadFailure: loadFailure ?? this.loadFailure,
        outcome: outcome,
      );
}

/// One deal's commission split, and the writes made on it from its card.
class CommissionSplitBloc
    extends Bloc<CommissionSplitEvent, CommissionSplitState> {
  final CommissionSplitRepository _repo;
  final int dealId;

  CommissionSplitBloc(this._repo, {required this.dealId})
      : super(const CommissionSplitState()) {
    on<CommissionSplitLoadEvent>(_onLoad);
    on<CommissionSplitSaveEvent>(
        (e, emit) => _write(emit, () => _repo.saveSplit(dealId, e.draft)));
    on<CommissionSplitClearEvent>(
        (e, emit) => _write(emit, () => _repo.clearSplit(dealId)));
  }

  Future<void> _onLoad(
      CommissionSplitLoadEvent e, Emitter<CommissionSplitState> emit) async {
    if (state.status != CommissionSplitStatus.loaded) {
      emit(state.copyWith(status: CommissionSplitStatus.loading));
    }
    try {
      final split = await _repo.getSplit(dealId);
      emit(state.copyWith(status: CommissionSplitStatus.loaded, split: split));
    } catch (error) {
      final failure = ApiFailure.from(error);
      emit(state.status == CommissionSplitStatus.loaded
          ? state.copyWith(outcome: CommissionSplitWriteFailed(failure))
          : state.copyWith(
              status: CommissionSplitStatus.error, loadFailure: failure));
    }
  }

  Future<void> _write(Emitter<CommissionSplitState> emit,
      Future<CommissionSplit> Function() call) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final split = await call();
      emit(state.copyWith(
          status: CommissionSplitStatus.loaded,
          split: split,
          saving: false,
          saved: state.saved + 1));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: CommissionSplitWriteFailed(ApiFailure.from(error))));
    }
  }
}
