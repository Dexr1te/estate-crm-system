import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/clients/data/datasources/client_dates_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/client_dates_repository.dart';

class ClientDatesRepositoryImpl implements ClientDatesRepository {
  final ClientDatesRemoteDataSource _remote;
  ClientDatesRepositoryImpl(this._remote);

  @override
  Future<List<UpcomingClientDate>> getUpcoming({
    required DateTime from,
    int days = ClientDatesRepository.defaultDays,
  }) =>
      _remote.getUpcoming(from: from, days: days);
}
