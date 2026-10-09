import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';

abstract class CommissionSplitRepository {
  /// Who gets what of the deal's commission, the deal's agent first.
  Future<CommissionSplit> getSplit(int dealId);

  /// Replaces the split; the deal's agent, a manager or an admin, totalling
  /// exactly 100%. A paid share has to stay as it was paid.
  Future<CommissionSplit> saveSplit(int dealId, CommissionSplitDraft draft);

  /// Gives the whole commission back to the deal's agent.
  Future<CommissionSplit> clearSplit(int dealId);

  /// The agency has paid share [shareId] of a won deal out; a manager or an
  /// admin, with an optional [note].
  Future<CommissionSplit> markPaid(int dealId, int shareId, {String? note});

  /// Share [shareId] is owed again: a payout marked by mistake.
  Future<CommissionSplit> undoPayout(int dealId, int shareId);
}
