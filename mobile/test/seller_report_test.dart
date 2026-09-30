import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/seller_report_screen.dart';
import 'package:real_estate_crm/features/properties/report/seller_report_text.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _property = PropertyResponse(
  id: 12,
  title: 'Светлая квартира у парка на Абая, с видом на горы',
  address: 'ул. Абая, 150, кв. 45',
  city: 'Алматы',
  status: PropertyStatus.AVAILABLE,
  price: 45000000,
  areaSqm: 64,
  rooms: 2,
);

final _full = SellerReport(
  propertyId: 12,
  title: _property.title,
  address: _property.address,
  city: 'Алматы',
  listedAt: DateTime(2026, 8, 31, 10),
  daysOnMarket: 30,
  generatedOn: DateTime(2026, 9, 30),
  viewings: SellerReportViewings(
    total: 5,
    held: 4,
    upcoming: 1,
    outcomes: const {'INTERESTED': 1, 'REJECTED': 1, 'NO_SHOW': 1},
    awaitingOutcome: 1,
    lastHeldAt: DateTime(2026, 9, 28, 18),
    nextAt: DateTime(2026, 10, 1, 12),
  ),
  publicLink: const SellerReportLink(active: true, views: 17, leads: 4),
  price: SellerReportPrice(
    current: 45000000,
    original: 50000000,
    change: -5000000,
    changePercent: -10,
    changes: [
      PropertyPriceChange(
          id: 1,
          oldPrice: 50000000,
          newPrice: 48000000,
          changedAt: DateTime(2026, 9, 10)),
      PropertyPriceChange(
          id: 2,
          oldPrice: 48000000,
          newPrice: 45000000,
          changedAt: DateTime(2026, 9, 25)),
    ],
  ),
  matchingBuyers: 3,
);

final _bare = SellerReport(
  propertyId: 12,
  title: _property.title,
  address: _property.address,
  listedAt: DateTime(2026, 9, 30, 9),
  generatedOn: DateTime(2026, 9, 30),
  price: const SellerReportPrice(current: 45000000, original: 45000000),
);

late FakePropertiesRepository _repo;
late FakeShareGateway _share;

Future<void> _open(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
}) async {
  await expectNoOverflow(tester, const SellerReportScreen(propertyId: 12),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
}

Future<void> _tapShare(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('seller-report-share'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Each metric's value by its caption, as the card was given them.
Map<String, String> _metrics(WidgetTester tester) => {
      for (final m in tester
          .widget<MetricsCard>(
              find.byKey(const ValueKey('seller-report-metrics')))
          .metrics)
        m.caption: m.value,
    };

void main() {
  setUp(() {
    _repo = FakePropertiesRepository([_property])..sellerReport = _full;
    _share = FakeShareGateway();
    Injector.propertiesRepository = _repo;
    Injector.shareGateway = _share;
  });

  testWidgets('the figures: days, viewings, outcomes, link, buyers, price',
      (tester) async {
    await _open(tester);

    expect(find.text('Report for the seller'), findsOneWidget);
    expect(find.text(_property.title), findsOneWidget);
    expect(_metrics(tester), {
      'Days on the market': '30',
      'Buyers it fits': '3',
      'Viewings held': '4',
      'Viewings to come': '1',
      'Link opens': '17',
      'Enquiries from the link': '4',
    });
    for (final caption in _metrics(tester).keys) {
      expect(find.text(caption), findsOneWidget);
    }

    for (final outcome in ViewingOutcome.values) {
      final row = find.byKey(ValueKey('seller-report-outcome-${outcome.name}'));
      expect(
          find.descendant(of: row, matching: find.text('1')), findsOneWidget);
    }
    expect(find.text('Not recorded yet'), findsOneWidget);
    expect(find.text('Next viewing Oct 1, 2026'), findsOneWidget);

    expect(find.text(formatPrice(50000000)), findsOneWidget);
    expect(find.text('−10%'), findsOneWidget);
    expect(find.text('${formatPrice(48000000)} → ${formatPrice(45000000)}'),
        findsOneWidget);
  });

  testWidgets('Share sends a plain-text summary with every figure',
      (tester) async {
    await _open(tester);
    await _tapShare(tester);

    expect(_share.calls, 1);
    final text = _share.sharedText!;
    expect(text, startsWith('Report for the seller: ${_property.title}'));
    expect(text, contains('As of Sep 30, 2026'));
    expect(text, contains('Listed on Aug 31, 2026'));
    expect(text, contains('Days on the market: 30'));
    expect(text, contains('Viewings held: 4'));
    expect(text, contains('Viewings to come: 1'));
    expect(text, contains('  Interested: 1'));
    expect(text, contains('  Turned it down: 1'));
    expect(text, contains('  No show: 1'));
    expect(text, contains('  Not recorded yet: 1'));
    expect(text, contains('Link opens: 17'));
    expect(text, contains('Enquiries from the link: 4'));
    expect(text, contains('Buyers it fits: 3'));
    expect(text, contains('Listed at: ${formatPrice(50000000)}'));
    expect(text, contains('Now: ${formatPrice(45000000)} (−10%)'));
    expect(
        text,
        contains('  Sep 10, 2026: '
            '${formatPrice(50000000)} → ${formatPrice(48000000)}'));
    expect(find.byType(SnackBar), findsNothing);
  });

  test('the summary is in the language it is given', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final text = sellerReportText(_full, ru, 'ru');
    expect(text, startsWith('Отчёт для продавца: '));
    expect(text, contains('Дней в продаже: 30'));
    expect(text, contains('Заинтересовался: 1'));
    expect(text, isNot(contains('INTERESTED')));
  });

  test('a listing with nothing to report yet still reads sensibly', () {
    final text = sellerReportText(_bare, AppLocalizationsEn(), 'en');
    expect(text, contains('Viewings held: 0'));
    expect(text, isNot(contains('Not recorded yet')));
    expect(text, contains('Price: ${formatPrice(45000000)}'));
    expect(text, contains('The price has not changed since it was listed'));
  });

  testWidgets('a share that fails says so', (tester) async {
    _share.outcome = ShareOutcome.failed;
    await _open(tester);
    await _tapShare(tester);
    await tester.pump();
    expect(find.text("Couldn't share the report. Try again."), findsOneWidget);
  });

  testWidgets('no viewings and an unchanged price: the empty lines show',
      (tester) async {
    _repo.sellerReport = _bare;
    await _open(tester);

    expect(find.text('No viewings yet'), findsOneWidget);
    expect(find.text('The price has not changed since it was listed'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('seller-report-outcome-INTERESTED')),
        findsNothing);
    expect(find.text('Listed at'), findsNothing);
  });

  testWidgets('a failed load offers a retry that recovers', (tester) async {
    _repo.sellerReportError = Exception('offline');
    await _open(tester);

    expect(find.text("Couldn't load the report"), findsOneWidget);
    expect(find.byKey(const ValueKey('seller-report-share')), findsNothing);

    _repo.sellerReportError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(_repo.sellerReportReads, 2);
    expect(find.text("Couldn't load the report"), findsNothing);
    expect(find.byKey(const ValueKey('seller-report-metrics')), findsOneWidget);
  });

  testWidgets('the listing screen opens the report', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/properties/12',
      routes: [
        GoRoute(
          path: '/properties/:id',
          builder: (_, __) => const PropertyDetailScreen(id: 12),
          routes: [
            GoRoute(
              path: 'report',
              builder: (_, s) => SellerReportScreen(
                  propertyId: int.parse(s.pathParameters['id']!)),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_repo)),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();

    final entry = find.byKey(const ValueKey('property-seller-report'));
    await tester.ensureVisible(entry);
    await tester.pumpAndSettle();
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.byType(SellerReportScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('seller-report-metrics')), findsOneWidget);
  });

  forEachAcceptanceCase('seller report', (tester, size, brightness, scale) {
    return expectNoOverflow(tester, const SellerReportScreen(propertyId: 12),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      for (final report in [_full, _bare]) {
        testWidgets(
            'renders in ${locale.languageCode} ${brightness.name} at 1.5x, '
            '${report == _full ? 'full' : 'bare'}', (tester) async {
          _repo.sellerReport = report;
          await _open(tester,
              size: const Size(320, 568),
              brightness: brightness,
              textScale: 1.5,
              locale: locale);
          final share = find.byKey(const ValueKey('seller-report-share'));
          await tester.ensureVisible(share);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(share, findsOneWidget);
        });
      }
    }
  }
}
