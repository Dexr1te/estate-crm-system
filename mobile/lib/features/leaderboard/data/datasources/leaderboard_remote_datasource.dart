import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class LeaderboardRemoteDataSource {
  final ApiClient _client;
  LeaderboardRemoteDataSource(this._client);

  /// `GET /analytics/leaderboard`: the manager's own agency over
  /// [from, to). An agent is refused with 403.
  Future<AgentLeaderboard> getLeaderboard(
      {required DateTime from, required DateTime to}) async {
    final res = await _client.dio.get('/analytics/leaderboard',
        queryParameters: {'from': _date(from), 'to': _date(to)});
    return AgentLeaderboard.fromJson(jsonObject(res));
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';
}
