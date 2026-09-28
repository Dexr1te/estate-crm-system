import 'package:real_estate_crm/features/route/domain/day_route.dart';

abstract class DayRouteRepository {
  /// The viewings on [day] (local midnight to midnight) as a route, with
  /// every listing's pin that can be found.
  Future<DayRoute> getDayRoute(DateTime day);
}
