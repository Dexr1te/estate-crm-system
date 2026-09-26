import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource _remote;
  ClientsRepositoryImpl(this._remote);

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) =>
      _remote.getClients(type: type, agentId: agentId, search: search);

  @override
  Future<List<ClientListItem>> getClientsWithDetails() =>
      _remote.getClientsWithDetails();

  @override
  Future<ClientResponse> getClient(int id) => _remote.getClient(id);

  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) =>
      _remote.createClient(data);

  @override
  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) =>
      _remote.updateClient(id, data);

  @override
  Future<void> deleteClient(int id) => _remote.deleteClient(id);

  @override
  Future<List<PropertyMatch>> getMatches(int id) => _remote.getMatches(id);

  @override
  Future<List<ClientActivity>> getActivities(int clientId) =>
      _remote.getActivities(clientId);

  @override
  Future<ClientActivity> logActivity(
    int clientId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
    List<int> propertyIds = const [],
  }) =>
      _remote.logActivity(clientId,
          type: type,
          note: note,
          occurredAt: occurredAt,
          propertyIds: propertyIds);

  @override
  Future<ClientActivity> updateActivity(
    int clientId,
    int activityId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
  }) =>
      _remote.updateActivity(clientId, activityId,
          type: type, note: note, occurredAt: occurredAt);

  @override
  Future<void> deleteActivity(int clientId, int activityId) =>
      _remote.deleteActivity(clientId, activityId);

  @override
  Future<List<ClientDuplicate>> findDuplicates({
    String? phone,
    String? email,
    int? excludeId,
  }) =>
      _remote.findDuplicates(phone: phone, email: email, excludeId: excludeId);

  @override
  Future<ClientResponse> mergeClients(int targetId, int sourceId) =>
      _remote.mergeClients(targetId, sourceId);
}
