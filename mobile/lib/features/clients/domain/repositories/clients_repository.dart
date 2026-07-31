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
}
