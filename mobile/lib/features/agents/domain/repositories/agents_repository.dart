import 'package:real_estate_crm/core/models/models.dart';

/// Contract for the shared agent lookup (`/users/agents`), used by deal and
/// meeting forms to populate the "assigned agent" picker.
abstract class AgentsRepository {
  Future<List<AgentOption>> getAgentOptions();
}
