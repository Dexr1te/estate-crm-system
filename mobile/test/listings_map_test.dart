import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_text_scaling.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Listings on a map: the list's Map view with a price on every pinned flat,
/// the form's pin, and the detail's still map with a way out to Maps.
///
/// Every map here draws blank tiles (flutter_test_config), so nothing reaches
/// OpenStreetMap; the fake repository records the rectangles asked for.

// Around Almaty's centre, where a map with no better idea opens.
const _listings = [
  PropertyResponse(
    id: 1,
    title: 'Esentai Park, apartment 12 with a deliberately long name',
    address: 'Al-Farabi 77',
    city: 'Almaty',
    price: 28000000,
    rooms: 3,
    areaSqm: 92,
    latitude: 43.2400,
    longitude: 76.8900,
  ),
  PropertyResponse(
    id: 2,
    title: 'Kok-Tobe house',
    address: 'Kok-Tobe 5',
    city: 'Almaty',
    type: PropertyType.HOUSE,
    status: PropertyStatus.SOLD,
    price: 54000000,
    latitude: 43.2350,
    longitude: 76.8820,
  ),
  PropertyResponse(
    id: 3,
    title: 'No pin yet',
    address: 'Abaya 10',
    city: 'Almaty',
    price: 19000000,
  ),
];

late FakePropertiesRepository _repo;
late List<Uri> _opened;

void _install({List<PropertyResponse> listings = _listings}) {
  _repo = FakePropertiesRepository(listings);
  Injector.propertiesRepository = _repo;
  Injector.clientsRepository = FakeClientsRepository();
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
  _opened = [];
  ContactActions.opener = (uri, _) async {
    _opened.add(uri);
    return true;
  };
  addTearDown(ContactActions.resetOpener);
}

Widget _blocs(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_repo)),
      ],
      child: child,
    );

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

/// The screens under a real router, for the taps that navigate.
Widget _routed(String initial) => _blocs(MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(
              path: '/properties',
              builder: (_, __) => const PropertiesScreen(),
              routes: [
                GoRoute(
                    path: 'new',
                    builder: (_, __) => const PropertyFormScreen()),
                GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        _Stub('property ${s.pathParameters['id']}'),
                    routes: [
                      GoRoute(
                          path: 'edit',
                          builder: (_, s) => PropertyFormScreen(
                              propertyId: int.parse(s.pathParameters['id']!))),
                    ]),
              ]),
        ],
      ),
      builder: (context, child) => MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: AppTextScaling(child: child ?? const SizedBox.shrink()),
      ),
    ));

Future<void> _pumpRouted(WidgetTester tester, String initial) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_routed(initial));
  await tester.pumpAndSettle();
}

Finder _pin(int id) =>
    find.byWidgetPredicate((w) => w is PricePin && w.property.id == id);

Future<void> _openMap(WidgetTester tester) async {
  await tester.tap(find.text('Map'));
  await tester.pumpAndSettle();
}

/// flutter_map holds a single tap back until a double tap is ruled out.
Future<void> _tapMap(WidgetTester tester, Finder finder,
    {Offset offset = Offset.zero}) async {
  await tester.tapAt(tester.getCenter(finder) + offset);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  group('the list and the map', () {
    testWidgets('List / Map switches the body and the map asks for its area',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      expect(
          find.byKey(const ValueKey('properties-view-tabs')), findsOneWidget);
      expect(find.byKey(const ValueKey('properties-map')), findsNothing);

      await _openMap(tester);
      expect(find.byKey(const ValueKey('properties-map')), findsOneWidget);
      expect(_repo.areaRequests, hasLength(1));
      final area = _repo.areaRequests.single;
      expect(area.south, lessThan(43.235));
      expect(area.north, greaterThan(43.24));
      expect(BlankTileProvider.requests, greaterThan(0));

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('properties-map')), findsNothing);
    });

    testWidgets('a pin for every listing with a location, a price on each',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);

      expect(_pin(1), findsOneWidget);
      expect(_pin(2), findsOneWidget);
      expect(_pin(3), findsNothing);
      expect(find.descendant(of: _pin(1), matching: find.text(r'$28.0M')),
          findsOneWidget);
    });

    testWidgets('tapping a pin shows its card, and the card opens the listing',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);

      await tester.tap(_pin(1));
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('map-card-1'));
      expect(card, findsOneWidget);
      expect(
          find.descendant(of: card, matching: find.textContaining('Esentai')),
          findsOneWidget);

      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.text('property 1'), findsOneWidget);
    });

    testWidgets('moving the map asks again once it rests, not on every frame',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);
      final first = _repo.areaRequests.single;

      final map = find.byKey(const ValueKey('properties-map'));
      final gesture = await tester.startGesture(tester.getCenter(map));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(-30, 0));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_repo.areaRequests, hasLength(1), reason: 'still settling');

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(_repo.areaRequests, hasLength(2));
      expect(_repo.areaRequests.last.west, greaterThan(first.west));
    });

    testWidgets('the map honours the list filters', (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);

      final sold = find.text('Sold').first;
      await tester.ensureVisible(sold);
      await tester.pumpAndSettle();
      await tester.tap(sold);
      await tester.pumpAndSettle();
      expect(_repo.areaStatuses.last, PropertyStatus.SOLD);
      expect(_pin(1), findsNothing);
      expect(_pin(2), findsOneWidget);
    });

    testWidgets('listings with no location are counted and can be opened',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);

      final hint = find.byKey(const ValueKey('map-unpinned-hint'));
      expect(hint, findsOneWidget);
      expect(find.text('1 listing has no location'), findsOneWidget);

      await tester.tap(hint);
      await tester.pumpAndSettle();
      expect(find.text('Not on the map'), findsOneWidget);
      await tester.tap(find.text('No pin yet'));
      await tester.pumpAndSettle();
      expect(find.text('property 3'), findsOneWidget);
    });

    testWidgets('an empty area says so', (tester) async {
      _install(listings: const []);
      await _pumpRouted(tester, '/properties');
      await _openMap(tester);
      expect(find.byKey(const ValueKey('map-empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('map-unpinned-hint')), findsNothing);
    });
  });

  group('the pin in the form', () {
    final picker = find.byKey(const ValueKey('location-picker-map'));
    final pin = find.byKey(const ValueKey('location-picker-pin'));
    final clear = find.byKey(const ValueKey('location-picker-clear'));

    Future<void> submit(WidgetTester tester, String label) async {
      await tester.ensureVisible(find.text('Next — details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next — details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'a tap on the map drops the pin and the listing is sent with it',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties/new');
      await tester.enterText(find.byType(TextFormField).at(0), 'Pinned flat');
      await tester.enterText(find.byType(TextFormField).at(1), '30000000');
      await tester.enterText(find.byType(TextFormField).at(3), 'Abaya 10');

      await tester.ensureVisible(picker);
      await tester.pumpAndSettle();
      expect(pin, findsNothing);
      expect(clear, findsNothing);
      await _tapMap(tester, picker, offset: const Offset(20, 10));
      expect(pin, findsOneWidget);
      expect(clear, findsOneWidget);

      await submit(tester, 'Create Property');
      final sent = _repo.sent['create']!;
      // No city typed: the map opened on Almaty, and the tap landed near it.
      expect(sent['latitude'], closeTo(43.2389, 0.02));
      expect(sent['longitude'], closeTo(76.8897, 0.02));
      expect(sent['longitude'], greaterThan(76.8897));
    });

    testWidgets('an edit opens on the saved pin, and clearing it sends nulls',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties/1/edit');
      await tester.ensureVisible(picker);
      await tester.pumpAndSettle();
      expect(pin, findsOneWidget);

      await tester.tap(clear);
      await tester.pumpAndSettle();
      expect(pin, findsNothing);

      await submit(tester, 'Update Property');
      final sent = _repo.sent['update-1']!;
      expect(sent.containsKey('latitude'), isTrue);
      expect(sent['latitude'], isNull);
      expect(sent['longitude'], isNull);
    });

    testWidgets('dragging the pin moves it, not the map under it',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties/1/edit');
      await tester.ensureVisible(picker);
      await tester.pumpAndSettle();
      final pinBefore = tester.getCenter(pin);

      final gesture = await tester.startGesture(tester.getCenter(pin));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getCenter(pin).dx - pinBefore.dx, closeTo(60, 2));

      await submit(tester, 'Update Property');
      final sent = _repo.sent['update-1']!;
      expect(sent['longitude'], greaterThan(76.8900));
      expect(sent['latitude'], closeTo(43.2400, 0.0005));
    });

    testWidgets('an edit that leaves the pin alone sends it back unchanged',
        (tester) async {
      _install();
      await _pumpRouted(tester, '/properties/1/edit');
      await submit(tester, 'Update Property');
      expect(_repo.sent['update-1']!['latitude'], 43.2400);
      expect(_repo.sent['update-1']!['longitude'], 76.8900);
    });
  });

  group('the map on the detail', () {
    Future<void> showDetail(WidgetTester tester, int id) async {
      await expectNoOverflow(tester, _blocs(PropertyDetailScreen(id: id)),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
    }

    final preview = find.byKey(const ValueKey('property-location'));
    final open = find.byKey(const ValueKey('property-open-in-maps'));

    testWidgets('a pinned listing shows a still map and opens Maps on the pin',
        (tester) async {
      _install();
      await showDetail(tester, 1);
      await tester.ensureVisible(preview);
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('property-location-map')), findsOneWidget);
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);

      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      // Tests run as Android: the geo: link any maps app answers.
      expect(_opened.single.scheme, 'geo');
      expect(_opened.single.toString(), contains('43.240000,76.890000'));
    });

    testWidgets('with no maps app the pin opens on openstreetmap.org',
        (tester) async {
      _install();
      ContactActions.opener = (uri, mode) async {
        _opened.add(uri);
        expect(mode, LaunchMode.externalApplication);
        return uri.scheme != 'geo';
      };
      await showDetail(tester, 1);
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(_opened.map((u) => u.scheme), ['geo', 'https']);
      expect(_opened.last.host, 'www.openstreetmap.org');
      expect(_opened.last.queryParameters['mlat'], '43.240000');
    });

    testWidgets('a listing with no pin has no map', (tester) async {
      _install();
      await showDetail(tester, 3);
      expect(preview, findsNothing);
      expect(open, findsNothing);
    });
  });
}
