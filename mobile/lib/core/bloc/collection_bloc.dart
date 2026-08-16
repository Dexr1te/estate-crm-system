import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

/// Drops a repeat of an operation that is already running.
///
/// Event handlers run concurrently unless told otherwise, and a button's
/// disabled state only takes effect a rebuild later, so a double tap — or Enter
/// and then the button — reaches the bloc as two events. Writes want the second
/// one gone: a second accept spends an invite token that is already spent, a
/// second submit files a second row.
mixin SingleFlight {
  final _running = <String>{};

  /// Whether an operation registered under [key] is still in flight.
  bool isRunning(String key) => _running.contains(key);

  /// Runs [action] unless [key] is already running, in which case this call is
  /// dropped. [key] names the operation and its target — `'delete-7'` — so two
  /// different rows are never mistaken for a repeat of each other.
  Future<void> once(String key, Future<void> Function() action) async {
    if (!_running.add(key)) return;
    try {
      await action();
    } finally {
      _running.remove(key);
    }
  }
}

/// The read/write plumbing every list bloc in the app shares.
///
/// Each feature used to spell these rules out for itself and they drifted — the
/// audit log blanked its rows to a skeleton on every pull-to-refresh, and a
/// write that landed after its screen was popped threw on `add`. They live in
/// one place now:
///
/// * **A refresh keeps what is already on screen.** The skeleton belongs to a
///   screen with nothing to show, not to one that is replacing good rows.
/// * **A superseded response is dropped.** A filter change on top of a refresh
///   leaves two requests in flight and the network decides which returns first;
///   only the newest may reach the UI.
/// * **A failed write leaves the list alone.** It reports a message rather than
///   swapping a working screen for a full-page error.
/// * **A write runs once**, and never touches a bloc that has since closed.
mixin CollectionBloc<Event, State> on Bloc<Event, State>, SingleFlight {
  int _generation = 0;

  /// The ticket of the newest load. A feature with a flow of its own — paging
  /// past the first page, say — takes one and checks [isStale] itself.
  int get loadTicket => _generation;

  /// Whether a newer load has started since [ticket] was taken, which makes
  /// whatever it was waiting on no longer worth emitting.
  bool isStale(int ticket) => ticket != _generation;

  /// Discards every response still in flight, so nothing fetched under the
  /// previous session or filter can repopulate the screen after a reset.
  int invalidate() => ++_generation;

  /// Loads the collection.
  ///
  /// [skeleton] is emitted first unless [keepVisible] says the screen already
  /// holds rows worth leaving up. [onData] and [onFailure] run only while this
  /// load is still the newest, which also makes them the right place to write
  /// back any cursor the feature keeps.
  Future<void> load<T>(
    Emitter<State> emit, {
    required Future<T> Function() fetch,
    required State Function(T data) onData,
    required State Function(String message) onFailure,
    State? skeleton,
    bool keepVisible = false,
  }) async {
    final ticket = invalidate();
    if (!keepVisible && skeleton != null) emit(skeleton);
    try {
      final data = await fetch();
      if (isStale(ticket)) return;
      emit(onData(data));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(onFailure(apiErrorMessage(err)));
    }
  }

  /// Runs a write, reports it, and refreshes the list behind it.
  ///
  /// [key] identifies the write for [SingleFlight]. [onFailure] is handed only
  /// a message and is expected to hand back the rows it already had.
  Future<void> write<T>(
    Emitter<State> emit, {
    required String key,
    required Future<T> Function() perform,
    required State Function(T result) onSuccess,
    required State Function(String message) onFailure,
    void Function()? reload,
  }) =>
      once(key, () async {
        try {
          final result = await perform();
          emit(onSuccess(result));
          // A form pops the moment it submits, so the bloc can already be gone
          // by the time the server answers — and `add` throws on a closed bloc.
          if (reload != null && !isClosed) reload();
        } catch (err) {
          emit(onFailure(apiErrorMessage(err)));
        }
      });
}
