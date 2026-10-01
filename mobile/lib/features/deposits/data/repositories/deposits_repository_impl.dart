import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deposits/data/datasources/deposits_remote_datasource.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/domain/repositories/deposits_repository.dart';

class DepositsRepositoryImpl implements DepositsRepository {
  final DepositsRemoteDataSource _remote;
  DepositsRepositoryImpl(this._remote);

  @override
  Future<List<DealDeposit>> getDealDeposits(int dealId) =>
      _remote.getDealDeposits(dealId);

  @override
  Future<DealDeposit> record(int dealId, DepositDraft draft) =>
      _remote.record(dealId, draft);

  @override
  Future<DealDeposit> update(int dealId, int depositId, DepositDraft draft) =>
      _remote.update(dealId, depositId, draft);

  @override
  Future<DealDeposit> close(
          int dealId, int depositId, DepositClosing closing) =>
      _remote.close(dealId, depositId, closing);

  @override
  Future<List<DealDeposit>> getDepositsEnding() => _remote.getDepositsEnding();
}
