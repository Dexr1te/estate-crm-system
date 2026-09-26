import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';

abstract class NotificationsRepository {
  Stream<int> get unreadCounts;

  int get lastUnreadCount;

  Future<PagedResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  });

  Future<int> refreshUnreadCount();

  Future<AppNotification> markRead(int id);

  Future<void> markAllRead();

  void clear();
}
