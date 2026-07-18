import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> {
  final DealsRepository _repo;
  DealsBloc(this._repo) : super(DealsInitial()) {
    on<DealsLoadEvent>(_onLoad);
    on<DealsDeleteEvent>(_onDelete);
    on<DealsCreateEvent>(_onCreate);
    on<DealsUpdateEvent>(_onUpdate);
    on<DealsUpdateStatusEvent>(_onUpdateStatus);
  }
  Future<void> _onLoad(DealsLoadEvent e, Emitter<DealsState> emit) async {
    emit(DealsLoading());
    try {
      emit(DealsLoaded(await _repo.getDeals(status: e.status)));
    } catch (err) {
      emit(DealsError(err.toString()));
    }
  }

  Future<void> _onDelete(DealsDeleteEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.deleteDeal(e.id);
      emit(DealsActionSuccess('Deal deleted'));
      add(DealsLoadEvent());
    } catch (err) {
      emit(DealsError(err.toString()));
    }
  }

  Future<void> _onCreate(DealsCreateEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.createDeal(e.data);
      emit(DealsActionSuccess('Deal created'));
    } catch (err) {
      emit(DealsError(err.toString()));
    }
  }

  Future<void> _onUpdate(DealsUpdateEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.updateDeal(e.id, e.data);
      emit(DealsActionSuccess('Deal updated'));
    } catch (err) {
      emit(DealsError(err.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      DealsUpdateStatusEvent e, Emitter<DealsState> emit) async {
    try {
      await _repo.updateDealStatus(e.id, e.status);
      emit(DealsActionSuccess('Status updated'));
      add(DealsLoadEvent());
    } catch (err) {
      emit(DealsError(err.toString()));
    }
  }
}
