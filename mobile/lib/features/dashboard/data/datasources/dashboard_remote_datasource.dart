import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class DashboardRemoteDataSource {
  final ApiClient _client;
  DashboardRemoteDataSource(this._client);

  Future<DashboardSummary> getDashboardSummary() async {
    final res = await _client.dio.get('/dashboard/summary');
    return DashboardSummary.fromJson(jsonObject(res));
  }
}
