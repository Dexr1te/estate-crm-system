import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';

abstract class CommissionSplitRepository {
  /// Who gets what of the deal's commission, the deal's agent first.
  Future<CommissionSplit> getSplit(int dealId);

  /// Replaces the split; the deal's agent, a manager or an admin, totalling
  /// exactly 100%.
  Future<CommissionSplit> saveSplit(int dealId, CommissionSplitDraft draft);

  /// Gives the whole commission back to the deal's agent.
  Future<CommissionSplit> clearSplit(int dealId);
}
