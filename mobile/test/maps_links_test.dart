import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/features/route/domain/maps_links.dart';

const a = LatLng(43.2383, 76.9453);
const b = LatLng(43.2018, 76.8927);
const c = LatLng(43.2331, 76.9759);

List<LatLng> many(int n) =>
    [for (var i = 0; i < n; i++) LatLng(43.2 + i / 1000, 76.9 + i / 1000)];

void main() {
  group('Google Maps', () {
    test('one stop is a destination from where the phone is', () {
      final link = googleLink([a]);
      expect(link.primary.toString(),
          'https://www.google.com/maps/dir/?api=1&destination=43.238300,76.945300&travelmode=driving');
      expect(link.primary.queryParameters.containsKey('origin'), isFalse);
      expect(link.covered, 1);
      expect(link.fallback, isNull);
    });

    test('three stops: origin, a waypoint, destination', () {
      final q = googleLink([a, b, c]).primary.queryParameters;
      expect(q['api'], '1');
      expect(q['origin'], '43.238300,76.945300');
      expect(q['waypoints'], '43.201800,76.892700');
      expect(q['destination'], '43.233100,76.975900');
      expect(q['travelmode'], 'driving');
    });

    test('waypoints are pipe-separated, sent encoded', () {
      final link = googleLink([a, b, c, a]);
      expect(link.primary.toString(),
          contains('waypoints=43.201800,76.892700%7C43.233100,76.975900'));
      expect(link.primary.queryParameters['waypoints'],
          '43.201800,76.892700|43.233100,76.975900');
    });

    test('eleven stops fit: nine waypoints', () {
      final link = googleLink(many(11));
      expect(link.covered, 11);
      expect(link.primary.queryParameters['waypoints']!.split('|'),
          hasLength(googleMaxWaypoints));
    });

    test('past eleven the link stops at the eleventh', () {
      final stops = many(14);
      final link = googleLink(stops);
      expect(link.covered, 11);
      expect(
          link.primary.queryParameters['waypoints']!.split('|'), hasLength(9));
      expect(link.primary.queryParameters['destination'], latLng(stops[10]));
      // The rest start from where this one ended.
      expect(googleLink(stops.sublist(10)).covered, 4);
    });

    test('a negative coordinate keeps its sign', () {
      expect(
          googleLink([const LatLng(-33.8688, 151.2093)])
              .primary
              .queryParameters['destination'],
          '-33.868800,151.209300');
    });
  });

  group('Yandex Maps', () {
    test('every stop, tilde-separated, by car, app then web', () {
      final link = yandexLink([a, b, c]);
      expect(link.primary.toString(),
          'yandexmaps://maps.yandex.ru/?rtext=43.238300,76.945300~43.201800,76.892700~43.233100,76.975900&rtt=auto');
      expect(link.fallback.toString(),
          'https://yandex.ru/maps/?rtext=43.238300,76.945300~43.201800,76.892700~43.233100,76.975900&rtt=auto');
      expect(link.primary.queryParameters['rtt'], 'auto');
      expect(link.covered, 3);
    });

    test('one stop starts from the phone: an empty first point', () {
      expect(yandexLink([a]).primary.queryParameters['rtext'],
          '~43.238300,76.945300');
    });

    test('has no cap of its own', () {
      expect(yandexLink(many(14)).covered, 14);
    });
  });

  group('2GIS', () {
    test('one destination, longitude first, app then web', () {
      final link = dgisLink(a);
      expect(link.primary.toString(),
          'dgis://2gis.ru/routeSearch/rsType/car/to/76.945300,43.238300');
      expect(link.fallback.toString(),
          'https://2gis.ru/routeSearch/rsType/car/to/76.945300,43.238300');
    });

    test('a whole route in 2GIS is its first stop', () {
      final link = mapsLink(MapsApp.dgis, [b, c]);
      expect(link.covered, 1);
      expect(link.primary.path, endsWith(lngLat(b)));
    });
  });

  group('Apple Maps', () {
    test('a drive to one point', () {
      final link = mapsLink(MapsApp.apple, [c, a]);
      expect(link.primary.toString(),
          'https://maps.apple.com/?daddr=43.233100,76.975900&dirflg=d');
      expect(link.covered, 1);
    });
  });

  group('the sheet offers', () {
    test('the next stop in every app, Apple only where asked', () {
      expect(mapsChoices(5, whole: false, includeApple: false), const [
        MapsChoice(MapsApp.google, 0, 0),
        MapsChoice(MapsApp.yandex, 0, 0),
        MapsChoice(MapsApp.dgis, 0, 0),
      ]);
      expect(mapsChoices(5, whole: false, includeApple: true).last,
          const MapsChoice(MapsApp.apple, 0, 0));
    });

    test('a short whole route: one Google link, Yandex all of it', () {
      expect(mapsChoices(4, whole: true, includeApple: false), const [
        MapsChoice(MapsApp.google, 0, 3),
        MapsChoice(MapsApp.yandex, 0, 3),
        MapsChoice(MapsApp.dgis, 0, 0),
      ]);
    });

    test('fourteen stops split Google in two, the second from the 11th', () {
      final google = mapsChoices(14, whole: true, includeApple: false)
          .where((c) => c.app == MapsApp.google)
          .toList();
      expect(google, const [
        MapsChoice(MapsApp.google, 0, 10),
        MapsChoice(MapsApp.google, 10, 13),
      ]);
    });

    test('twenty-one stops take exactly two Google links', () {
      final google = mapsChoices(21, whole: true, includeApple: false)
          .where((c) => c.app == MapsApp.google);
      expect(google.map((c) => (c.first, c.last)), [(0, 10), (10, 20)]);
    });
  });

  test('only Google and Yandex carry a whole route', () {
    expect([for (final app in MapsApp.values) carriesWholeRoute(app)],
        [true, true, false, false]);
  });
}
