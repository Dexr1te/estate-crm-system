import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

/// Mean Earth radius in kilometres, the one haversine is usually quoted with.
const earthRadiusKm = 6371.0088;

/// How far apart two points are over the ground, in km, as the crow flies.
/// Not the drive: a river or a one-way street can double it.
double haversineKm(LatLng a, LatLng b) {
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLng = rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(h)));
}

/// A meeting has no end time, so a viewing is taken to last at least this
/// long: two that start closer together than this overlap, and one that
/// started longer ago than this is over.
const minViewingLength = Duration(minutes: 30);

/// One viewing on the day's route.
class RouteStop {
  final MeetingResponse meeting;

  /// Where the listing stands; null when nobody dropped a pin yet.
  final LatLng? point;

  const RouteStop(this.meeting, this.point);

  DateTime get at => meeting.scheduledAt;

  /// An outcome recorded, or ticked off: nothing left to do there.
  bool get isDone => meeting.completed || meeting.outcome != null;

  bool isPast(DateTime now) => !at.add(minViewingLength).isAfter(now);
}

/// A stop on the map, with what the list says about the leg into it and
/// the time before the next one.
class RouteLeg {
  final RouteStop stop;

  /// 1-based, the number on the pin: the order of the schedule.
  final int number;

  /// Straight-line km from the stop before; null for the first.
  final double? kmFromPrevious;

  /// From this viewing's start to the next one's; null for the last.
  final Duration? untilNext;

  /// The next viewing starts before this one can be over.
  final bool overlapsNext;

  const RouteLeg({
    required this.stop,
    required this.number,
    this.kmFromPrevious,
    this.untilNext,
    this.overlapsNext = false,
  });

  LatLng get point => stop.point!;
}

/// A day's viewings in the order they are booked: the ones with a pin as a
/// route, the rest set aside for "Not on the map".
class DayRoute {
  final List<RouteLeg> legs;
  final List<RouteStop> unlocated;

  const DayRoute({required this.legs, required this.unlocated});

  bool get isEmpty => legs.isEmpty && unlocated.isEmpty;

  List<LatLng> get points => [for (final l in legs) l.point];

  double get totalKm =>
      legs.fold(0.0, (sum, l) => sum + (l.kmFromPrevious ?? 0));

  /// Builds the route from [meetings]: viewings only (a meeting with a
  /// listing), soonest first, a tie broken by id so the numbers never shuffle.
  /// [pins] fills in coordinates a meeting did not carry, by listing id.
  factory DayRoute.from(List<MeetingResponse> meetings,
      {Map<int, LatLng> pins = const {}}) {
    final stops = [
      for (final m in meetings)
        if (m.propertyId != null) RouteStop(m, pinOf(m) ?? pins[m.propertyId]),
    ]..sort((a, b) {
        final byTime = a.at.compareTo(b.at);
        return byTime != 0 ? byTime : a.meeting.id.compareTo(b.meeting.id);
      });
    final located = [
      for (final s in stops)
        if (s.point != null) s
    ];
    final legs = <RouteLeg>[
      for (var i = 0; i < located.length; i++)
        RouteLeg(
          stop: located[i],
          number: i + 1,
          kmFromPrevious: i == 0
              ? null
              : haversineKm(located[i - 1].point!, located[i].point!),
          untilNext: i + 1 < located.length
              ? located[i + 1].at.difference(located[i].at)
              : null,
          overlapsNext: i + 1 < located.length &&
              overlaps(located[i].at, located[i + 1].at),
        ),
    ];
    return DayRoute(
      legs: legs,
      unlocated: [
        for (final s in stops)
          if (s.point == null) s
      ],
    );
  }

  /// The stop to drive to now: the first on the map that is neither done nor
  /// over. Null once the day is through.
  RouteLeg? nextFrom(DateTime now) {
    for (final l in legs) {
      if (!l.stop.isDone && !l.stop.isPast(now)) return l;
    }
    return null;
  }

  /// What is still ahead, from the next stop on; the whole day if it is over.
  List<RouteLeg> remainingFrom(DateTime now) {
    final next = nextFrom(now);
    return next == null ? legs : legs.sublist(next.number - 1);
  }
}

/// The pin a meeting carries for its listing, if both halves are there.
LatLng? pinOf(MeetingResponse m) {
  final lat = m.propertyLatitude;
  final lng = m.propertyLongitude;
  return lat == null || lng == null ? null : LatLng(lat, lng);
}

/// Two viewings starting [a] then [b] collide when the second begins before
/// the first can be over.
bool overlaps(DateTime a, DateTime b) =>
    b.difference(a).abs() < minViewingLength;

/// Whether a day's meetings are worth a route: at least one viewing with a pin.
bool hasRoute(Iterable<MeetingResponse> meetings) =>
    meetings.any((m) => m.propertyId != null && pinOf(m) != null);

/// `yyyy-MM-dd` for the route's address, the day it opens on.
String routeDateParam(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// The day in a `?date=` value; today when it is missing or unreadable.
DateTime parseRouteDate(String? raw) {
  final parsed = raw == null ? null : DateTime.tryParse(raw);
  final day = parsed ?? AppClock.now();
  return DateTime(day.year, day.month, day.day);
}
