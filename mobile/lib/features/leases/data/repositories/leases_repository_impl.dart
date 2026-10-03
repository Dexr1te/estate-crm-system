import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/leases/data/datasources/leases_remote_datasource.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/domain/repositories/leases_repository.dart';

class LeasesRepositoryImpl implements LeasesRepository {
  final LeasesRemoteDataSource _remote;
  LeasesRepositoryImpl(this._remote);

  @override
  Future<List<LeaseEnding>> getLeasesEnding(
          {required int days, DateTime? from}) =>
      _remote.getLeasesEnding(days: days, from: from);

  @override
  Future<DealResponse> renew(int dealId, LeaseRenewal renewal) =>
      _remote.renew(dealId, renewal);
}
