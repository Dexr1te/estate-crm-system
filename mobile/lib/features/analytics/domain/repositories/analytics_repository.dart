import 'package:real_estate_crm/core/models/models.dart';

abstract class AnalyticsRepository {
  Future<DealFunnel> getFunnel(
      {required DateTime from, required DateTime to, int? agentId});

  /// Clients created in [from, to) by how they reached the agency.
  Future<LeadSourceBreakdown> getLeadSources(
      {required DateTime from, required DateTime to, int? agentId});
}
