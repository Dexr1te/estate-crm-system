import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> with LoadGeneration {
  final DealsRepository _repo;

  /// The filter the current list was fetched with, so a reload triggered by a
  /// write re-fetches the same slice instead of silently widening to "all".
  DealStatus? _status;

  DealsBloc(this._repo) : super(DealsInitial()) {
    on<DealsLoadEvent>(_onLoad);
    on<DealsResetEvent>(_onReset);
    on<DealsDeleteEvent>(_onDelete);
    on<DealsCreateEvent>(_onCreate);
    on<DealsUpdateEvent>(_onUpdate);
    on<DealsUpdateStatusEvent>(_onUpdateStatus);
  }

  /// Whatever is currently on screen, so a write's outcome can carry it
  /// forward instead of blanking the list.
  List<DealResponse> get _current {
    final s = state;
    return s is DealsLoaded ? s.deals : const [];
  }

  /// A write failed. Keep whatever is on screen; only a failed *load* leaves
  /// the user with nothing to look at.
  DealsState _failure(Object err) => _current.isEmpty
      ? DealsError(apiErrorMessage(err))
      : DealsActionFailure(apiErrorMessage(err), _current);

  void _reload() => add(DealsLoadEvent(status: _status));

  void _onReset(DealsResetEvent e, Emitter<DealsState> emit) {
    // Invalidate any load still in flight, so a response fetched with the old
    // session's token can't repopulate the list after the reset.
    startLoad();
    _status = null;
    emit(DealsInitial());
  }

  Future<void> _onLoad(DealsLoadEvent e, Emitter<DealsState> emit) async {
    final ticket = startLoad();
    _status = e.status;
    emit(DealsLoading());
    try {
      final deals = await _repo.getDeals(status: e.status);
      // A newer load started while this one was in flight — its result wins.
      if (isStale(ticket)) return;
      emit(DealsLoaded(deals));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(DealsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onDelete(DealsDeleteEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.deleteDeal(e.id);
      emit(DealsActionSuccess('Deal deleted', _current));
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onCreate(DealsCreateEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.createDeal(e.data);
      emit(DealsActionSuccess('Deal created', _current));
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(DealsUpdateEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.updateDeal(e.id, e.data);
      emit(DealsActionSuccess('Deal updated', _current));
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdateStatus(
      DealsUpdateStatusEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.updateDealStatus(e.id, e.status);
      emit(DealsActionSuccess('Status updated', _current));
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }
}
