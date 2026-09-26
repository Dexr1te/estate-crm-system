import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class AnalyticsRemoteDataSource {
  final ApiClient _client;
  AnalyticsRemoteDataSource(this._client);

  Future<DealFunnel> getFunnel(
      {required DateTime from, required DateTime to, int? agentId}) async {
    final res = await _client.dio.get('/analytics/funnel', queryParameters: {
      'from': _date(from),
      'to': _date(to),
      if (agentId != null) 'agentId': agentId,
    });
    return DealFunnel.fromJson(jsonObject(res));
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';
}
