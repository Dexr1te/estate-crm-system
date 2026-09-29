import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/clients/data/datasources/cold_clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';

class ColdClientsRepositoryImpl implements ColdClientsRepository {
  final ColdClientsRemoteDataSource _remote;
  ColdClientsRepositoryImpl(this._remote);

  @override
  Future<List<ColdClient>> getColdClients({
    int days = ColdClientsRepository.defaultDays,
    int limit = 20,
  }) =>
      _remote.getColdClients(days: days, limit: limit);
}
