import 'package:real_estate_crm/core/models/payout_models.dart';

abstract class PayoutsRepository {
  /// The shares of won deals in [status]: the whole agency for a manager,
  /// one colleague's with [agentId]; an agent's own otherwise. The totals
  /// cover both statuses.
  Future<PayoutList> getPayouts({required PayoutStatus status, int? agentId});
}
