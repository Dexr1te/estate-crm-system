import 'package:real_estate_crm/core/models/models.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
}
