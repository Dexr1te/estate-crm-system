import 'dart:async';

import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:real_estate_crm/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;
  final _counts = StreamController<int>.broadcast();
  int _last = 0;

  NotificationsRepositoryImpl(this._remote);

  @override
  Stream<int> get unreadCounts => _counts.stream;

  @override
  int get lastUnreadCount => _last;

  void _publish(int count) {
    _last = count < 0 ? 0 : count;
    _counts.add(_last);
  }

  @override
  Future<PagedResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) =>
      _remote.getNotifications(page: page, size: size, unreadOnly: unreadOnly);

  @override
  Future<int> refreshUnreadCount() async {
    final count = await _remote.unreadCount();
    _publish(count);
    return count;
  }

  @override
  Future<AppNotification> markRead(int id) async {
    final updated = await _remote.markRead(id);
    _publish(_last - 1);
    return updated;
  }

  @override
  Future<void> markAllRead() async {
    await _remote.markAllRead();
    _publish(0);
  }

  @override
  void clear() => _publish(0);
}
