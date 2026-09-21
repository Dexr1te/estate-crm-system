import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

mixin SingleFlight {
  final _running = <String>{};

  bool isRunning(String key) => _running.contains(key);

  Future<void> once(String key, Future<void> Function() action) async {
    if (!_running.add(key)) return;
    try {
      await action();
    } finally {
      _running.remove(key);
    }
  }
}

mixin CollectionBloc<Event, State> on Bloc<Event, State>, SingleFlight {
  int _generation = 0;

  int get loadTicket => _generation;

  bool isStale(int ticket) => ticket != _generation;

  int invalidate() => ++_generation;

  Future<void> load<T>(
    Emitter<State> emit, {
    required Future<T> Function() fetch,
    required State Function(T data) onData,
    required State Function(ApiFailure failure) onFailure,
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
      emit(onFailure(ApiFailure.from(err)));
    }
  }

  Future<void> write<T>(
    Emitter<State> emit, {
    required String key,
    required Future<T> Function() perform,
    required State Function(T result) onSuccess,
    required State Function(ApiFailure failure) onFailure,
    void Function()? reload,
  }) =>
      once(key, () async {
        try {
          final result = await perform();
          emit(onSuccess(result));

          if (reload != null && !isClosed) reload();
        } catch (err) {
          emit(onFailure(ApiFailure.from(err)));
        }
      });
}
