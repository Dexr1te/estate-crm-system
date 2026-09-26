import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:real_estate_crm/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState>
    with SingleFlight, CollectionBloc<NotificationsEvent, NotificationsState> {
  static const pageSize = 20;

  final NotificationsRepository _repo;

  NotificationsBloc(this._repo) : super(NotificationsInitial()) {
    on<NotificationsLoadEvent>(_onLoad);
    on<NotificationsLoadMoreEvent>(_onLoadMore);
    on<NotificationsMarkReadEvent>(_onMarkRead);
    on<NotificationsMarkAllReadEvent>(_onMarkAllRead);
  }

  NotificationsLoaded? get _loaded {
    final s = state;
    return s is NotificationsLoaded ? s : null;
  }

  Future<void> _onLoad(
      NotificationsLoadEvent e, Emitter<NotificationsState> emit) async {
    await load<PagedResponse<AppNotification>>(
      emit,
      keepVisible: state is NotificationsLoaded,
      skeleton: NotificationsLoading(),
      fetch: () => _repo.getNotifications(page: 0, size: pageSize),
      onData: (p) => NotificationsLoaded(p.content, hasMore: p.hasMore),
      onFailure: NotificationsError.new,
    );
    try {
      await _repo.refreshUnreadCount();
    } catch (_) {}
  }

  Future<void> _onLoadMore(
      NotificationsLoadMoreEvent e, Emitter<NotificationsState> emit) {
    final current = _loaded;
    if (current == null || !current.hasMore) return Future.value();
    return once('more', () async {
      final ticket = loadTicket;
      emit(current.copyWith(loadingMore: true));
      try {
        final next = await _repo.getNotifications(
            page: current.page + 1, size: pageSize);
        if (isStale(ticket)) return;
        final seen = current.items.map((n) => n.id).toSet();
        emit(NotificationsLoaded(
          [
            ...current.items,
            ...next.content.where((n) => !seen.contains(n.id))
          ],
          page: current.page + 1,
          hasMore: next.hasMore,
        ));
      } catch (err) {
        if (isStale(ticket)) return;
        emit(NotificationsActionFailure(
            ApiFailure.from(err), current.copyWith(loadingMore: false)));
      }
    });
  }

  Future<void> _onMarkRead(
      NotificationsMarkReadEvent e, Emitter<NotificationsState> emit) async {
    final current = _loaded;
    if (current == null) return;
    final target = current.items.where((n) => n.id == e.id).firstOrNull;
    if (target == null || target.isRead) return;
    final now = AppClock.now();
    emit(current.copyWith(
        items: current.items
            .map((n) => n.id == e.id ? n.copyWith(readAt: now) : n)
            .toList()));
    try {
      await _repo.markRead(e.id);
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(
      NotificationsMarkAllReadEvent e, Emitter<NotificationsState> emit) {
    final current = _loaded;
    if (current == null) return Future.value();
    return write<void>(
      emit,
      key: 'read-all',
      perform: _repo.markAllRead,
      onSuccess: (_) {
        final now = AppClock.now();
        final latest = _loaded ?? current;
        return NotificationsActionSuccess(
          ActionMessage.notificationsAllRead,
          latest.copyWith(
              items: latest.items
                  .map((n) => n.isRead ? n : n.copyWith(readAt: now))
                  .toList()),
        );
      },
      onFailure: (f) => NotificationsActionFailure(f, _loaded ?? current),
    );
  }
}
