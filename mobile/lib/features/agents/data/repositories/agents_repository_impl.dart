import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/agents/data/datasources/agents_remote_datasource.dart';
import 'package:real_estate_crm/features/agents/domain/repositories/agents_repository.dart';

class AgentsRepositoryImpl implements AgentsRepository {
  final AgentsRemoteDataSource _remote;
  AgentsRepositoryImpl(this._remote);

  @override
  Future<List<AgentOption>> getAgentOptions() => _remote.getAgentOptions();
}
