import 'package:latlong2/latlong.dart';

/// The maps apps a route can be handed to.
enum MapsApp { google, yandex, dgis, apple }

/// Google Maps URLs take at most nine waypoints between origin and
/// destination (three in a mobile browser, but the app takes nine), so one
/// link carries at most eleven stops.
const googleMaxWaypoints = 9;
const googleMaxStops = googleMaxWaypoints + 2;

/// What to open: the app's own link first, then a web one if the app is not
/// there. [covered] is how many of the asked-for stops the link includes;
/// fewer than asked means the rest have to be opened after.
class MapsLink {
  final Uri primary;
  final Uri? fallback;
  final int covered;

  const MapsLink(this.primary, {this.fallback, required this.covered});
}

String _coord(double v) => v.toStringAsFixed(6);

/// `lat,lng` — the order Google, Yandex and Apple read.
String latLng(LatLng p) => '${_coord(p.latitude)},${_coord(p.longitude)}';

/// `lng,lat` — the order 2GIS reads.
String lngLat(LatLng p) => '${_coord(p.longitude)},${_coord(p.latitude)}';

/// Whether [app] can carry more than one stop in a link. 2GIS deep links
/// route to one destination reliably, and Apple's `daddr` takes one too, so
/// those two only ever get the next stop.
bool carriesWholeRoute(MapsApp app) =>
    app == MapsApp.google || app == MapsApp.yandex;

/// The driving route through [stops] in order, in [app]. An app that takes a
/// single destination gets the first stop only. Empty [stops] is a bug.
MapsLink mapsLink(MapsApp app, List<LatLng> stops) {
  assert(stops.isNotEmpty, 'a route needs at least one stop');
  return switch (app) {
    MapsApp.google => googleLink(stops),
    MapsApp.yandex => yandexLink(stops),
    MapsApp.dgis => dgisLink(stops.first),
    MapsApp.apple => appleLink(stops.first),
  };
}

/// Google Maps directions. One stop: a destination from wherever the phone
/// is. More: origin, up to nine waypoints (`|`-separated, sent as `%7C`) and
/// destination; past eleven stops the link stops at the eleventh.
MapsLink googleLink(List<LatLng> stops) {
  final take = stops.take(googleMaxStops).toList();
  final params = <String>['api=1'];
  if (take.length == 1) {
    params.add('destination=${latLng(take.single)}');
  } else {
    params
      ..add('origin=${latLng(take.first)}')
      ..add('destination=${latLng(take.last)}');
    final middle = take.sublist(1, take.length - 1);
    if (middle.isNotEmpty) {
      params.add('waypoints=${middle.map(latLng).join('%7C')}');
    }
  }
  params.add('travelmode=driving');
  return MapsLink(
    Uri.parse('https://www.google.com/maps/dir/?${params.join('&')}'),
    covered: take.length,
  );
}

/// Yandex Maps: `rtext` is every stop `~`-separated, `rtt=auto` drives. The
/// app's scheme first, yandex.ru in a browser if it is not installed. With a
/// single stop the route starts from the phone's own position.
MapsLink yandexLink(List<LatLng> stops) {
  final points = stops.map(latLng).join('~');
  final rtext = stops.length == 1 ? '~$points' : points;
  final query = 'rtext=$rtext&rtt=auto';
  return MapsLink(
    Uri.parse('yandexmaps://maps.yandex.ru/?$query'),
    fallback: Uri.parse('https://yandex.ru/maps/?$query'),
    covered: stops.length,
  );
}

/// 2GIS: a drive to one point, longitude first.
MapsLink dgisLink(LatLng to) => MapsLink(
      Uri.parse('dgis://2gis.ru/routeSearch/rsType/car/to/${lngLat(to)}'),
      fallback:
          Uri.parse('https://2gis.ru/routeSearch/rsType/car/to/${lngLat(to)}'),
      covered: 1,
    );

/// Apple Maps: a drive to one point from where the phone is.
MapsLink appleLink(LatLng to) => MapsLink(
      Uri.parse('https://maps.apple.com/?daddr=${latLng(to)}&dirflg=d'),
      covered: 1,
    );

/// One row of the "open in" sheet: [app] over the stops from [first] to
/// [last] (indexes into the list the sheet was given, both included).
class MapsChoice {
  final MapsApp app;
  final int first;
  final int last;

  const MapsChoice(this.app, this.first, this.last);

  @override
  bool operator ==(Object other) =>
      other is MapsChoice &&
      other.app == app &&
      other.first == first &&
      other.last == last;

  @override
  int get hashCode => Object.hash(app, first, last);

  @override
  String toString() => 'MapsChoice(${app.name}, $first..$last)';
}

/// What the sheet offers for [stopCount] stops. For the next stop, every app
/// drives to stop 0. For the whole route, Yandex takes it all; Google takes
/// eleven at a time, so a longer day is split into links that each start
/// where the one before ended; 2GIS and Apple still only get the next stop.
/// Apple Maps is offered only where it is built in: [includeApple].
List<MapsChoice> mapsChoices(int stopCount,
    {required bool whole, required bool includeApple}) {
  assert(stopCount > 0, 'nothing to open');
  final last = stopCount - 1;
  final google = <MapsChoice>[];
  if (!whole || stopCount == 1) {
    google.add(const MapsChoice(MapsApp.google, 0, 0));
  } else {
    var start = 0;
    while (true) {
      final end = (start + googleMaxStops - 1).clamp(0, last);
      google.add(MapsChoice(MapsApp.google, start, end));
      if (end == last) break;
      start = end;
    }
  }
  return [
    ...google,
    MapsChoice(MapsApp.yandex, 0, whole ? last : 0),
    const MapsChoice(MapsApp.dgis, 0, 0),
    if (includeApple) const MapsChoice(MapsApp.apple, 0, 0),
  ];
}
