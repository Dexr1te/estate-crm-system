import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> with LoadGeneration {
  final DealsRepository _repo;

  DealStatus? _status;

  DealsBloc(this._repo) : super(DealsInitial()) {
    on<DealsLoadEvent>(_onLoad);
    on<DealsResetEvent>(_onReset);
    on<DealsDeleteEvent>(_onDelete);
    on<DealsCreateEvent>(_onCreate);
    on<DealsUpdateEvent>(_onUpdate);
    on<DealsUpdateStatusEvent>(_onUpdateStatus);
  }

  List<DealResponse> get _current {
    final s = state;
    return s is DealsLoaded ? s.deals : const [];
  }

  DealsState _failure(Object err) => _current.isEmpty
      ? DealsError(apiErrorMessage(err))
      : DealsActionFailure(apiErrorMessage(err), _current);

  void _reload() => add(DealsLoadEvent(status: _status));

  void _onReset(DealsResetEvent e, Emitter<DealsState> emit) {
    startLoad();
    _status = null;
    emit(DealsInitial());
  }

  Future<void> _onLoad(DealsLoadEvent e, Emitter<DealsState> emit) async {
    final ticket = startLoad();
    final queryChanged = e.status != _status;
    _status = e.status;

    if (_current.isEmpty || queryChanged) emit(DealsLoading());
    try {
      final deals = await _repo.getDeals(status: e.status);
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
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(DealsUpdateEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.updateDeal(e.id, e.data);
      emit(DealsActionSuccess('Deal updated', _current));
      _reload();
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
