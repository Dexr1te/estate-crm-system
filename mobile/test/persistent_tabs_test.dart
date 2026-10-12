import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/navigation/active_tab.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

const _signedIn = AuthResponse(
    userId: 7,
    fullName: 'Sultan',
    email: 'sultan@estate.crm',
    role: Role.AGENT,
    teamId: 1,
    teamName: 'Downtown desk');

final _manager = _signedIn.copyWith(userId: 8, role: Role.MANAGER);

final _admin = _signedIn.copyWith(userId: 9, role: Role.ADMIN);

const _tabLabels = ['Home', 'Clients', 'Listings', 'Deals', 'Calendar'];

final _fab = find.byWidgetPredicate(
    (w) => w is QuickAddButton && w.shape == QuickAddShape.floating,
    description: 'the floating "+"');

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

    setUp(() {
      Injector.adminRepository = FakeAdminRepository();
      Injector.teamsRepository = FakeTeamsRepository();
    });

    Future<void> pumpApp(WidgetTester tester,
        {AuthResponse user = _signedIn}) async {
      dashboard = _CountingDashboard();
      final auth = AuthBloc(FakeAuthRepository(user: user))
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
          BlocProvider(
              create: (_) =>
                  PropertiesBloc(FakePropertiesRepository(const []))),
          BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(const []))),
          BlocProvider(
              create: (_) => MeetingsBloc(FakeMeetingsRepository(const []))),
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

    List<String> barLabels(WidgetTester tester) => [
          for (final t in tester.widgetList<Text>(find.descendant(
              of: find.byType(AppBottomNav), matching: find.byType(Text))))
            t.data!,
        ];

    for (final user in [_signedIn, _manager, _admin]) {
      testWidgets('${user.role.name} gets the five shared tabs and no more',
          (tester) async {
        await pumpApp(tester, user: user);
        expect(barLabels(tester), _tabLabels);
        expect(
            find.descendant(
                of: find.byType(AppBottomNav), matching: find.text('Team')),
            findsNothing);
        expect(
            find.descendant(
                of: find.byType(AppBottomNav), matching: find.text('Admin')),
            findsNothing);
      });
    }

    testWidgets(
        'a console out of the bar selects no tab, and the bar still '
        'leads back', (tester) async {
      await pumpApp(tester, user: _admin);
      expect(find.byKey(const ValueKey('nav-lens')), findsOneWidget);

      router.go('/admin');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nav-lens')), findsNothing);
      expect(barLabels(tester), _tabLabels);

      await tester.tap(find.descendant(
          of: find.byType(AppBottomNav), matching: find.text('Home')));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-lens')), findsOneWidget);
    });

    testWidgets('system back on a console goes home instead of out of the app',
        (tester) async {
      await pumpApp(tester, user: _manager);
      router.go('/team-console');
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('system back still pops a screen pushed over a tab',
        (tester) async {
      await pumpApp(tester);
      unawaited(router.push<Object?>('/tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(TasksScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(TasksScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('switching tabs ticks once under the thumb', (tester) async {
      await pumpApp(tester);
      final haptics = <Object?>[];
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      final bar = find.byType(AppBottomNav);
      await tester
          .tap(find.descendant(of: bar, matching: find.text('Clients')));
      await tester.pumpAndSettle();
      expect(haptics, ['HapticFeedbackType.selectionClick']);

      await tester
          .tap(find.descendant(of: bar, matching: find.text('Clients')));
      await tester.pumpAndSettle();
      expect(haptics, hasLength(1),
          reason: 'tapping the tab already on show switches nothing');
    });

    testWidgets('the "+" floats over every tab root, never over a pushed page',
        (tester) async {
      await pumpApp(tester, user: _manager);
      for (final route in [...ShellTabs.routes]) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(_fab, findsOneWidget, reason: route);
      }

      router.go('/dashboard');
      await tester.pumpAndSettle();
      unawaited(router.push<Object?>('/tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(TasksScreen), findsOneWidget);
      expect(_fab, findsNothing);
    });

    testWidgets('the "+" sits above the bar, clear of it, in reach of a thumb',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpApp(tester);

      final fab = tester.getRect(_fab);
      final bar = tester.getRect(find.byType(AppBottomNav));
      expect(fab.width, greaterThanOrEqualTo(AppMetrics.minHitTarget));
      expect(fab.height, greaterThanOrEqualTo(AppMetrics.minHitTarget));
      expect(fab.bottom, lessThanOrEqualTo(bar.top));
      expect(fab.right, greaterThan(390 / 2));

      final dashboard = tester.element(find.byType(DashboardScreen));
      expect(AppMetrics.navClearance(dashboard),
          greaterThanOrEqualTo(844 - fab.top),
          reason: 'a tab scrolled to its end must not hide under the "+"');
    });

    testWidgets('the "+" opens the quick-add sheet', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpApp(tester);
      await tester.tap(_fab);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quick-add-client')), findsOneWidget);
    });

    testWidgets('on a wide screen the "+" and the console live in the side nav',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpApp(tester, user: _manager);

      expect(find.byType(AppBottomNav), findsNothing);
      expect(_fab, findsNothing);
      expect(
          find.byWidgetPredicate(
              (w) => w is QuickAddButton && w.shape == QuickAddShape.rail),
          findsOneWidget);

      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('a pushed page slides in from the right on Android',
        (tester) async {
      await pumpApp(tester);
      unawaited(router.push<Object?>('/tasks'));
      await tester.pumpAndSettle();
      final route = ModalRoute.of(tester.element(find.byType(TasksScreen)))!;
      expect(route.settings, isA<MaterialPage<void>>());
    });

    testWidgets(
        'a pushed page is a Cupertino page on iOS, with edge swipe-back',
        (tester) async {
      await pumpApp(tester);
      unawaited(router.push<Object?>('/tasks'));
      await tester.pumpAndSettle();
      final route = ModalRoute.of(tester.element(find.byType(TasksScreen)))!;
      expect(route.settings, isA<CupertinoPage<void>>());

      await tester.dragFrom(const Offset(4, 400), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.byType(TasksScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('tab roots switch in place, with no slide', (tester) async {
      await pumpApp(tester);
      router.go('/clients');
      await tester.pump();
      expect(find.byType(DashboardScreen), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });
}
