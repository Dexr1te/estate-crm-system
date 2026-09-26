import 'package:real_estate_crm/core/models/models.dart';

abstract class ClientsRepository {
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  });

  Future<List<ClientListItem>> getClientsWithDetails();

  Future<ClientResponse> getClient(int id);

  Future<ClientResponse> createClient(Map<String, dynamic> data);

  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data);

  Future<void> deleteClient(int id);

  Future<List<PropertyMatch>> getMatches(int id);

  Future<List<ClientActivity>> getActivities(int clientId);

  Future<ClientActivity> logActivity(
    int clientId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
    List<int> propertyIds = const [],
  });

  /// Corrects an entry; the listings it names stay as they were.
  Future<ClientActivity> updateActivity(
    int clientId,
    int activityId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
  });

  Future<void> deleteActivity(int clientId, int activityId);

  /// Cards in the agency sharing this phone (however typed) or email.
  Future<List<ClientDuplicate>> findDuplicates({
    String? phone,
    String? email,
    int? excludeId,
  });

  /// Folds [sourceId] into [targetId] and deletes it; returns the target.
  Future<ClientResponse> mergeClients(int targetId, int sourceId);
}
