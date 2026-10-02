import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class ClientDatesRemoteDataSource {
  final ApiClient _client;
  ClientDatesRemoteDataSource(this._client);

  Future<List<UpcomingClientDate>> getUpcoming({
    required DateTime from,
    required int days,
  }) async {
    final res = await _client.dio.get('/clients/upcoming-dates',
        queryParameters: {'from': isoDay(from), 'days': days});
    return jsonArray(res).map(UpcomingClientDate.fromJson).toList();
  }

  /// `2026-10-01`: the phone's today, so "today" is the agent's day and not
  /// the server's.
  static String isoDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
