import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class NotificationsRemoteDataSource {
  final ApiClient _client;
  NotificationsRemoteDataSource(this._client);

  Future<PagedResponse<AppNotification>> getNotifications({
    required int page,
    required int size,
    required bool unreadOnly,
  }) async {
    final res = await _client.dio.get('/notifications', queryParameters: {
      'page': page,
      'size': size,
      if (unreadOnly) 'unreadOnly': true,
    });
    return PagedResponse.parse(jsonObject(res), AppNotification.fromJson,
        requestedPage: page);
  }

  Future<int> unreadCount() async {
    final res = await _client.dio.get('/notifications/unread-count');
    final count = jsonObject(res)['count'];
    return count is num ? count.toInt() : 0;
  }

  Future<AppNotification> markRead(int id) async {
    final res = await _client.dio.post('/notifications/$id/read');
    return AppNotification.fromJson(jsonObject(res));
  }

  Future<void> markAllRead() async {
    await _client.dio.post('/notifications/read-all');
  }
}
