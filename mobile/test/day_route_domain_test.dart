import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';

const republicSquare = LatLng(43.2383, 76.9453);
const megaAlmaty = LatLng(43.2018, 76.8927);
const koktobe = LatLng(43.2331, 76.9759);

MeetingResponse viewing(int id, DateTime at,
        {LatLng? pin,
        int? propertyId,
        bool completed = false,
        ViewingOutcome? outcome}) =>
    MeetingResponse(
      id: id,
      title: 'Viewing $id',
      scheduledAt: at,
      propertyId: propertyId ?? 100 + id,
      propertyTitle: 'Listing $id',
      propertyLatitude: pin?.latitude,
      propertyLongitude: pin?.longitude,
      completed: completed,
      outcome: outcome,
      agentId: 1,
      clientId: 1,
      clientName: 'Client $id',
    );

void main() {
  final day = DateTime(2026, 9, 28);
  DateTime at(int h, [int m = 0]) => day.add(Duration(hours: h, minutes: m));

  group('haversine', () {
    test('London to Paris is the textbook 343.5 km', () {
      expect(
          haversineKm(
              const LatLng(51.5074, -0.1278), const LatLng(48.8566, 2.3522)),
          closeTo(343.5, 0.5));
    });

    test('Almaty to Astana is about 970 km', () {
      expect(
          haversineKm(
              const LatLng(43.2380, 76.9450), const LatLng(51.1694, 71.4491)),
          closeTo(970, 10));
    });

    test('across Almaty: Republic Square to Mega is 5.9 km', () {
      expect(haversineKm(republicSquare, megaAlmaty).toStringAsFixed(1), '5.9');
    });

    test('is symmetric and zero for the same point', () {
      expect(haversineKm(republicSquare, koktobe),
          closeTo(haversineKm(koktobe, republicSquare), 1e-9));
      expect(haversineKm(koktobe, koktobe), 0);
    });
  });

  group('DayRoute.from', () {
    test('orders by the schedule, a tie by id, and numbers the pins', () {
      final route = DayRoute.from([
        viewing(3, at(15), pin: koktobe),
        viewing(2, at(10), pin: megaAlmaty),
        viewing(1, at(10), pin: republicSquare),
      ]);
      expect([for (final l in route.legs) l.stop.meeting.id], [1, 2, 3]);
      expect([for (final l in route.legs) l.number], [1, 2, 3]);
    });

    test('distance is from the previous stop, gap to the next start', () {
      final route = DayRoute.from([
        viewing(1, at(10), pin: republicSquare),
        viewing(2, at(11), pin: megaAlmaty),
        viewing(3, at(11, 40), pin: koktobe),
      ]);
      expect(route.legs[0].kmFromPrevious, isNull);
      expect(route.legs[1].kmFromPrevious, closeTo(5.9, 0.05));
      expect(route.legs[0].untilNext, const Duration(hours: 1));
      expect(route.legs[1].untilNext, const Duration(minutes: 40));
      expect(route.legs[2].untilNext, isNull);
      expect(route.totalKm, greaterThan(5.9));
    });

    test('plain meetings stay off, pinless viewings go to not-on-the-map', () {
      final plain = viewing(9, at(9)).copyWith(propertyId: null);
      final route = DayRoute.from([
        plain,
        viewing(1, at(10), pin: republicSquare),
        viewing(2, at(12)),
      ]);
      expect(route.legs, hasLength(1));
      expect([for (final s in route.unlocated) s.meeting.id], [2]);
    });

    test('a pin fetched for the listing fills a meeting that lacked one', () {
      final route = DayRoute.from([viewing(2, at(12), propertyId: 7)],
          pins: {7: koktobe});
      expect(route.legs.single.point, koktobe);
      expect(route.unlocated, isEmpty);
    });
  });

  group('overlaps', () {
    test('starts under 30 minutes apart collide, 30 or more do not', () {
      expect(overlaps(at(10), at(10)), isTrue);
      expect(overlaps(at(10), at(10, 29)), isTrue);
      expect(overlaps(at(10), at(10, 30)), isFalse);
    });

    test('the leg before a collision carries the warning', () {
      final route = DayRoute.from([
        viewing(1, at(10), pin: republicSquare),
        viewing(2, at(10, 15), pin: megaAlmaty),
        viewing(3, at(12), pin: koktobe),
      ]);
      expect(
          [for (final l in route.legs) l.overlapsNext], [true, false, false]);
    });
  });

  group('next stop', () {
    final route = DayRoute.from([
      viewing(1, at(10), pin: republicSquare),
      viewing(2, at(12), pin: megaAlmaty, outcome: ViewingOutcome.INTERESTED),
      viewing(3, at(14), pin: koktobe),
    ]);

    test('before the day, it is the first stop', () {
      expect(route.nextFrom(at(8))?.number, 1);
    });

    test('a viewing under way is still the next stop', () {
      expect(route.nextFrom(at(10, 20))?.number, 1);
    });

    test('a finished one is skipped, even if its time is ahead', () {
      expect(route.nextFrom(at(10, 30))?.number, 3);
      expect([for (final l in route.remainingFrom(at(10, 30))) l.number], [3]);
    });

    test('after the last, there is none and the whole day remains', () {
      expect(route.nextFrom(at(18)), isNull);
      expect(route.remainingFrom(at(18)), hasLength(3));
    });
  });

  test('hasRoute wants a viewing with a pin', () {
    expect(hasRoute([viewing(1, at(10))]), isFalse);
    expect(hasRoute([viewing(1, at(10), pin: koktobe)]), isTrue);
    expect(
        hasRoute([viewing(1, at(10), pin: koktobe).copyWith(propertyId: null)]),
        isFalse);
  });
}
