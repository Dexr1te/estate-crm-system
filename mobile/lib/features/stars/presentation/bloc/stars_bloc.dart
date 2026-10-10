import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/stars/domain/repositories/stars_repository.dart';

abstract class StarsEvent {}

/// Reads the list again. A star still being written stays the way it was
/// asked for.
class StarsLoadEvent extends StarsEvent {}

/// Signed out: nothing of the last person's stars stays.
class StarsResetEvent extends StarsEvent {}

/// Stars the record when it is not starred and takes the star off when it
/// is. [title] and [subtitle] show it in the list until the server answers.
class StarsToggleEvent extends StarsEvent {
  final StarKey key;
  final String title;
  final String? subtitle;

  StarsToggleEvent(this.key, {required this.title, this.subtitle});
}

enum StarsStatus { initial, loading, loaded, failure }

/// A change the app showed at once and then had to put back, because the
/// server refused it. Each one is a new object, so a listener can tell it
/// from the last.
class StarsWriteFailure {
  final StarKey key;

  /// Whether a star was being added, rather than taken off.
  final bool starring;
  final ApiFailure failure;

  const StarsWriteFailure(this.key,
      {required this.starring, required this.failure});
}

class StarsState {
  final StarsStatus status;

  /// Newest first, with every change already applied the moment it was
  /// asked for.
  final List<StarredItem> items;

  /// Why the list could not be read, when it never was.
  final ApiFailure? loadFailure;

  /// The last change that was put back.
  final StarsWriteFailure? writeFailure;

  late final Set<StarKey> _keys = {for (final item in items) item.key};

  StarsState({
    required this.status,
    this.items = const [],
    this.loadFailure,
    this.writeFailure,
  });

  factory StarsState.initial() => StarsState(status: StarsStatus.initial);

  bool isStarred(StarKey key) => _keys.contains(key);

  List<StarredItem> ofType(StarType type) =>
      items.where((item) => item.type == type).toList();
}

/// The signed-in person's starred records, app-wide, so a detail screen's
/// star and the Starred list always agree.
///
/// A toggle shows at once. The write behind it runs one at a time per record:
/// taps that land while one is out only change what is wanted, and the record
/// is written again until the server holds what was last asked for. When the
/// server refuses, the record goes back to what the server holds and
/// [StarsState.writeFailure] says so.
class StarsBloc extends Bloc<StarsEvent, StarsState>
    with SingleFlight, CollectionBloc<StarsEvent, StarsState> {
  final StarsRepository _repo;

  /// For each record with a write out: what was last asked for (null: no star).
  final _wanted = <StarKey, StarredItem?>{};

  /// For each record with a write out: what the server is known to hold.
  final _confirmed = <StarKey, StarredItem?>{};

  /// Moves on at sign-out, so a write that lands afterwards changes nothing.
  int _session = 0;

  StarsBloc(this._repo) : super(StarsState.initial()) {
    on<StarsLoadEvent>(_onLoad);
    on<StarsResetEvent>(_onReset);
    on<StarsToggleEvent>(_onToggle);
  }

  /// Reads the list unless it is there or on its way.
  void ensureLoaded() {
    final status = state.status;
    if (status == StarsStatus.initial || status == StarsStatus.failure) {
      add(StarsLoadEvent());
    }
  }

  /// Reads the list again if it has been read at all this session.
  void refresh() {
    if (state.status != StarsStatus.initial) add(StarsLoadEvent());
  }

  Future<void> _onLoad(StarsLoadEvent e, Emitter<StarsState> emit) => load(
        emit,
        keepVisible: state.status == StarsStatus.loaded,
        skeleton: _with(status: StarsStatus.loading),
        fetch: _repo.getStars,
        onData: (items) {
          var shown = items;
          _wanted.forEach((key, wish) => shown = _put(shown, key, wish));
          return StarsState(
            status: StarsStatus.loaded,
            items: shown,
            writeFailure: state.writeFailure,
          );
        },
        onFailure: (failure) => state.status == StarsStatus.loaded
            ? state
            : _with(status: StarsStatus.failure, loadFailure: failure),
      );

  void _onReset(StarsResetEvent e, Emitter<StarsState> emit) {
    _session++;
    invalidate();
    _wanted.clear();
    _confirmed.clear();
    emit(StarsState.initial());
  }

  Future<void> _onToggle(StarsToggleEvent e, Emitter<StarsState> emit) async {
    final key = e.key;
    final writing = _wanted.containsKey(key);
    final shown = _itemFor(key);
    if (!writing) _confirmed[key] = shown;
    final subtitle = e.subtitle?.trim();
    final wish = shown != null
        ? null
        : StarredItem(
            type: key.type,
            id: key.id,
            title: e.title,
            subtitle: subtitle == null || subtitle.isEmpty ? null : subtitle,
            starredAt: AppClock.now(),
          );
    _wanted[key] = wish;
    emit(_with(items: _put(state.items, key, wish)));
    // The write already out sees the new wish when it lands.
    if (writing) return;

    final session = _session;
    try {
      while (true) {
        final want = _wanted[key];
        if ((want == null) == (_confirmed[key] == null)) return;
        try {
          if (want != null) {
            final saved = await _repo.star(key);
            if (session != _session) return;
            _confirmed[key] = saved;
            if (_wanted[key] != null) {
              _wanted[key] = saved;
              emit(_with(items: _put(state.items, key, saved)));
            }
          } else {
            await _repo.unstar(key);
            if (session != _session) return;
            _confirmed[key] = null;
          }
        } catch (err) {
          if (session != _session) return;
          emit(_with(
            items: _put(state.items, key, _confirmed[key]),
            writeFailure: StarsWriteFailure(key,
                starring: want != null, failure: ApiFailure.from(err)),
          ));
          return;
        }
      }
    } finally {
      if (session == _session) {
        _wanted.remove(key);
        _confirmed.remove(key);
      }
    }
  }

  StarredItem? _itemFor(StarKey key) {
    for (final item in state.items) {
      if (item.key == key) return item;
    }
    return null;
  }

  StarsState _with({
    StarsStatus? status,
    List<StarredItem>? items,
    ApiFailure? loadFailure,
    StarsWriteFailure? writeFailure,
  }) =>
      StarsState(
        status: status ?? state.status,
        items: items ?? state.items,
        loadFailure: loadFailure ?? state.loadFailure,
        writeFailure: writeFailure ?? state.writeFailure,
      );

  /// [items] with [key] taken out and, when given, [item] put back in its
  /// place, newest first.
  static List<StarredItem> _put(
      List<StarredItem> items, StarKey key, StarredItem? item) {
    final rest = [
      for (final i in items)
        if (i.key != key) i
    ];
    if (item == null) return rest;
    final at = rest.indexWhere((i) => i.starredAt.isBefore(item.starredAt));
    return [...rest]..insert(at < 0 ? rest.length : at, item);
  }
}
