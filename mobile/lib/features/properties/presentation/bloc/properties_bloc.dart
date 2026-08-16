import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState>
    with SingleFlight, CollectionBloc<PropertiesEvent, PropertiesState> {
  final PropertiesRepository _repo;
  static const _pageSize = 20;

  PropertyStatus? _status;
  PropertyType? _type;
  String? _search;
  int _page = 0;
  bool _hasMore = false;
  List<PropertyResponse> _items = const [];

  PropertiesBloc(this._repo) : super(PropertiesInitial()) {
    on<PropertiesLoadEvent>(_onLoad);
    on<PropertiesLoadMoreEvent>(_onLoadMore);
    on<PropertiesResetEvent>(_onReset);
    on<PropertiesDeleteEvent>(_onDelete);
    on<PropertiesCreateEvent>(_onCreate);
    on<PropertiesUpdateEvent>(_onUpdate);
    on<PropertiesUpdateStatusEvent>(_onUpdateStatus);
  }

  /// A write reloads under the filters the screen is actually showing, and from
  /// the first page — the rows behind it may have shifted.
  void _reload() =>
      add(PropertiesLoadEvent(status: _status, type: _type, search: _search));

  PropertiesState _failure(String message) => _items.isEmpty
      ? PropertiesError(message)
      : PropertiesActionFailure(message, _items, hasMore: _hasMore);

  void _onReset(PropertiesResetEvent e, Emitter<PropertiesState> emit) {
    invalidate();
    _status = null;
    _type = null;
    _search = null;
    _page = 0;
    _hasMore = false;
    _items = const [];
    emit(PropertiesInitial());
  }

  Future<void> _onLoad(PropertiesLoadEvent e, Emitter<PropertiesState> emit) {
    final queryChanged =
        e.status != _status || e.type != _type || e.search != _search;
    _status = e.status;
    _type = e.type;
    _search = e.search;

    return load(
      emit,
      keepVisible: _items.isNotEmpty && !queryChanged,
      skeleton: PropertiesLoading(),
      fetch: () => _repo.getProperties(
          status: e.status,
          type: e.type,
          search: e.search,
          page: 0,
          size: _pageSize),
      onData: (res) {
        _page = res.page;
        _hasMore = res.hasMore;
        _items = List.unmodifiable(res.content);
        return PropertiesLoaded(_items, hasMore: _hasMore);
      },
      onFailure: PropertiesError.new,
    );
  }

  /// Paging is the one flow that appends instead of replacing, so it takes the
  /// current load's ticket rather than starting a new one: a filter change that
  /// lands mid-page must win, and this page must not be grafted onto its rows.
  Future<void> _onLoadMore(
      PropertiesLoadMoreEvent e, Emitter<PropertiesState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is PropertiesLoaded && current.isLoadingMore) return;

    final ticket = loadTicket;
    final nextPage = _page + 1;
    emit(PropertiesLoaded(_items, hasMore: _hasMore, isLoadingMore: true));

    try {
      final res = await _repo.getProperties(
          status: _status,
          type: _type,
          search: _search,
          page: nextPage,
          size: _pageSize);
      if (isStale(ticket)) return;
      _page = res.page;
      _hasMore = res.hasMore;
      _items = List.unmodifiable([..._items, ...res.content]);
      emit(PropertiesLoaded(_items, hasMore: _hasMore));
    } catch (err) {
      if (isStale(ticket)) return;
      // Just dropping the spinner reads as "that was the end of the list".
      // Keep the rows already paged in, and say why the next ones are missing.
      emit(PropertiesActionFailure(apiErrorMessage(err), _items,
          hasMore: _hasMore));
    }
  }

  Future<void> _act(Emitter<PropertiesState> emit, String key, String success,
          Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) =>
            PropertiesActionSuccess(success, _items, hasMore: _hasMore),
        onFailure: _failure,
        reload: _reload,
      );

  Future<void> _onDelete(
          PropertiesDeleteEvent e, Emitter<PropertiesState> emit) =>
      _act(emit, 'delete-${e.id}', 'Property deleted',
          () => _repo.deleteProperty(e.id));

  Future<void> _onCreate(
          PropertiesCreateEvent e, Emitter<PropertiesState> emit) =>
      write(
        emit,
        key: 'create-${e.data['title']}-${e.data['address']}',
        perform: () => _repo.createProperty(e.data),
        onSuccess: (created) =>
            PropertyCreated(created, _items, hasMore: _hasMore),
        onFailure: _failure,
        reload: _reload,
      );

  Future<void> _onUpdate(
          PropertiesUpdateEvent e, Emitter<PropertiesState> emit) =>
      _act(emit, 'update-${e.id}', 'Property updated',
          () => _repo.updateProperty(e.id, e.data));

  Future<void> _onUpdateStatus(
          PropertiesUpdateStatusEvent e, Emitter<PropertiesState> emit) =>
      _act(emit, 'status-${e.id}-${e.status.name}', 'Status updated',
          () => _repo.updatePropertyStatus(e.id, e.status));
}
