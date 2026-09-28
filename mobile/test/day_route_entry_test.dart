import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/goal/goal_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'day_route_fixtures.dart';
import 'fakes.dart';

/// Where the route is offered: the calendar's day and the dashboard's
/// today, and only when there is something to draw.

Uri? _opened;

Widget _routed(Widget home, List<MeetingResponse> meetings) {
  final repo = FakeMeetingsRepository(meetings);
  Injector.meetingsRepository = repo;
  Injector.tasksRepository = FakeTasksRepository(const []);
  Injector.clientsRepository = FakeClientsRepository(clients: const []);
  Injector.dealsRepository = FakeDealsRepository(const []);
  return MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (_) => AuthBloc(FakeAuthRepository())..add(AuthCheckEvent())),
      BlocProvider(create: (_) => MeetingsBloc(repo)),
      BlocProvider(create: (_) => GoalBloc()..add(GoalChangedEvent(null))),
      BlocProvider(
        create: (_) => DashboardBloc(
          FakeDashboardRepository(const DashboardSummary()),
          repo,
          FakeDealsRepository(const []),
        ),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, __) => home),
          GoRoute(
            path: '/route',
            builder: (_, s) {
              _opened = s.uri;
              return const Scaffold(body: Text('route screen'));
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _pump(
    WidgetTester tester, Widget home, List<MeetingResponse> meetings) async {
  _opened = null;
  AppClock.freeze(routeAt(8));
  addTearDown(AppClock.reset);
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_routed(home, meetings));
  await tester.pumpAndSettle();
}

const _calendar = Scaffold(body: MeetingsScreen(initialMonth: true));
const _dashboard = Scaffold(body: DashboardScreen());

Finder _key(String k) => find.byKey(ValueKey(k));

void main() {
  group('calendar day', () {
    testWidgets('a day with a pinned viewing offers its route', (tester) async {
      await _pump(tester, _calendar, routeMeetings());
      expect(find.text('Route for this day'), findsOneWidget);

      await tester.ensureVisible(_key('calendar-day-route'));
      await tester.tap(_key('calendar-day-route'));
      await tester.pumpAndSettle();
      expect(find.text('route screen'), findsOneWidget);
      expect(_opened?.queryParameters, {'date': '2026-09-28'});
    });

    testWidgets('pinless viewings and plain meetings offer none',
        (tester) async {
      await _pump(tester, _calendar, [
        routeViewing(4, routeAt(12)),
        routeViewing(6, routeAt(14)).copyWith(propertyId: null),
      ]);
      expect(find.text('Viewing 4'), findsOneWidget);
      expect(_key('calendar-day-route'), findsNothing);
    });

    testWidgets('another day without viewings offers none', (tester) async {
      await _pump(tester, _calendar, routeMeetings());
      await tester.tap(_key('calendar-day-2026-9-29'));
      await tester.pumpAndSettle();
      expect(_key('calendar-day-route'), findsNothing);
    });
  });

  group('dashboard', () {
    testWidgets("today's pinned viewings: Today's route opens it",
        (tester) async {
      await _pump(tester, _dashboard, routeMeetings());
      expect(find.text("Today's route"), findsOneWidget);

      await tester.ensureVisible(_key('dashboard-today-route'));
      await tester.tap(_key('dashboard-today-route'));
      await tester.pumpAndSettle();
      expect(_opened?.queryParameters, {'date': '2026-09-28'});
    });

    testWidgets('a pinned viewing tomorrow is no route for today',
        (tester) async {
      await _pump(tester, _dashboard, [
        routeViewing(1, routeAt(34), pin: republicSquare),
      ]);
      expect(find.text('Viewing 1'), findsWidgets);
      expect(_key('dashboard-today-route'), findsNothing);
    });
  });
}
