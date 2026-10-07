import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/domain/repositories/deposits_repository.dart';

abstract class DealDepositsEvent {}

class DealDepositsLoadEvent extends DealDepositsEvent {}

class DealDepositsRecordEvent extends DealDepositsEvent {
  final DepositDraft draft;
  DealDepositsRecordEvent(this.draft);
}

class DealDepositsUpdateEvent extends DealDepositsEvent {
  final int depositId;
  final DepositDraft draft;
  DealDepositsUpdateEvent(this.depositId, this.draft);
}

class DealDepositsCloseEvent extends DealDepositsEvent {
  final int depositId;
  final DepositClosing closing;
  DealDepositsCloseEvent(this.depositId, this.closing);
}

enum DealDepositsStatus { loading, loaded, error }

/// A write the server refused; the list stays as it was.
class DealDepositWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  DealDepositWriteFailed(this.failure);
}

class DealDepositsState {
  final DealDepositsStatus status;

  /// The latest first, as the server sends them.
  final List<DealDeposit> deposits;
  final bool saving;

  /// Bumped on every write the server took, so the screen can refresh what
  /// the write touched (the discussion line it added).
  final int saved;
  final ApiFailure? loadFailure;
  final DealDepositWriteFailed? outcome;

  const DealDepositsState({
    this.status = DealDepositsStatus.loading,
    this.deposits = const [],
    this.saving = false,
    this.saved = 0,
    this.loadFailure,
    this.outcome,
  });

  DealDeposit? get active => activeDeposit(deposits);

  DealDepositsState copyWith({
    DealDepositsStatus? status,
    List<DealDeposit>? deposits,
    bool? saving,
    int? saved,
    ApiFailure? loadFailure,
    DealDepositWriteFailed? outcome,
  }) =>
      DealDepositsState(
        status: status ?? this.status,
        deposits: deposits ?? this.deposits,
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        loadFailure: loadFailure ?? this.loadFailure,
        outcome: outcome,
      );
}

/// The deposits of one deal, and the writes made on them from its card.
class DealDepositsBloc extends Bloc<DealDepositsEvent, DealDepositsState> {
  final DepositsRepository _repo;
  final int dealId;

  DealDepositsBloc(this._repo, {required this.dealId})
      : super(const DealDepositsState()) {
    on<DealDepositsLoadEvent>(_onLoad);
    on<DealDepositsRecordEvent>((e, emit) => _write(
        emit,
        () => _repo.record(dealId, e.draft),
        (saved) => [saved, ...state.deposits]));
    on<DealDepositsUpdateEvent>((e, emit) => _write(
        emit,
        () => _repo.update(dealId, e.depositId, e.draft),
        (saved) => _replace(saved)));
    on<DealDepositsCloseEvent>((e, emit) => _write(
        emit,
        () => _repo.close(dealId, e.depositId, e.closing),
        (saved) => _replace(saved)));
  }

  Future<void> _onLoad(
      DealDepositsLoadEvent e, Emitter<DealDepositsState> emit) async {
    if (state.status != DealDepositsStatus.loaded) {
      emit(state.copyWith(status: DealDepositsStatus.loading));
    }
    try {
      final deposits = await _repo.getDealDeposits(dealId);
      emit(state.copyWith(
          status: DealDepositsStatus.loaded, deposits: deposits));
    } catch (error) {
      final failure = ApiFailure.from(error);
      emit(state.status == DealDepositsStatus.loaded
          ? state.copyWith(outcome: DealDepositWriteFailed(failure))
          : state.copyWith(
              status: DealDepositsStatus.error, loadFailure: failure));
    }
  }

  Future<void> _write(
    Emitter<DealDepositsState> emit,
    Future<DealDeposit> Function() call,
    List<DealDeposit> Function(DealDeposit saved) apply,
  ) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final saved = await call();
      emit(state.copyWith(
          deposits: apply(saved), saving: false, saved: state.saved + 1));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: DealDepositWriteFailed(ApiFailure.from(error))));
    }
  }

  List<DealDeposit> _replace(DealDeposit next) =>
      [for (final d in state.deposits) d.id == next.id ? next : d];
}
