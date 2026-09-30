import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/domain/mandate.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/mandates_ending_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_badge.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_row.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'mandate_fixtures.dart';

/// The seller's agreement on a listing: the badge on the card and the
/// listing, the form that records it, and the dashboard card and list of the
/// agreements running out.

PropertyResponse _listing(
        {MandateType? type,
        DateTime? ends,
        PropertyStatus status = PropertyStatus.AVAILABLE}) =>
    PropertyResponse(
        id: 1,
        title: 'Flat',
        status: status,
        mandateType: type,
        mandateEndDate: ends);

DateTime _inDays(int days) =>
    DateTime(mandateNow.year, mandateNow.month, mandateNow.day + days);

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(390, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(mandateNow);
    addTearDown(AppClock.reset);
  });

  group('where an agreement stands', () {
    test('days are counted on calendar dates, whatever the hour', () {
      expect(
          mandateDaysLeft(
              _listing(type: MandateType.OPEN, ends: _inDays(0)), mandateNow),
          0);
      expect(
          mandateDaysLeft(_listing(type: MandateType.OPEN, ends: _inDays(3)),
              DateTime(2026, 10, 1, 23, 59)),
          3);
      expect(
          mandateDaysLeft(
              _listing(type: MandateType.EXCLUSIVE, ends: _inDays(-7)),
              mandateNow),
          -7);
      expect(mandateDaysLeft(_listing(type: MandateType.EXCLUSIVE), mandateNow),
          isNull);
      expect(mandateDaysLeft(_listing(ends: _inDays(3)), mandateNow), isNull,
          reason: 'a date without an agreement means nothing');
    });

    test('ending is today to fourteen days out; after that it holds', () {
      MandateUrgency at(int days) => mandateUrgency(
          _listing(type: MandateType.EXCLUSIVE, ends: _inDays(days)),
          mandateNow);
      expect(at(-1), MandateUrgency.ended);
      expect(at(0), MandateUrgency.ending);
      expect(at(14), MandateUrgency.ending);
      expect(at(15), MandateUrgency.active);
      expect(mandateUrgency(_listing(type: MandateType.EXCLUSIVE), mandateNow),
          MandateUrgency.active);
      expect(mandateUrgency(_listing(), mandateNow), MandateUrgency.none);
    });

    test('a sold listing no longer needs its agreement watched', () {
      final ended = _listing(type: MandateType.EXCLUSIVE, ends: _inDays(-2));
      expect(mandateNeedsAttention(ended, mandateNow), isTrue);
      expect(
          mandateNeedsAttention(
              ended.copyWith(status: PropertyStatus.RESERVED), mandateNow),
          isTrue);
      expect(
          mandateNeedsAttention(
              ended.copyWith(status: PropertyStatus.SOLD), mandateNow),
          isFalse);
    });

    test('the listing reads the agreement from JSON; an unknown kind is none',
        () {
      final p = PropertyResponse.fromJson({
        'id': 3,
        'mandateType': 'EXCLUSIVE',
        'mandateEndDate': '2026-10-12',
      });
      expect(p.mandateType, MandateType.EXCLUSIVE);
      expect(p.mandateEndDate, DateTime(2026, 10, 12));

      final future = PropertyResponse.fromJson(
          {'id': 4, 'mandateType': 'SOLE', 'mandateEndDate': null});
      expect(future.mandateType, isNull);

      final older = PropertyResponse.fromJson({'id': 5});
      expect(older.mandateType, isNull);
      expect(older.mandateEndDate, isNull);
    });
  });

  group('the wording', () {
    String? badge(AppLocalizations l10n, PropertyResponse p, String locale) =>
        mandateBadgeLabel(l10n, p, mandateNow, locale);

    test('the badge names the kind and the last day', () {
      expect(
          badge(en, _listing(type: MandateType.EXCLUSIVE, ends: _inDays(11)),
              'en'),
          'Exclusive until Oct 12');
      expect(
          badge(en, _listing(type: MandateType.OPEN, ends: _inDays(11)), 'en'),
          'Open until Oct 12');
      expect(
          badge(en, _listing(type: MandateType.EXCLUSIVE), 'en'), 'Exclusive');
      expect(
          badge(en, _listing(type: MandateType.OPEN), 'en'), 'Open agreement');
      expect(
          badge(en, _listing(type: MandateType.OPEN, ends: _inDays(-7)), 'en'),
          'Agreement ended Sep 24');
      expect(
          badge(en, _listing(type: MandateType.EXCLUSIVE, ends: _inDays(-7)),
              'en'),
          'Exclusive ended Sep 24');
      expect(
          badge(
              en,
              _listing(
                  type: MandateType.EXCLUSIVE, ends: DateTime(2027, 1, 31)),
              'en'),
          'Exclusive until Jan 31, 2027',
          reason: 'another year says which');
      expect(badge(en, _listing(), 'en'), isNull);
    });

    test('in Russian and Kazakh too', () {
      final p = _listing(type: MandateType.EXCLUSIVE, ends: _inDays(11));
      expect(badge(ru, p, 'ru'), startsWith('Эксклюзив до 12'));
      expect(badge(kk, p, 'kk'), contains('дейін эксклюзив'));
    });

    test('time left, with plural forms', () {
      expect(mandateTimeLeftLabel(en, 0), 'Ends today');
      expect(mandateTimeLeftLabel(en, 1), 'Ends tomorrow');
      expect(mandateTimeLeftLabel(en, 5), 'Ends in 5 days');
      expect(mandateTimeLeftLabel(en, -1), 'Ended yesterday');
      expect(mandateTimeLeftLabel(en, -7), 'Ended 7 days ago');
      expect(mandateTimeLeftLabel(ru, 5), 'Истекает через 5 дней');
      expect(mandateTimeLeftLabel(ru, 2), 'Истекает через 2 дня');
      expect(mandateTimeLeftLabel(ru, -21), 'Истёк 21 день назад');
      expect(mandateTimeLeftLabel(kk, 5), '5 күннен кейін аяқталады');
      expect(mandateTimeLeftLabel(kk, 0), 'Бүгін аяқталады');
    });
  });

  group('the badge on a listing card', () {
    setUp(() => installMandates(const []));

    testWidgets('warns when the agreement ends within two weeks',
        (tester) async {
      final p = _listing(type: MandateType.EXCLUSIVE, ends: _inDays(5));
      await _pump(tester, PropertyCard(property: p, onTap: () {}));
      expect(find.byKey(const ValueKey('mandate-badge-1-warning')),
          findsOneWidget);
      expect(find.text('Exclusive until Oct 6'), findsOneWidget);
    });

    testWidgets('warns once it has ended on a listing still for sale',
        (tester) async {
      final p = _listing(
          type: MandateType.OPEN,
          ends: _inDays(-3),
          status: PropertyStatus.RESERVED);
      await _pump(tester, PropertyCard(property: p, onTap: () {}));
      expect(find.byKey(const ValueKey('mandate-badge-1-warning')),
          findsOneWidget);
      expect(find.text('Agreement ended Sep 28'), findsOneWidget);
    });

    testWidgets('is quiet while the agreement holds, or once the flat is sold',
        (tester) async {
      await _pump(
          tester,
          PropertyCard(
              property:
                  _listing(type: MandateType.EXCLUSIVE, ends: _inDays(30)),
              onTap: () {}));
      expect(find.byKey(const ValueKey('mandate-badge-1')), findsOneWidget);
      expect(find.text('Exclusive until Oct 31'), findsOneWidget);

      await _pump(
          tester,
          PropertyCard(
              property: _listing(
                  type: MandateType.EXCLUSIVE,
                  ends: _inDays(-3),
                  status: PropertyStatus.SOLD),
              onTap: () {}));
      expect(find.byKey(const ValueKey('mandate-badge-1')), findsOneWidget);
    });

    testWidgets('is not there without an agreement', (tester) async {
      await _pump(tester, PropertyCard(property: _listing(), onTap: () {}));
      expect(find.byType(MandateBadge), findsNothing);
    });
  });

  group('the dashboard card', () {
    Future<void> pumpCard(WidgetTester tester, {VoidCallback? onSeeAll}) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bloc = mandatesBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(mandatesCardApp(bloc, onSeeAll: onSeeAll));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the soonest three, how long each has, and the total',
        (tester) async {
      installMandates(mandateListings);
      await pumpCard(tester);

      expect(find.byType(MandateRow), findsNWidgets(3));
      expect(find.text('Ended 7 days ago'), findsOneWidget);
      expect(find.text('Ends today'), findsOneWidget);
      expect(find.text('Ends in 5 days'), findsOneWidget);
      expect(find.text('Abaya 10'), findsNothing);
      expect(find.text('4 in all'), findsOneWidget);
      expect(find.text('Open until Oct 1 · Daniyar Abenov'), findsOneWidget);
    });

    testWidgets('a row opens its listing, and See all goes to the list',
        (tester) async {
      installMandates(mandateListings);
      var seeAll = 0;
      await pumpCard(tester, onSeeAll: () => seeAll++);

      await tester.tap(find.byKey(const ValueKey('mandates-see-all')));
      expect(seeAll, 1);

      await tester.tap(find.text('Kok-Tobe house'));
      await tester.pumpAndSettle();
      expect(find.text('listing 13'), findsOneWidget);
    });

    testWidgets('is not there at all when no agreement is running out',
        (tester) async {
      installMandates(const []);
      await pumpCard(tester);
      expect(find.byKey(const ValueKey('mandates-card')), findsNothing);
      expect(find.byKey(const ValueKey('mandates-hidden')), findsOneWidget);
    });

    testWidgets('keeps a failure inside the card, and can try again',
        (tester) async {
      final repo = installMandates(mandateListings, fail: true);
      await pumpCard(tester);
      expect(find.text('Could not load the agreements running out'),
          findsOneWidget);

      repo.failMandates = false;
      await tester.tap(find.byKey(const ValueKey('mandates-retry')));
      await tester.pumpAndSettle();
      expect(find.byType(MandateRow), findsNWidgets(3));
      expect(repo.mandatesRequests, 2);
    });
  });

  group('the full list', () {
    testWidgets('lists every one, with the count', (tester) async {
      installMandates(mandateListings);
      await _pumpScreen(tester);
      expect(find.byType(MandateRow), findsNWidgets(4));
      expect(find.text('Ends in 14 days'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('says so when nothing is running out', (tester) async {
      installMandates(const []);
      await _pumpScreen(tester);
      expect(find.text('No agreements running out'), findsOneWidget);
    });
  });

  group('the listing form', () {
    Future<void> toDetails(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Next — details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next — details'));
      await tester.pumpAndSettle();
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Update Property'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update Property'));
      await tester.pumpAndSettle();
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      await tester.ensureVisible(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }

    testWidgets('an agreement is recorded with its last day', (tester) async {
      final repo = installMandates(const [
        PropertyResponse(
            id: 1, title: 'Flat', address: 'Abaya 10', price: 30000000),
      ]);
      await _pumpForm(tester, repo);
      await toDetails(tester);

      expect(find.byKey(const ValueKey('mandate-end-date')), findsNothing,
          reason: 'no agreement, no day to pick');
      await tapKey(tester, 'mandate-type-EXCLUSIVE');
      expect(find.text('No end date'), findsOneWidget);

      await tapKey(tester, 'mandate-end-date');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Dec 30'), findsOneWidget);

      await submit(tester);
      final sent = repo.sent['update-1']!;
      expect(sent['mandateType'], 'EXCLUSIVE');
      expect(sent['mandateEndDate'], '2026-12-30');
    });

    testWidgets('an exclusive agreement can go without an end date',
        (tester) async {
      final repo = installMandates([
        PropertyResponse(
            id: 1,
            title: 'Flat',
            address: 'Abaya 10',
            price: 30000000,
            mandateType: MandateType.EXCLUSIVE,
            mandateEndDate: DateTime(2026, 10, 12)),
      ]);
      await _pumpForm(tester, repo);
      await toDetails(tester);
      expect(find.text('Oct 12'), findsOneWidget);

      await tapKey(tester, 'mandate-end-date-clear');
      expect(find.text('No end date'), findsOneWidget);

      await submit(tester);
      final sent = repo.sent['update-1']!;
      expect(sent['mandateType'], 'EXCLUSIVE');
      expect(sent.containsKey('mandateEndDate'), isTrue);
      expect(sent['mandateEndDate'], isNull);
    });

    testWidgets('None takes the agreement and its date off', (tester) async {
      final repo = installMandates([
        PropertyResponse(
            id: 1,
            title: 'Flat',
            address: 'Abaya 10',
            price: 30000000,
            mandateType: MandateType.OPEN,
            mandateEndDate: DateTime(2026, 10, 12)),
      ]);
      await _pumpForm(tester, repo);
      await toDetails(tester);

      await tapKey(tester, 'mandate-type-none');
      expect(find.byKey(const ValueKey('mandate-end-date')), findsNothing);

      await submit(tester);
      final sent = repo.sent['update-1']!;
      expect(sent.containsKey('mandateType'), isTrue);
      expect(sent['mandateType'], isNull);
      expect(sent['mandateEndDate'], isNull);
    });
  });
}

Future<void> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const MandatesEndingScreen(),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpForm(
    WidgetTester tester, FakePropertiesRepository repo) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  Injector.propertiesRepository = repo;
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
      BlocProvider(create: (_) => PropertiesBloc(repo)),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/properties/1/edit',
        routes: [
          GoRoute(
            path: '/properties',
            builder: (_, __) => const Scaffold(body: Text('listings')),
            routes: [
              GoRoute(
                path: ':id/edit',
                builder: (_, s) => PropertyFormScreen(
                    propertyId: int.parse(s.pathParameters['id']!)),
              ),
            ],
          ),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}
