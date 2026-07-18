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
}
