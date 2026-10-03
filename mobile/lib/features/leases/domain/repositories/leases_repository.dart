import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';

abstract class LeasesRepository {
  /// Won rents whose lease ends within [days] of [from] (the phone's today),
  /// soonest first; the agency's, narrowed by data scope like the deals.
  Future<List<LeaseEnding>> getLeasesEnding(
      {required int days, DateTime? from});

  /// Carries a won rent's lease on to a later last day; the deal as it is now.
  Future<DealResponse> renew(int dealId, LeaseRenewal renewal);
}
