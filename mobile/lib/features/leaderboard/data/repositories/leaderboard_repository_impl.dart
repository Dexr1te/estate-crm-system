import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:real_estate_crm/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _remote;
  LeaderboardRepositoryImpl(this._remote);

  @override
  Future<AgentLeaderboard> getLeaderboard(
          {required DateTime from, required DateTime to}) =>
      _remote.getLeaderboard(from: from, to: to);
}
