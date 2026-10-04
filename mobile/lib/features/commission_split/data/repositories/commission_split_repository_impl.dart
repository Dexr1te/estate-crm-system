import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/commission_split/data/datasources/commission_split_remote_datasource.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';
import 'package:real_estate_crm/features/commission_split/domain/repositories/commission_split_repository.dart';

class CommissionSplitRepositoryImpl implements CommissionSplitRepository {
  final CommissionSplitRemoteDataSource _remote;
  CommissionSplitRepositoryImpl(this._remote);

  @override
  Future<CommissionSplit> getSplit(int dealId) => _remote.getSplit(dealId);

  @override
  Future<CommissionSplit> saveSplit(int dealId, CommissionSplitDraft draft) =>
      _remote.saveSplit(dealId, draft);

  @override
  Future<CommissionSplit> clearSplit(int dealId) => _remote.clearSplit(dealId);
}
