import 'package:real_estate_crm/core/models/models.dart';

/// Contract for dashboard data access.
abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
}
