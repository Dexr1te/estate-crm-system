import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/dashboard` endpoints.
class DashboardRemoteDataSource {
  final ApiClient _client;
  DashboardRemoteDataSource(this._client);

  Future<DashboardSummary> getDashboardSummary() async {
    final res = await _client.dio.get('/dashboard/summary');
    return DashboardSummary.fromJson(res.data);
  }
}
