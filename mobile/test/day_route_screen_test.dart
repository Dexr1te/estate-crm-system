import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/presentation/screens/route_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'day_route_fixtures.dart';

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

Widget _app() => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (context, _) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () =>
                      context.push('/route?date=${routeDateParam(routeDay)}'),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/route',
            builder: (_, s) =>
                RouteScreen(day: parseRouteDate(s.uri.queryParameters['date'])),
          ),
          GoRoute(
            path: '/properties/:id/edit',
            builder: (_, s) => _Stub('edit ${s.pathParameters['id']}'),
          ),
          GoRoute(
            path: '/meetings/:id',
            builder: (_, s) => _Stub('meeting ${s.pathParameters['id']}'),
          ),
        ],
      ),
    );

Future<void> _open(WidgetTester tester, DateTime now) async {
  AppClock.freeze(now);
  addTearDown(AppClock.reset);
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app());
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

Finder _key(String k) => find.byKey(ValueKey(k));

Future<void> _tapKey(WidgetTester tester, String k) async {
  await tester.ensureVisible(_key(k));
  await tester.pumpAndSettle();
  await tester.tap(_key(k));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('numbered pins in schedule order, joined by a line',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(8));

    for (var n = 1; n <= 4; n++) {
      expect(_key('route-pin-$n'), findsOneWidget, reason: 'pin $n');
    }
    expect(_key('route-pin-5'), findsNothing);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('Straight lines between stops, not driving directions'),
        findsOneWidget);
    expect(find.textContaining('4 stops'), findsOneWidget);
  });

  testWidgets('the list: time, client, distance, gaps and overlaps',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(8));

    expect(find.text('10:00 · Aigerim'), findsOneWidget);
    expect(find.text('Listing 1 · Street 1'), findsOneWidget);
    expect(_key('route-km-1'), findsNothing);
    expect(find.text('5.9 km from the previous stop'), findsOneWidget);
    expect(find.text('40 min until the next one'), findsOneWidget);
    expect(_key('route-overlap-2'), findsOneWidget);
    expect(find.text('Overlaps the next viewing'), findsOneWidget);
    expect(find.text('1 h 10 min until the next one'), findsOneWidget);
    // Recorded outcome on stop 3.
    expect(find.text('Interested'), findsOneWidget);
  });

  testWidgets('pins come from the meeting; only the pinless cost a read',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(8));
    expect(routeProperties.reads..sort(), [14, 15]);
  });

  testWidgets('a pinless viewing is under Not on the map, and Add a pin edits',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(8));

    expect(_key('route-not-on-map'), findsOneWidget);
    expect(_key('route-unlocated-5'), findsOneWidget);
    expect(_key('route-unlocated-6'), findsNothing,
        reason: 'a plain meeting is no stop at all');
    await _tapKey(tester, 'route-add-pin-15');
    expect(find.text('edit 15'), findsOneWidget);
  });

  testWidgets('the next stop follows the clock', (tester) async {
    installRoute();
    await _open(tester, routeAt(10, 45));

    final stop1 = _key('route-stop-1');
    expect(
        find.ancestor(
            of: find.text('10:00 · Aigerim'), matching: find.byType(Opacity)),
        findsOneWidget,
        reason: 'stop 1 is over, so muted');
    expect(
        find.descendant(of: stop1, matching: find.text('Next')), findsNothing);
    expect(
        find.descendant(of: _key('route-stop-2'), matching: find.text('Next')),
        findsOneWidget);

    await _tapKey(tester, 'route-navigate-next');
    expect(find.text('Next stop: Listing 2 · Street 2'), findsOneWidget);
    await _tapKey(tester, 'route-app-google-0');
    expect(routeOpened.single.toString(),
        'https://www.google.com/maps/dir/?api=1&destination=43.201800,76.892700&travelmode=driving');
  });

  testWidgets('after the last stop there is nothing to navigate to',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(18));
    expect(_key('route-navigate-next'), findsNothing);
    expect(_key('route-day-over'), findsOneWidget);
  });

  testWidgets('Yandex falls back to the web when the app is not there',
      (tester) async {
    installRoute(refuse: {'yandexmaps'});
    await _open(tester, routeAt(8));
    await _tapKey(tester, 'route-open-whole');
    await _tapKey(tester, 'route-app-yandex-0');
    expect(routeOpened.map((u) => u.scheme), ['yandexmaps', 'https']);
    expect(routeOpened.last.toString(),
        'https://yandex.ru/maps/?rtext=43.238300,76.945300~43.201800,76.892700~43.233100,76.975900~43.217800,76.927500&rtt=auto');
  });

  testWidgets('the whole route: 2GIS is honest that it takes one stop',
      (tester) async {
    installRoute();
    await _open(tester, routeAt(8));
    await _tapKey(tester, 'route-open-whole');
    expect(find.text('Next stop only'), findsOneWidget);
    expect(find.text('Whole route, in order'), findsNWidgets(2));
    expect(_key('route-app-apple-0'), findsNothing);
    await _tapKey(tester, 'route-app-dgis-0');
    expect(routeOpened.single.toString(),
        'dgis://2gis.ru/routeSearch/rsType/car/to/76.945300,43.238300');
  });

  testWidgets('a nothing-opened launch says so', (tester) async {
    installRoute(refuse: {'https', 'yandexmaps', 'dgis'});
    await _open(tester, routeAt(8));
    await _tapKey(tester, 'route-navigate-next');
    await _tapKey(tester, 'route-app-google-0');
    expect(find.text("Couldn't open a maps app"), findsOneWidget);
  });

  testWidgets('Apple Maps is offered on iOS, for the next stop',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    installRoute();
    await _open(tester, routeAt(8));
    await _tapKey(tester, 'route-navigate-next');
    await _tapKey(tester, 'route-app-apple-0');
    expect(routeOpened.single.toString(),
        'https://maps.apple.com/?daddr=43.238300,76.945300&dirflg=d');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('fourteen stops: Google is offered in two parts', (tester) async {
    installRoute(meetings: [
      for (var i = 0; i < 14; i++)
        routeViewing(100 + i, routeAt(8, i * 30),
            pin: LatLng(republicSquare.latitude + i / 1000,
                republicSquare.longitude + i / 1000)),
    ]);
    await _open(tester, routeAt(7));
    await _tapKey(tester, 'route-open-whole');
    expect(find.text('Stops 1–11 of 14'), findsOneWidget);
    expect(find.text('Stops 11–14 of 14'), findsOneWidget);
    await _tapKey(tester, 'route-app-google-10');
    final q = routeOpened.single.queryParameters;
    expect(q['origin'], '43.248300,76.955300');
    expect(q['waypoints']!.split('|'), hasLength(2));
  });

  testWidgets('a day with no viewings says so', (tester) async {
    installRoute(meetings: []);
    await _open(tester, routeAt(8));
    expect(find.text('No viewings this day'), findsOneWidget);
  });
}
