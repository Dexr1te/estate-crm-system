import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState>
    with LoadGeneration {
  final PropertiesRepository _repo;
  static const _pageSize = 20;

  // Active filters + paging cursor, retained across load-more/reload.
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

  /// Reload the first page, keeping the current filters.
  void _reload() =>
      add(PropertiesLoadEvent(status: _status, type: _type, search: _search));

  /// A write failed. Keep whatever is on screen; only a failed *load* leaves
  /// the user with nothing to look at.
  PropertiesState _failure(Object err) => _items.isEmpty
      ? PropertiesError(apiErrorMessage(err))
      : PropertiesActionFailure(apiErrorMessage(err), _items,
          hasMore: _hasMore);

  void _onReset(PropertiesResetEvent e, Emitter<PropertiesState> emit) {
    // Invalidate any load still in flight, so a response fetched with the old
    // session's token can't repopulate the list after the reset.
    startLoad();
    _status = null;
    _type = null;
    _search = null;
    _page = 0;
    _hasMore = false;
    _items = const [];
    emit(PropertiesInitial());
  }

  Future<void> _onLoad(
      PropertiesLoadEvent e, Emitter<PropertiesState> emit) async {
    final ticket = startLoad();
    final queryChanged =
        e.status != _status || e.type != _type || e.search != _search;
    _status = e.status;
    _type = e.type;
    _search = e.search;

    // Only blank the screen when what is on it no longer answers the request.
    // Every screen fires a load in initState and switching tabs remounts it,
    // so blanking unconditionally meant a full-page skeleton on every visit,
    // however fresh the rows already were. A *changed* filter is different:
    // the rows on screen are the wrong ones, so the skeleton is honest.
    if (_items.isEmpty || queryChanged) emit(PropertiesLoading());

    try {
      final res = await _repo.getProperties(
          status: e.status,
          type: e.type,
          search: e.search,
          page: 0,
          size: _pageSize);
      // A newer load started while this one was in flight — its result wins.
      if (isStale(ticket)) return;
      _page = res.page;
      _hasMore = res.hasMore;
      _items = List.unmodifiable(res.content);
      emit(PropertiesLoaded(_items, hasMore: _hasMore));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(PropertiesError(apiErrorMessage(err)));
    }
  }

  Future<void> _onLoadMore(
      PropertiesLoadMoreEvent e, Emitter<PropertiesState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is PropertiesLoaded && current.isLoadingMore) return;

    // Not a fresh load, so it takes no ticket — it only has to notice when a
    // reload supersedes it, since appending would then duplicate that page.
    final ticket = currentLoad;
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
    } catch (_) {
      if (isStale(ticket)) return;
      // Keep what is loaded and stop the footer spinner.
      emit(PropertiesLoaded(_items, hasMore: _hasMore));
    }
  }

  Future<void> _onDelete(
      PropertiesDeleteEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.deleteProperty(e.id);
      emit(PropertiesActionSuccess('Property deleted', _items,
          hasMore: _hasMore));
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onCreate(
      PropertiesCreateEvent e, Emitter<PropertiesState> emit) async {
    try {
      final created = await _repo.createProperty(e.data);
      // The full object, with its id.
      emit(PropertyCreated(created, _items, hasMore: _hasMore));
      // The form sits on the root navigator, so the list screen underneath
      // never remounts — nothing else would pick the new row up.
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(
      PropertiesUpdateEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updateProperty(e.id, e.data);
      emit(PropertiesActionSuccess('Property updated', _items,
          hasMore: _hasMore));
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdateStatus(
      PropertiesUpdateStatusEvent e, Emitter<PropertiesState> emit) async {
    try {
      await _repo.updatePropertyStatus(e.id, e.status);
      emit(PropertiesActionSuccess('Status updated', _items, hasMore: _hasMore));
      _reload();
    } catch (err) {
      emit(_failure(err));
    }
  }
}
