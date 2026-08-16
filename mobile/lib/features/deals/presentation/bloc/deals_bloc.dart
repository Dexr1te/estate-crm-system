import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState>
    with SingleFlight, CollectionBloc<DealsEvent, DealsState> {
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

  DealsState _failure(ApiFailure failure) => _current.isEmpty
      ? DealsError(failure)
      : DealsActionFailure(failure, _current);

  /// A write reloads under the filter the screen is actually showing, not the
  /// unfiltered list.
  void _reload() => add(DealsLoadEvent(status: _status));

  void _onReset(DealsResetEvent e, Emitter<DealsState> emit) {
    invalidate();
    _status = null;
    emit(DealsInitial());
  }

  Future<void> _onLoad(DealsLoadEvent e, Emitter<DealsState> emit) {
    final queryChanged = e.status != _status;
    _status = e.status;

    return load(
      emit,
      keepVisible: _current.isNotEmpty && !queryChanged,
      skeleton: DealsLoading(),
      fetch: () => _repo.getDeals(status: e.status),
      onData: DealsLoaded.new,
      onFailure: DealsError.new,
    );
  }

  Future<void> _act(Emitter<DealsState> emit, String key, ActionMessage success,
          Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) => DealsActionSuccess(success, _current),
        onFailure: _failure,
        reload: _reload,
      );

  Future<void> _onDelete(DealsDeleteEvent e, Emitter<DealsState> emit) => _act(
      emit,
      'delete-${e.id}',
      ActionMessage.dealDeleted,
      () => _repo.deleteDeal(e.id));

  Future<void> _onCreate(DealsCreateEvent e, Emitter<DealsState> emit) => _act(
      emit,
      'create-${e.data['clientId']}-${e.data['propertyId']}',
      ActionMessage.dealCreated,
      () => _repo.createDeal(e.data));

  Future<void> _onUpdate(DealsUpdateEvent e, Emitter<DealsState> emit) => _act(
      emit,
      'update-${e.id}',
      ActionMessage.dealUpdated,
      () => _repo.updateDeal(e.id, e.data));

  Future<void> _onUpdateStatus(
          DealsUpdateStatusEvent e, Emitter<DealsState> emit) =>
      _act(emit, 'status-${e.id}-${e.status.name}', ActionMessage.statusUpdated,
          () => _repo.updateDealStatus(e.id, e.status));
}
