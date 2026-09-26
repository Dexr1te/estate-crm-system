
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// The notification centre: a bell with the unread count on the dashboard, a
/// feed grouped into today and earlier, and a tap that marks the line read and
/// opens what it is about. Every kind of line reads as a sentence in all three
/// languages, and the count is only polled while somebody could see it.

final _now = DateTime(2026, 9, 26, 15, 30);

AppNotification _n(int id, NotificationType type, DateTime at,
        {bool read = false,
        int? target,
        Map<String, dynamic> params = const {}}) =>
    AppNotification(
      id: id,
      type: type,
      targetId: target,
      params: params,
      createdAt: at,
      readAt: read ? at.add(const Duration(minutes: 1)) : null,
    );

List<AppNotification> _feed() => [
      _n(1, NotificationType.taskAssigned, DateTime(2026, 9, 26, 14),
          target: 11,
          params: {'actorName': 'Asel Nurlanovna', 'taskTitle': 'Call Irina'}),
      _n(2, NotificationType.dealStatusChanged, DateTime(2026, 9, 26, 9),
          target: 42,
          params: {
            'actorName': 'Asel Nurlanovna',
            'dealTitle': 'Dostyk flat',
            'fromStatus': 'LEAD',
            'toStatus': 'CLOSED_WON',
          }),
      _n(3, NotificationType.newMatch, DateTime(2026, 9, 25, 18),
          read: true,
          target: 7,
          params: {
            'propertyTitle': 'Dostyk 5',
            'buyerCount': 5,
            'buyerNames': ['Aigerim', 'Bolat', 'Daniyar'],
          }),
      _n(4, NotificationType.recordsHandedOver, DateTime(2026, 9, 22, 10),
          read: true,
          params: {'fromName': 'Timur Aliev', 'clients': 3, 'tasks': 1}),
    ];

late FakeNotificationsRepository _repo;

Widget _routed(String initial) => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(initialLocation: initial, routes: [
        GoRoute(
            path: '/home',
            builder: (_, __) =>
                const Scaffold(body: Center(child: NotificationBell()))),
        GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen()),
        GoRoute(
            path: '/deals/:id',
            builder: (_, s) =>
                Scaffold(body: Text('deal ${s.pathParameters['id']}'))),
        GoRoute(
            path: '/tasks',
            builder: (_, __) => const Scaffold(body: Text('task list'))),
      ]),
    );

Future<void> _pump(WidgetTester tester, String initial) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_routed(initial));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeNotificationsRepository(_feed());
    Injector.notificationsRepository = _repo;
  });

  tearDown(() {
    AppClock.reset();
    Injector.notificationsRepository = FakeNotificationsRepository();
  });

  group('the bell', () {
    testWidgets('carries the unread count and opens the feed', (tester) async {
      await _pump(tester, '/home');

      expect(find.byKey(const ValueKey('notifications-unread-badge')),
          findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows no badge when everything is read', (tester) async {
      _repo.items = [for (final n in _feed()) n.copyWith(readAt: _now)];
      await _pump(tester, '/home');

      expect(find.byKey(const ValueKey('notifications-unread-badge')),
          findsNothing);
    });

    testWidgets('caps a long count at 99+', (tester) async {
      _repo.items = [
        for (var i = 0; i < 120; i++)
          _n(100 + i, NotificationType.taskAssigned, _now),
      ];
      await _pump(tester, '/home');

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('drops back when the feed is read on another screen',
        (tester) async {
      await _pump(tester, '/home');
      expect(find.text('2'), findsOneWidget);

      await _repo.markAllRead();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('notifications-unread-badge')),
          findsNothing);
    });
  });

  group('the feed', () {
    testWidgets('groups today above earlier, newest first', (tester) async {
      await _pump(tester, '/notifications');

      final today = tester.getTopLeft(find.text('Today')).dy;
      final earlier = tester.getTopLeft(find.text('Earlier')).dy;
      final task = tester
          .getTopLeft(find.text('Asel Nurlanovna gave you a task: Call Irina'))
          .dy;
      final deal = tester
          .getTopLeft(find.text('Asel Nurlanovna moved Dostyk flat to Won'))
          .dy;
      final match = tester
          .getTopLeft(find.text('New listing for your buyers: Dostyk 5'))
          .dy;
      expect(today < task && task < deal && deal < earlier && earlier < match,
          isTrue);
      expect(find.byKey(const ValueKey('notification-unread-dot')),
          findsNWidgets(2));
    });

    testWidgets('a tap marks the line read and opens what it is about',
        (tester) async {
      await _pump(tester, '/notifications');

      await tester.tap(find.text('Asel Nurlanovna moved Dostyk flat to Won'));
      await tester.pumpAndSettle();

      expect(find.text('deal 42'), findsOneWidget);
      expect(_repo.markedRead, [2]);
    });

    testWidgets('a line already read opens without writing again',
        (tester) async {
      _repo.items = [
        _n(1, NotificationType.taskAssigned, _now, read: true, target: 11),
      ];
      await _pump(tester, '/notifications');

      await tester.tap(find.byKey(const ValueKey('notification-1')));
      await tester.pumpAndSettle();

      expect(find.text('task list'), findsOneWidget);
      expect(_repo.markedRead, isEmpty);
    });

    testWidgets('mark all read clears every dot and says so', (tester) async {
      await _pump(tester, '/notifications');

      await tester.tap(find.byKey(const ValueKey('notifications-mark-all')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_repo.markAllCalls, 1);
      expect(
          find.byKey(const ValueKey('notification-unread-dot')), findsNothing);
      expect(find.text('All caught up'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('notifications-mark-all')), findsNothing);
    });

    testWidgets('an empty feed says what will arrive there', (tester) async {
      _repo.items = [];
      await _pump(tester, '/notifications');

      expect(find.text('Nothing new'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('notifications-mark-all')), findsNothing);
    });

    testWidgets('scrolling to the end fetches the next page', (tester) async {
      _repo
        ..pageSize = 20
        ..items = [
          for (var i = 0; i < 25; i++)
            _n(200 + i, NotificationType.taskAssigned,
                _now.subtract(Duration(minutes: i)),
                params: {'actorName': 'Asel', 'taskTitle': 'Task $i'}),
        ];
      await _pump(tester, '/notifications');
      expect(find.byKey(const ValueKey('notification-224')), findsNothing);

      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('notification-224')), 400,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('notification-224')), findsOneWidget);
    });

    testWidgets('waits with a skeleton, never a spinner', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_routed('/notifications'));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
    });
  });
}
