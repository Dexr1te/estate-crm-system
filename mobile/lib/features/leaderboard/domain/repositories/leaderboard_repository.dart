import 'package:real_estate_crm/core/models/models.dart';

abstract class LeaderboardRepository {
  Future<AgentLeaderboard> getLeaderboard(
      {required DateTime from, required DateTime to});
}
