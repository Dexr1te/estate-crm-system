import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final PropertiesRepository _repo;
  static const _pageSize = 20;

  // Active filters + paging cursor, retained across load-more/reload.
  PropertyStatus? _status;
  PropertyType? _type;
  String? _search;
  int _page = 0;
  bool _hasMore = false;
  final List<PropertyResponse> _items = [];

  PropertiesBloc(this._repo) : super(PropertiesInitial()) {
    on<PropertiesLoadEvent>(_onLoad);
    on<PropertiesLoadMoreEvent>(_onLoadMore);
    on<PropertiesDeleteEvent>(_onDelete);
    on<PropertiesCreateEvent>(_onCreate);
    on<PropertiesUpdateEvent>(_onUpdate);
    on<PropertiesUpdateStatusEvent>(_onUpdateStatus);
  }

  // Reload the first page, keeping the current filters.
  void _reload() => add(PropertiesLoadEvent(
      status: _status, type: _type, search: _search));

  Future<void> _onLoad(
      PropertiesLoadEvent e, Emitter<PropertiesState> emit) async {
    _status = e.status;
    _type = e.type;
    _search = e.search;
    _page = 0;
    _items.clear();
    _hasMore = false;
    emit(PropertiesLoading());
    try {
      final res = await _repo.getProperties(
          status: _status,
          type: _type,
          search: _search,
          page: 0,
          size: _pageSize);
      _items.addAll(res.content);
      _page = res.page;
      _hasMore = res.hasMore;
      emit(PropertiesLoaded(List.of(_items), hasMore: _hasMore));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onLoadMore(
      PropertiesLoadMoreEvent e, Emitter<PropertiesState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is PropertiesLoaded && current.isLoadingMore) return;

    emit(PropertiesLoaded(List.of(_items),
        hasMore: _hasMore, isLoadingMore: true));
    try {
      final res = await _repo.getProperties(
          status: _status,
          type: _type,
          search: _search,
          page: _page + 1,
          size: _pageSize);
      _page = res.page;
      _hasMore = res.hasMore;
      _items.addAll(res.content);
      emit(PropertiesLoaded(List.of(_items), hasMore: _hasMore));
    } catch (_) {
      // Keep the loaded items and stop the footer spinner.
      emit(PropertiesLoaded(List.of(_items), hasMore: _hasMore));
    }
  }

  Future<void> _onDelete(
      PropertiesDeleteEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.deleteProperty(e.id);
      emit(PropertiesActionSuccess('Property deleted'));
      _reload();
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onCreate(
      PropertiesCreateEvent e, Emitter<PropertiesState> emit) async {
    try {
      final created = await _repo.createProperty(e.data);
      emit(PropertyCreated(created)); // emit the full object with id
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdate(
      PropertiesUpdateEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updateProperty(e.id, e.data);
      emit(PropertiesActionSuccess('Property updated'));
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      PropertiesUpdateStatusEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updatePropertyStatus(e.id, e.status);
      emit(PropertiesActionSuccess('Status updated'));
      _reload();
    } catch (err) {
      emit(PropertiesError(err.toString()));
    }
  }
}
