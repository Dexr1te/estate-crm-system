import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/cold_clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/today_tasks_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'going_cold_fixtures.dart';

FakeColdClientsRepository get _cold =>
    Injector.coldClientsRepository as FakeColdClientsRepository;

Future<void> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const ColdClientsScreen(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(coldNow);
    addTearDown(AppClock.reset);
    installCold(coldClients);
  });

  group('see all', () {
    testWidgets('lists everyone at 14 days, with what to do next',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.byType(ColdClientRow), findsNWidgets(4));
      expect(find.text('No contact for 14 days or more'), findsOneWidget);
      expect(find.text('Move the deal forward'), findsOneWidget);
      expect(find.text('Make the first call'), findsOneWidget);
      expect(_cold.queries.single, (14, 100));
    });

    testWidgets('the threshold changes the list', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('cold-days-30')));
      await tester.pumpAndSettle();
      expect(find.byType(ColdClientRow), findsNWidgets(2));
      expect(find.text('No contact for 30 days or more'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cold-days-7')));
      await tester.pumpAndSettle();
      expect(find.byType(ColdClientRow), findsNWidgets(5));
      expect(_cold.queries.map((q) => q.$1), [14, 30, 7]);
    });

    testWidgets('pull to refresh reads again', (tester) async {
      await _pumpScreen(tester);
      await tester.fling(
          find.byType(ColdClientRow).first, const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(_cold.queries, hasLength(2));
    });

    testWidgets('nobody going cold is an empty state, not a blank page',
        (tester) async {
      installCold(const []);
      await _pumpScreen(tester);

      expect(find.text('Nobody is going cold'), findsOneWidget);
    });
  });

  testWidgets('the dashboard carries the card right after today\'s tasks',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                AuthBloc(FakeAuthRepository())..add(AuthCheckEvent())),
        BlocProvider(
          create: (_) => DashboardBloc(
            FakeDashboardRepository(const DashboardSummary(coldCount: 9)),
            FakeMeetingsRepository(const []),
            FakeDealsRepository(const []),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('going-cold-card'));
    expect(card, findsOneWidget);
    expect(find.text('9 in all'), findsOneWidget,
        reason: 'the total comes from the summary');
    expect(tester.getTopLeft(card).dy,
        greaterThan(tester.getTopLeft(find.byType(TodayTasksCard)).dy));
  });
}
