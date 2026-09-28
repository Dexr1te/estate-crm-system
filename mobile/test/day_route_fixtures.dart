import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';

import 'fakes.dart';

/// A Monday of viewings across Almaty, shared by the route's widget suites.
final routeDay = DateTime(2026, 9, 28);
DateTime routeAt(int h, [int m = 0]) =>
    routeDay.add(Duration(hours: h, minutes: m));

const republicSquare = LatLng(43.2383, 76.9453);
const megaAlmaty = LatLng(43.2018, 76.8927);
const koktobe = LatLng(43.2331, 76.9759);
const esentai = LatLng(43.2178, 76.9275);

MeetingResponse routeViewing(int id, DateTime at,
        {LatLng? pin,
        int? propertyId,
        String? client,
        String? title,
        bool completed = false,
        ViewingOutcome? outcome}) =>
    MeetingResponse(
      id: id,
      title: 'Viewing $id',
      scheduledAt: at,
      propertyId: propertyId ?? 10 + id,
      propertyTitle: title ?? 'Listing $id',
      propertyAddress: 'Street $id',
      propertyLatitude: pin?.latitude,
      propertyLongitude: pin?.longitude,
      completed: completed,
      outcome: outcome,
      agentId: 1,
      clientId: id,
      clientName: client ?? 'Client $id',
    );

/// Four on the map (the fourth's pin comes from its listing, not the
/// meeting), one with no pin anywhere, and a plain meeting that is no stop.
List<MeetingResponse> routeMeetings() => [
      routeViewing(1, routeAt(10), pin: republicSquare, client: 'Aigerim'),
      routeViewing(2, routeAt(10, 40), pin: megaAlmaty, client: 'Bolat'),
      routeViewing(3, routeAt(10, 50),
          pin: koktobe, outcome: ViewingOutcome.INTERESTED),
      routeViewing(4, routeAt(12)),
      routeViewing(5, routeAt(13)),
      routeViewing(6, routeAt(14)).copyWith(propertyId: null),
    ];

/// Answers listing reads and counts them, so a test can see which cost one.
class CountingPropertiesRepository extends FakePropertiesRepository {
  final List<int> reads = [];
  CountingPropertiesRepository(super.properties);

  @override
  Future<PropertyResponse> getProperty(int id) {
    reads.add(id);
    return super.getProperty(id);
  }
}

late CountingPropertiesRepository routeProperties;
late List<Uri> routeOpened;

/// Fakes in [Injector] and a recorder for anything handed to the phone.
/// [refuse] makes the opener turn down a scheme, as a missing app would.
void installRoute(
    {List<MeetingResponse>? meetings, Set<String> refuse = const {}}) {
  routeProperties = CountingPropertiesRepository([
    PropertyResponse(
        id: 14,
        title: 'Listing 4',
        latitude: esentai.latitude,
        longitude: esentai.longitude),
    const PropertyResponse(id: 15, title: 'Listing 5'),
  ]);
  Injector.propertiesRepository = routeProperties;
  Injector.meetingsRepository =
      FakeMeetingsRepository(meetings ?? routeMeetings());
  routeOpened = [];
  ContactActions.opener = (uri, _) async {
    routeOpened.add(uri);
    return !refuse.contains(uri.scheme);
  };
  addTearDown(ContactActions.resetOpener);
}
