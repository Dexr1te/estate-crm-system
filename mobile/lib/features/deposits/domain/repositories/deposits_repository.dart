import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';

abstract class DepositsRepository {
  /// A deal's deposits, the latest first; at most one is active.
  Future<List<DealDeposit>> getDealDeposits(int dealId);

  /// Records a deposit; the deal's agent or a manager, on a deal still under
  /// way without an active one.
  Future<DealDeposit> record(int dealId, DepositDraft draft);

  /// Corrects an active deposit.
  Future<DealDeposit> update(int dealId, int depositId, DepositDraft draft);

  /// Ends an active deposit: applied, refunded or forfeited, on a day.
  Future<DealDeposit> close(int dealId, int depositId, DepositClosing closing);

  /// Active deposits whose hold ends within a week or has ended, soonest
  /// first; scoped like the deals.
  Future<List<DealDeposit>> getDepositsEnding();
}
