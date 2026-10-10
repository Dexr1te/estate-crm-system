import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';
import 'package:real_estate_crm/features/stars/presentation/screens/starred_screen.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/starred_entry_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Starred records on screen: the Starred list grouped as clients, listings
/// and deals, a row that opens its record and a star that takes it off; the
/// star in a record's header that flips at once and back with a message when
/// the server refuses; and the dashboard's way in. Every one fits every
/// acceptance size, theme, text scale and language.

final _now = DateTime(2026, 10, 9, 12, 0);

const _admin = AuthResponse(
    userId: 9, fullName: 'Platform Admin', role: Role.ADMIN, teamId: 1);

const _client = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova-Kuznetsova',
  phone: '+7 916 220-84-11',
  email: 'sokolova@mail.ru',
  type: ClientType.BUYER,
  agentName: 'Maria Kim-Doroshenko',
);

const _property = PropertyResponse(
  id: 1,
  title: 'Severny Residence, apartment 84 with a deliberately long name',
  address: 'Dmitrovskoye shosse, 107k2',
  city: 'Moscow',
  type: PropertyType.APARTMENT,
  status: PropertyStatus.AVAILABLE,
  price: 12300000,
);

const _deal = DealResponse(
  id: 1,
  title: 'Severny Residence, apartment 84 — a long deal title for wrapping',
  status: DealStatus.NEGOTIATION,
  clientId: 1,
  clientName: 'Irina Alexandrovna Sokolova-Kuznetsova',
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  dealPrice: 12300000,
);

List<StarredItem> _starred() => [
      StarredItem(
          type: StarType.deal,
          id: 1,
          title: _deal.title,
          subtitle: _deal.clientName,
          starredAt: _now.subtract(const Duration(hours: 1))),
      StarredItem(
          type: StarType.client,
          id: 1,
          title: _client.fullName,
          subtitle: _client.phone,
          starredAt: _now.subtract(const Duration(hours: 2))),
      StarredItem(
          type: StarType.property,
          id: 1,
          title: _property.title,
          subtitle: _property.address,
          starredAt: _now.subtract(const Duration(hours: 3))),
      StarredItem(
          type: StarType.client,
          id: 2,
          title: 'Алексей Петров',
          starredAt: _now.subtract(const Duration(hours: 4))),
    ];

void _installFakes() {
  Injector.clientsRepository = FakeClientsRepository(clients: const [_client]);
  Injector.propertiesRepository = FakePropertiesRepository(const [_property]);
  Injector.dealsRepository = FakeDealsRepository(const [_deal]);
  Injector.documentsRepository = FakeDocumentsRepository();
}

StarsBloc _stars(FakeStarsRepository repo) {
  final bloc = StarsBloc(repo)..add(StarsLoadEvent());
  addTearDown(bloc.close);
  return bloc;
}

/// A detail screen as the app has it: signed in, with the app-wide blocs.
Widget _detail(Widget screen, StarsBloc stars, {AuthBloc? auth}) =>
    MultiBlocProvider(
      providers: [
        if (auth != null)
          BlocProvider.value(value: auth)
        else
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) =>
                ClientsBloc(FakeClientsRepository(clients: const []))),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
        BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(const []))),
        BlocProvider.value(value: stars),
      ],
      child: screen,
    );

Widget _page(Widget child) => Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
            child: child,
          ),
        ),
      ),
    );

/// The Starred screen and the dashboard row behind a router, with every
/// record a placeholder page that names itself.
Widget _routed(StarsBloc stars, String initial) => BlocProvider.value(
      value: stars,
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: initial,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, _) =>
                  _page(StarredEntryRow(onTap: () => context.push('/stars'))),
            ),
            GoRoute(path: '/stars', builder: (_, __) => const StarredScreen()),
            for (final kind in ['clients', 'properties', 'deals'])
              GoRoute(
                path: '/$kind/:id',
                builder: (_, s) => Scaffold(
                    body: Text('$kind page ${s.pathParameters['id']}')),
              ),
          ],
        ),
      ),
    );

Future<AuthBloc> _signedIn(AuthResponse me) async {
  final auth = AuthBloc(FakeAuthRepository(user: me))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  return auth;
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

double _top(WidgetTester tester, Key key) =>
    tester.getTopLeft(find.byKey(key)).dy;

void main() {
  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });
  setUp(_installFakes);

  // Fitting ------------------------------------------------------------------------

  forEachAcceptanceCase('starred screen',
      (tester, size, brightness, scale) async {
    final stars = _stars(FakeStarsRepository(items: _starred()));
    await expectNoOverflow(
      tester,
      BlocProvider.value(value: stars, child: const StarredScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('starred-row-CLIENT-1')), findsOneWidget);
  });

  forEachAcceptanceCase('starred screen, nothing starred',
      (tester, size, brightness, scale) async {
    final stars = _stars(FakeStarsRepository());
    await expectNoOverflow(
      tester,
      BlocProvider.value(value: stars, child: const StarredScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('starred-empty')), findsOneWidget);
  });

  forEachAcceptanceCase('dashboard starred row',
      (tester, size, brightness, scale) async {
    for (final items in [_starred(), <StarredItem>[]]) {
      final stars = _stars(FakeStarsRepository(items: items));
      await expectNoOverflow(
        tester,
        BlocProvider.value(
          value: stars,
          child: _page(StarredEntryRow(onTap: () {})),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  forEachAcceptanceCase('client detail header with its star, as an admin',
      (tester, size, brightness, scale) async {
    final auth = await _signedIn(_admin);
    final stars = _stars(FakeStarsRepository(items: _starred()));
    await expectNoOverflow(
      tester,
      _detail(const ClientDetailScreen(id: 1), stars, auth: auth),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('client-merge')), findsOneWidget);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('starred screens render in ${locale.languageCode}',
        (tester) async {
      final auth = await _signedIn(_admin);
      for (final (name, items, screen) in [
        ('list', _starred(), const StarredScreen()),
        ('empty list', <StarredItem>[], const StarredScreen()),
        ('row', _starred(), _page(StarredEntryRow(onTap: () {}))),
        ('empty row', <StarredItem>[], _page(StarredEntryRow(onTap: () {}))),
        ('client', _starred(), const ClientDetailScreen(id: 1)),
        ('listing', _starred(), const PropertyDetailScreen(id: 1)),
        ('deal', _starred(), const DealDetailScreen(id: 1)),
      ]) {
        final stars = _stars(FakeStarsRepository(items: items));
        for (final brightness in Brightness.values) {
          await expectNoOverflow(
            tester,
            _detail(screen, stars, auth: auth),
            size: const Size(320, 568),
            brightness: brightness,
            textScale: 1.5,
            locale: locale,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '$name in ${locale.languageCode}, $brightness');
          await tester.pumpWidget(Container());
        }
      }
    });
  }

  // The Starred screen ---------------------------------------------------------------

  testWidgets(
      'groups clients, listings and deals under their headings, '
      'newest first in each', (tester) async {
    final stars = _stars(FakeStarsRepository(items: _starred()));
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();

    const clients = ValueKey('starred-section-CLIENT');
    const listings = ValueKey('starred-section-PROPERTY');
    const deals = ValueKey('starred-section-DEAL');
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Deals'), findsOneWidget);
    expect(_top(tester, clients), lessThan(_top(tester, listings)));
    expect(_top(tester, listings), lessThan(_top(tester, deals)));

    const first = ValueKey('starred-row-CLIENT-1');
    const second = ValueKey('starred-row-CLIENT-2');
    expect(_top(tester, clients), lessThan(_top(tester, first)));
    expect(_top(tester, first), lessThan(_top(tester, second)));
    expect(_top(tester, second), lessThan(_top(tester, listings)));
    expect(find.text('+7 916 220-84-11'), findsOneWidget);
  });

  testWidgets('a row opens its record', (tester) async {
    final stars = _stars(FakeStarsRepository(items: _starred()));
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();

    await _tapAndSettle(
        tester, find.byKey(const ValueKey('starred-row-PROPERTY-1')));
    await tester.pumpAndSettle();
    expect(find.text('properties page 1'), findsOneWidget);
  });

  testWidgets(
      'a row\'s star takes it off at once, and puts it back with a '
      'message when the server refuses', (tester) async {
    final repo = FakeStarsRepository(items: _starred());
    final stars = _stars(repo);
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();
    final gate = Completer<void>();
    repo
      ..gate = gate
      ..writeError = Exception('offline');

    await _tapAndSettle(
        tester, find.byKey(const ValueKey('starred-unstar-DEAL-1')));
    expect(find.byKey(const ValueKey('starred-row-DEAL-1')), findsNothing,
        reason: 'gone before the server answers');
    expect(find.text('Deals'), findsNothing,
        reason: 'a heading with nothing under it goes too');
    expect(repo.writes, ['DELETE DEAL 1']);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('starred-row-DEAL-1')), findsOneWidget);
    expect(find.text("Couldn't remove the star. Try again."), findsOneWidget);
  });

  testWidgets('a row\'s star that the server takes keeps it off',
      (tester) async {
    final repo = FakeStarsRepository(items: _starred());
    final stars = _stars(repo);
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();

    await _tapAndSettle(
        tester, find.byKey(const ValueKey('starred-unstar-CLIENT-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('starred-row-CLIENT-2')), findsNothing);
    expect(repo.items.map((i) => i.key),
        isNot(contains(const StarKey(StarType.client, 2))));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('with nothing starred it says how to star', (tester) async {
    final stars = _stars(FakeStarsRepository());
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing starred yet'), findsOneWidget);
    expect(
        find.text('Tap the star at the top of a client, a listing or a deal '
            'to keep it here, one tap away.'),
        findsOneWidget);
  });

  testWidgets('a list that cannot be read offers to try again', (tester) async {
    final repo = FakeStarsRepository(items: _starred())
      ..readError = Exception('offline');
    final stars = _stars(repo);
    await tester.pumpWidget(_routed(stars, '/stars'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your starred records"), findsOneWidget);

    repo.readError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('starred-row-DEAL-1')), findsOneWidget);
  });

  // The dashboard's way in -----------------------------------------------------------

  testWidgets(
      'the dashboard row counts the stars, names the first few and '
      'opens the list', (tester) async {
    final stars = _stars(FakeStarsRepository(items: _starred()));
    await tester.pumpWidget(_routed(stars, '/dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Starred: 4'), findsOneWidget);
    expect(find.text('${_deal.title}, ${_client.fullName}, ${_property.title}'),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('starred-entry')));
    await tester.pumpAndSettle();
    expect(find.byType(StarredScreen), findsOneWidget);
  });

  // The row on its own goes through every case above. The whole dashboard is
  // measured where its own tests measure it in each language (a long ru or kk
  // card elsewhere on it does not fit 320 at 1.5 today), and at the narrowest
  // and largest in English.
  for (final (locale, size, brightness, scale) in [
    (const Locale('en'), const Size(320, 568), Brightness.dark, 1.5),
    for (final locale in kAcceptanceLocales)
      (locale, const Size(390, 844), Brightness.light, 1.0),
  ]) {
    testWidgets(
        'the dashboard carries the row, and fits, in ${locale.languageCode} '
        'at ${size.width.toInt()} ${scale}x', (tester) async {
      final stars = _stars(FakeStarsRepository(items: _starred()));
      await expectNoOverflow(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) => AuthBloc(FakeAuthRepository(user: _admin))
                  ..add(AuthCheckEvent())),
            BlocProvider(
              create: (_) => DashboardBloc(
                FakeDashboardRepository(const DashboardSummary(
                    totalDeals: 1, activeDeals: 1, totalClients: 2)),
                FakeMeetingsRepository(const []),
                FakeDealsRepository(const [_deal]),
              ),
            ),
            BlocProvider.value(value: stars),
          ],
          child: const DashboardScreen(),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('starred-entry')), findsOneWidget);
    });
  }

  testWidgets('with nothing starred the dashboard row says how to start',
      (tester) async {
    final stars = _stars(FakeStarsRepository());
    await tester.pumpWidget(_routed(stars, '/dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Starred'), findsOneWidget);
    expect(find.text('Star the clients, listings and deals you are working on'),
        findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
  });

  // The header star ------------------------------------------------------------------

  testWidgets('the header star flips at once, in gold, and the list has it',
      (tester) async {
    final repo = FakeStarsRepository(records: {
      const StarKey(StarType.client, 1): (
        title: _client.fullName,
        subtitle: _client.phone,
      ),
    });
    final stars = _stars(repo);
    await expectNoOverflow(
      tester,
      _detail(const ClientDetailScreen(id: 1), stars),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Star'), findsOneWidget);
    final gate = Completer<void>();
    repo.gate = gate;

    await tester.tap(find.byKey(const ValueKey('star-toggle')));
    await tester.pump();
    final icon = tester.widget<Icon>(find.descendant(
        of: find.byKey(const ValueKey('star-toggle')),
        matching: find.byType(Icon)));
    expect(icon.icon, Icons.star_rounded,
        reason: 'filled before the server answers');
    expect(icon.color, AppTokens.light.accent);
    expect(find.byTooltip('Remove star'), findsOneWidget);
    expect(repo.writes, ['PUT CLIENT 1']);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove star'), findsOneWidget);
    expect(stars.state.items.single.title, _client.fullName);
    expect(stars.state.items.single.subtitle, _client.phone);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a header star the server refuses goes back, with a message',
      (tester) async {
    final repo = FakeStarsRepository()..writeError = Exception('offline');
    final stars = _stars(repo);
    await expectNoOverflow(
      tester,
      _detail(const DealDetailScreen(id: 1), stars),
      size: const Size(390, 844),
      brightness: Brightness.dark,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('star-toggle')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Star'), findsOneWidget);
    expect(stars.state.isStarred(const StarKey(StarType.deal, 1)), isFalse);
    expect(find.text("Couldn't star it. Try again."), findsOneWidget);
  });

  testWidgets('a starred listing\'s header star is filled, and unstars',
      (tester) async {
    final repo = FakeStarsRepository(items: _starred());
    final stars = _stars(repo);
    await expectNoOverflow(
      tester,
      _detail(const PropertyDetailScreen(id: 1), stars),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('ru'),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Убрать из избранного'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('star-toggle')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('В избранное'), findsOneWidget);
    expect(repo.writes, ['DELETE PROPERTY 1']);
  });

  testWidgets('where no starred list is provided, the header has no star',
      (tester) async {
    await expectNoOverflow(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) =>
                  ClientsBloc(FakeClientsRepository(clients: const []))),
        ],
        child: const ClientDetailScreen(id: 1),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('star-toggle')), findsNothing);
  });
}
