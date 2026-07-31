import 'package:real_estate_crm/core/models/models.dart';

abstract class AgentsRepository {
  Future<List<AgentOption>> getAgentOptions();
}
