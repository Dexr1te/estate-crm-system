import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/features/notifications/domain/repositories/notifications_repository.dart';

abstract class UnreadCountEvent {}

class UnreadCountRefreshEvent extends UnreadCountEvent {}

class _UnreadCountChanged extends UnreadCountEvent {
  final int count;
  _UnreadCountChanged(this.count);
}

class UnreadCountBloc extends Bloc<UnreadCountEvent, int> {
  final NotificationsRepository _repo;
  late final StreamSubscription<int> _counts;

  UnreadCountBloc(this._repo) : super(_repo.lastUnreadCount) {
    on<UnreadCountRefreshEvent>(_onRefresh);
    on<_UnreadCountChanged>((e, emit) => emit(e.count));
    _counts = _repo.unreadCounts.listen((count) {
      if (!isClosed) add(_UnreadCountChanged(count));
    });
  }

  Future<void> _onRefresh(UnreadCountRefreshEvent e, Emitter<int> emit) async {
    try {
      await _repo.refreshUnreadCount();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _counts.cancel();
    return super.close();
  }
}

typedef PeriodicTimerFactory = Timer Function(
    Duration interval, void Function(Timer) tick);

class UnreadCountPoller {
  final Future<void> Function() refresh;
  final Duration? interval;
  final PeriodicTimerFactory _periodic;
  Timer? _timer;

  UnreadCountPoller({
    required this.refresh,
    required this.interval,
    PeriodicTimerFactory? periodic,
  }) : _periodic = periodic ?? Timer.periodic;

  bool get isRunning => _timer != null;

  void start() {
    stop();
    final every = interval;
    if (every == null) return;
    _timer = _periodic(every, (_) => _tick());
  }

  void refreshNow() => _tick();

  void _tick() {
    refresh().catchError((_) {});
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
