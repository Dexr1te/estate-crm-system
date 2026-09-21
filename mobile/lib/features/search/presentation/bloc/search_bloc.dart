import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/features/search/data/recent_searches.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_crm/features/search/presentation/bloc/search_event.dart';
import 'package:real_estate_crm/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState>
    with SingleFlight, CollectionBloc<SearchEvent, SearchState> {
  static const minQueryLength = 2;

  final SearchRepository _repo;
  final RecentSearches _recent;

  List<String> _remembered = const [];

  SearchBloc(this._repo, this._recent) : super(SearchIdle()) {
    on<SearchRecentLoadEvent>(_onLoadRecent);
    on<SearchQueryEvent>(_onQuery);
    on<SearchClearedEvent>(_onCleared);
    on<SearchRememberEvent>(_onRemember);
    on<SearchForgetAllEvent>(_onForgetAll);
  }

  Future<void> _onLoadRecent(
      SearchRecentLoadEvent e, Emitter<SearchState> emit) async {
    _remembered = await _loadRemembered() ?? _remembered;
    if (state is SearchIdle) emit(SearchIdle(_remembered));
  }

  Future<List<String>?> _loadRemembered() async {
    try {
      return await _recent.load();
    } catch (_) {
      return null;
    }
  }

  Future<void> _onQuery(SearchQueryEvent e, Emitter<SearchState> emit) async {
    final q = e.query.trim();
    if (q.length < minQueryLength) {
      invalidate();
      emit(SearchIdle(_remembered));
      return;
    }

    await load(
      emit,
      skeleton: SearchLoading(q),
      fetch: () => _repo.search(q),
      onData: (results) => SearchLoaded(q, results),
      onFailure: (failure) => SearchError(q, failure),
    );
  }

  void _onCleared(SearchClearedEvent e, Emitter<SearchState> emit) {
    invalidate();
    emit(SearchIdle(_remembered));
  }

  Future<void> _onRemember(
      SearchRememberEvent e, Emitter<SearchState> emit) async {
    try {
      _remembered = await _recent.remember(e.query);
    } catch (_) {}
  }

  Future<void> _onForgetAll(
      SearchForgetAllEvent e, Emitter<SearchState> emit) async {
    try {
      _remembered = await _recent.clear();
    } catch (_) {
      _remembered = const [];
    }
    if (state is SearchIdle) emit(SearchIdle(_remembered));
  }
}
