import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/navigation/active_tab.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

const _signedIn = AuthResponse(
    userId: 7,
    fullName: 'Sultan',
    email: 'sultan@estate.crm',
    role: Role.AGENT,
    teamId: 1,
    teamName: 'Downtown desk');

class _CountingDashboard extends FakeDashboardRepository {
  _CountingDashboard() : super(const DashboardSummary(totalClients: 138));

  int calls = 0;

  @override
  Future<DashboardSummary> getDashboardSummary() {
    calls++;
    return super.getDashboardSummary();
  }
}

class _Probe extends StatefulWidget {
  final String route;
  final VoidCallback onRefresh;
  const _Probe({required this.route, required this.onRefresh});

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> with RefreshOnTabReturn {
  @override
  String get tabRoute => widget.route;

  @override
  void refreshTab() => widget.onRefresh();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  final start = DateTime(2026, 3, 12, 9);

  setUp(() => AppClock.freeze(start));
  tearDown(AppClock.reset);

  group('RefreshOnTabReturn', () {
    Future<void> show(
            WidgetTester tester, String active, VoidCallback onRefresh,
            {String route = '/b'}) =>
        tester.pumpWidget(ActiveTab(
            route: active, child: _Probe(route: route, onRefresh: onRefresh)));

    testWidgets('coming back to the tab refreshes it once it has gone stale',
        (tester) async {
      var refreshes = 0;
      await show(tester, '/b', () => refreshes++);
      await show(tester, '/a', () => refreshes++);

      AppClock.freeze(start.add(const Duration(seconds: 11)));
      await show(tester, '/b', () => refreshes++);

      expect(refreshes, 1);
    });

    testWidgets('a quick flick away and back leaves the data alone',
        (tester) async {
      var refreshes = 0;
      await show(tester, '/b', () => refreshes++);
      await show(tester, '/a', () => refreshes++);

      AppClock.freeze(start.add(const Duration(seconds: 3)));
      await show(tester, '/b', () => refreshes++);

      expect(refreshes, 0);
    });

    testWidgets('another tab becoming active is none of its business',
        (tester) async {
      var refreshes = 0;
      await show(tester, '/b', () => refreshes++);
      await show(tester, '/a', () => refreshes++);

      AppClock.freeze(start.add(const Duration(minutes: 5)));
      await show(tester, '/c', () => refreshes++);

      expect(refreshes, 0);
    });

    testWidgets('a screen shown on its own, outside the tabs, never refreshes',
        (tester) async {
      var refreshes = 0;
      await tester
          .pumpWidget(_Probe(route: '/b', onRefresh: () => refreshes++));

      AppClock.freeze(start.add(const Duration(minutes: 5)));
      await tester
          .pumpWidget(_Probe(route: '/b', onRefresh: () => refreshes++));

      expect(refreshes, 0);
    });
  });

  group('the tab shell', () {
    late _CountingDashboard dashboard;
    late GoRouter router;

    Future<void> pumpApp(WidgetTester tester) async {
      dashboard = _CountingDashboard();
      final auth = AuthBloc(FakeAuthRepository(user: _signedIn))
        ..add(AuthCheckEvent());
      addTearDown(auth.close);
      router = createRouter(auth);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider(
            create: (_) => DashboardBloc(
              dashboard,
              FakeMeetingsRepository(const []),
              FakeDealsRepository(const []),
            ),
          ),
          BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('the dashboard survives a trip to another tab', (tester) async {
      await pumpApp(tester);
      expect(find.byType(DashboardScreen), findsOneWidget);
      final before = tester.state(find.byType(DashboardScreen));

      router.go('/clients');
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
      expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget,
          reason: 'the tab stays built behind the one on show');

      router.go('/dashboard');
      await tester.pumpAndSettle();

      expect(tester.state(find.byType(DashboardScreen)), same(before));
      expect(dashboard.calls, 1,
          reason: 'a quick look at another tab must not refetch the summary');
    });

    testWidgets(
        'coming back after a while refreshes in place, with no skeleton',
        (tester) async {
      await pumpApp(tester);
      expect(find.text('138'), findsOneWidget);

      router.go('/clients');
      await tester.pumpAndSettle();

      AppClock.freeze(start.add(const Duration(seconds: 30)));
      router.go('/dashboard');
      await tester.pump();

      expect(find.text('138'), findsOneWidget,
          reason: 'the numbers already loaded stay up while they refresh');
      expect(find.byType(ShimmerMetricsCard), findsNothing);

      await tester.pumpAndSettle();
      expect(dashboard.calls, 2);
    });

    testWidgets('the bottom bar switches tabs without rebuilding them',
        (tester) async {
      await pumpApp(tester);
      final before = tester.state(find.byType(DashboardScreen));
      final nav = find.byType(AppBottomNav);
      final labels = find.descendant(of: nav, matching: find.byType(Text));

      await tester.tap(labels.at(1));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);

      await tester.tap(labels.at(0));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(DashboardScreen)), same(before));
    });
  });
}
