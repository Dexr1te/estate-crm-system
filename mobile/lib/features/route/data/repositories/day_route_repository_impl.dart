import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/domain/repositories/day_route_repository.dart';

/// One call for the day's meetings, which carry their listing's pin. Only a
/// viewing whose meeting came without one (no pin yet, or a server from
/// before meetings carried it) costs a listing read; there is no batch-by-id
/// endpoint, so those go [maxParallel] at a time. A day has a handful of
/// viewings, so that is one round, and a pin dropped a minute ago shows up.
class DayRouteRepositoryImpl implements DayRouteRepository {
  final MeetingsRepository _meetings;
  final PropertiesRepository _properties;

  static const maxParallel = 4;

  DayRouteRepositoryImpl(this._meetings, this._properties);

  @override
  Future<DayRoute> getDayRoute(DateTime day) async {
    final from = DateTime(day.year, day.month, day.day);
    final to = DateTime(day.year, day.month, day.day + 1);
    final meetings = await _meetings.getMeetingsBetween(from, to);
    final missing = {
      for (final m in meetings)
        if (m.propertyId != null && pinOf(m) == null) m.propertyId!,
    }.toList();
    final pins = <int, LatLng>{};
    for (var i = 0; i < missing.length; i += maxParallel) {
      final round = missing.skip(i).take(maxParallel);
      final found = await Future.wait(round.map(_pin));
      for (final hit in found) {
        if (hit != null) pins[hit.$1] = hit.$2;
      }
    }
    return DayRoute.from(meetings, pins: pins);
  }

  /// A listing that is gone or out of reach just stays off the map.
  Future<(int, LatLng)?> _pin(int id) async {
    try {
      final p = await _properties.getProperty(id);
      final lat = p.latitude;
      final lng = p.longitude;
      return lat == null || lng == null ? null : (id, LatLng(lat, lng));
    } catch (_) {
      return null;
    }
  }
}
