import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/features/payouts/data/datasources/payouts_remote_datasource.dart';
import 'package:real_estate_crm/features/payouts/domain/repositories/payouts_repository.dart';

class PayoutsRepositoryImpl implements PayoutsRepository {
  final PayoutsRemoteDataSource _remote;
  PayoutsRepositoryImpl(this._remote);

  @override
  Future<PayoutList> getPayouts({required PayoutStatus status, int? agentId}) =>
      _remote.getPayouts(status: status, agentId: agentId);
}
