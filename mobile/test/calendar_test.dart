import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/calendar/presentation/widgets/calendar_month_view.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Thursday 12 March 2026, mid-morning. March 2026 opens on a Sunday, so a
/// Monday-first page needs six rows and a Sunday-first one five.
final _now = DateTime(2026, 3, 12, 9, 0);

MeetingResponse _meeting(int id, DateTime at, String title,
        {int? propertyId, String? propertyTitle}) =>
    MeetingResponse(
      id: id,
      title: title,
      scheduledAt: at,
      agentId: 5,
      agentName: 'Maria Kim',
      clientId: 9,
      clientName: 'Irina Sokolova',
      propertyId: propertyId,
      propertyTitle: propertyTitle,
    );

TaskResponse _task(int id, DateTime due, String title, {bool done = false}) =>
    TaskResponse(
      id: id,
      title: title,
      dueAt: due,
      assigneeId: 5,
      completedAt: done ? due : null,
    );

List<MeetingResponse> _meetings() => [
      _meeting(1, DateTime(2026, 3, 12, 10), 'Price talk'),
      _meeting(2, DateTime(2026, 3, 12, 15), 'Viewing at Severny',
          propertyId: 7, propertyTitle: 'Severny Residence, apt 84'),
      _meeting(3, DateTime(2026, 3, 20, 11), 'Contract signing'),
      _meeting(4, DateTime(2026, 4, 8, 12), 'April handover'),
    ];

List<TaskResponse> _tasks() => [
      _task(1, DateTime(2026, 3, 12, 18), 'Send the contract'),
      _task(2, DateTime(2026, 3, 10, 12), 'Chase the bank'),
      _task(3, DateTime(2026, 3, 12, 8), 'Call the notary', done: true),
    ];

late FakeMeetingsRepository _meetingsRepo;
late FakeTasksRepository _tasksRepo;

void _install() {
  _meetingsRepo = FakeMeetingsRepository(_meetings());
  _tasksRepo = FakeTasksRepository(_tasks());
  Injector.meetingsRepository = _meetingsRepo;
  Injector.tasksRepository = _tasksRepo;
  Injector.clientsRepository = FakeClientsRepository(clients: const []);
  Injector.dealsRepository = FakeDealsRepository(const []);
}

Widget _providers(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => MeetingsBloc(FakeMeetingsRepository(_meetings()))),
      ],
      child: child,
    );

Future<void> _pumpCalendar(WidgetTester tester,
    {Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    double scale = 1.0,
    Brightness brightness = Brightness.light}) async {
  await expectNoOverflow(
    tester,
    _providers(const MeetingsScreen(initialMonth: true)),
    size: size,
    brightness: brightness,
    textScale: scale,
    locale: locale,
  );
  await tester.pumpAndSettle();
}

Finder _day(int month, int day) =>
    find.byKey(ValueKey('calendar-day-2026-$month-$day'));

List<String> _markersOn(WidgetTester tester, int month, int day) => tester
    .widgetList(find.descendant(
        of: _day(month, day),
        matching: find.byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('calendar-marker-'))))
    .map((w) =>
        (w.key! as ValueKey<String>).value.substring('calendar-marker-'.length))
    .toList();

void main() {
  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
    _install();
  });

  group('month grid', () {
    test('starts on the first weekday it is given', () {
      // 1 October 2026 is a Thursday.
      final monday = monthGridDays(DateTime(2026, 10), 1);
      expect(monday.first, DateTime(2026, 9, 28));
      expect(monday.first.weekday, DateTime.monday);
      final sunday = monthGridDays(DateTime(2026, 10), 0);
      expect(sunday.first, DateTime(2026, 9, 27));
      expect(sunday.first.weekday, DateTime.sunday);
    });

    test('carries a leap February to the 29th', () {
      final days = monthGridDays(DateTime(2028, 2), 1);
      expect(days.where((d) => d.month == 2).length, 29);
      expect(days, contains(DateTime(2028, 2, 29)));
      expect(days.length % 7, 0);
      expect(monthGridDays(DateTime(2026, 2), 1).where((d) => d.month == 2),
          hasLength(28));
    });

    test('grows to six rows when the month needs them, four when it fits', () {
      // August 2026 opens on a Saturday: 5 lead days + 31 = six weeks.
      expect(monthGridDays(DateTime(2026, 8), 1), hasLength(42));
      // February 2026 opens on a Sunday: exactly four Sunday-first weeks.
      expect(monthGridDays(DateTime(2026, 2), 0), hasLength(28));
      expect(monthGridDays(DateTime(2026, 3), 1), hasLength(42));
      expect(monthGridDays(DateTime(2026, 3), 0), hasLength(35));
    });

    test('asks for the whole visible grid, end exclusive', () {
      expect(monthGridRange(DateTime(2026, 3), 0),
          (DateTime(2026, 3, 1), DateTime(2026, 4, 5)));
      expect(monthGridRange(DateTime(2026, 3), 1),
          (DateTime(2026, 2, 23), DateTime(2026, 4, 6)));
    });
  });

  for (final (locale, weekday) in [
    (const Locale('en'), DateTime.sunday),
    (const Locale('ru'), DateTime.monday),
    (const Locale('kk'), DateTime.monday),
  ]) {
    testWidgets(
        'the week starts on ${weekday == 1 ? 'Monday' : 'Sunday'} '
        'in ${locale.languageCode}', (tester) async {
      await _pumpCalendar(tester, locale: locale);
      final headers = tester
          .widgetList<Text>(find.byKey(const ValueKey('calendar-weekday')))
          .map((t) => t.data)
          .toList();
      final names = DateFormat.E(locale.languageCode);
      // 8 March 2026 is a Sunday, 9 March a Monday.
      final first = weekday == DateTime.sunday
          ? DateTime(2026, 3, 8)
          : DateTime(2026, 3, 9);
      expect(headers, hasLength(7));
      expect(headers.first, names.format(first));
    });
  }

  testWidgets('the tab opens on the list and switches to the month',
      (tester) async {
    await expectNoOverflow(
      tester,
      _providers(const MeetingsScreen()),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(_day(3, 12), findsNothing);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(_day(3, 12), findsOneWidget);
    expect(find.text('March 2026'), findsOneWidget);

    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(_day(3, 12), findsNothing);
  });

  testWidgets('a day shows at most three markers, in the order of its day',
      (tester) async {
    await _pumpCalendar(tester);

    // Four things on the 12th: the done 08:00 task, the 10:00 meeting, the
    // 15:00 viewing and the 18:00 task. Only the first three fit.
    expect(_markersOn(tester, 3, 12), ['doneTask', 'meeting', 'viewing']);
    expect(_markersOn(tester, 3, 10), ['overdueTask']);
    expect(_markersOn(tester, 3, 20), ['meeting']);
    expect(_markersOn(tester, 3, 11), isEmpty);
    // The April days trailing the March page carry theirs too.
    expect(_day(4, 8), findsNothing);
  });

  testWidgets('today is selected first and its agenda runs in time order',
      (tester) async {
    await _pumpCalendar(tester);

    final order = [
      'Call the notary',
      'Price talk',
      'Viewing at Severny',
      'Send the contract',
    ].map((s) => tester.getTopLeft(find.text(s)).dy).toList();
    expect(order, orderedEquals([...order]..sort()));
    expect(find.text('Irina Sokolova · Severny Residence, apt 84'),
        findsOneWidget);
  });

  testWidgets('tapping a day shows that day instead', (tester) async {
    await _pumpCalendar(tester);

    await tester.tap(_day(3, 20));
    await tester.pumpAndSettle();

    expect(find.text('Contract signing'), findsOneWidget);
    expect(find.text('Price talk'), findsNothing);
    expect(find.text('Today'), findsOneWidget,
        reason: 'away from today, a way back appears');
  });

  testWidgets('a task is checked off from the agenda and stays, muted',
      (tester) async {
    await _pumpCalendar(tester);

    final check = find.descendant(
        of: find.byKey(const ValueKey('calendar-task-1')),
        matching: find.byType(IconButton));
    await tester.ensureVisible(check);
    await tester.pumpAndSettle();
    await tester.tap(check);
    await tester.pumpAndSettle();

    expect(_tasksRepo.tasks.firstWhere((t) => t.id == 1).isDone, isTrue);
    final title = tester.widget<Text>(find.text('Send the contract'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('Task done'), findsWidgets);
  });

  testWidgets('moving between months reads just the page on screen, once',
      (tester) async {
    await _pumpCalendar(tester);
    expect(
        _meetingsRepo.ranges, [(DateTime(2026, 3, 1), DateTime(2026, 4, 5))]);
    final q = _tasksRepo.queries.last;
    expect((q.from, q.to, q.includeDone),
        (DateTime(2026, 3, 1), DateTime(2026, 4, 5), true));

    await tester.tap(find.byKey(const ValueKey('calendar-next')));
    await tester.pumpAndSettle();
    // April 2026 opens on a Wednesday: the Sunday-first page runs 29 March
    // to 2 May.
    expect(_meetingsRepo.ranges.last,
        (DateTime(2026, 3, 29), DateTime(2026, 5, 3)));
    expect(_markersOn(tester, 4, 8), ['meeting']);

    await tester.tap(find.byKey(const ValueKey('calendar-previous')));
    await tester.pumpAndSettle();
    expect(_meetingsRepo.ranges, hasLength(2), reason: 'March is cached');

    await tester.fling(find.byKey(const ValueKey('calendar-day-2026-3-18')),
        const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);
  });

  testWidgets('a task written anywhere refreshes the page', (tester) async {
    await _pumpCalendar(tester);
    final before = _meetingsRepo.ranges.length;

    await _tasksRepo.createTask({
      'title': 'Book the photographer',
      'dueAt': DateTime(2026, 3, 11, 12).toIso8601String(),
    });
    await tester.pumpAndSettle();

    expect(_meetingsRepo.ranges.length, before + 1);
    expect(_markersOn(tester, 3, 11), ['overdueTask']);
  });

  testWidgets('collapsing leaves the week of the selected day', (tester) async {
    await _pumpCalendar(tester);
    expect(find.byKey(const ValueKey('calendar-day-2026-3-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-collapse')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('calendar-day-2026-3-1')), findsNothing);
    for (var d = 8; d <= 14; d++) {
      expect(_day(3, d), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('calendar-next')));
    await tester.pumpAndSettle();
    expect(_day(3, 19), findsOneWidget);
    expect(find.text('Contract signing'), findsNothing);
    expect(find.text('Nothing planned'), findsOneWidget,
        reason: 'the 19th is selected and is empty');
  });

  group('creating from a day', () {
    late Uri? opened;

    Future<void> pumpRouted(WidgetTester tester) async {
      opened = null;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/meetings',
        routes: [
          GoRoute(
            path: '/meetings',
            builder: (_, __) => const Scaffold(body: CalendarMonthView()),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, s) {
                  opened = s.uri;
                  return const Scaffold(body: Text('meeting form'));
                },
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(_providers(MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      )));
      await tester.pumpAndSettle();
    }

    testWidgets('press and hold, Meeting: the form opens on that date',
        (tester) async {
      await pumpRouted(tester);

      await tester.longPress(_day(3, 20));
      await tester.pumpAndSettle();
      expect(find.text('Add to Fri, Mar 20'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('calendar-create-meeting')));
      await tester.pumpAndSettle();

      expect(find.text('meeting form'), findsOneWidget);
      expect(opened?.path, '/meetings/new');
      expect(opened?.queryParameters, {'date': '2026-03-20'});
    });

    testWidgets('+ in the agenda, Task: the sheet opens due that day',
        (tester) async {
      await pumpRouted(tester);
      await tester.tap(_day(3, 20));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('calendar-add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('calendar-create-task')));
      await tester.pumpAndSettle();

      final due = DateTime(2026, 3, 20, 10);
      expect(find.text(formatDayMonth(due, 'en')), findsWidgets);
      expect(find.text('10:00'), findsWidgets);
    });

    testWidgets('a day already gone offers nothing to add', (tester) async {
      await pumpRouted(tester);
      await tester.tap(_day(3, 10));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('calendar-add')), findsNothing);

      await tester.longPress(_day(3, 10));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('calendar-create-meeting')), findsNothing);
    });

    testWidgets('the meeting form reads the date it was opened with',
        (tester) async {
      await expectNoOverflow(
        tester,
        _providers(MeetingFormScreen(initialDate: DateTime(2026, 3, 20))),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
      expect(find.text(formatDayMonth(DateTime(2026, 3, 20), 'en')),
          findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });
  });

  forEachAcceptanceCase('calendar month',
      (tester, size, brightness, scale) async {
    await _pumpCalendar(tester,
        size: size, brightness: brightness, scale: scale);
    expect(tester.takeException(), isNull);

    // The agenda sits below the grid; bring it on screen so it is laid out.
    await tester.scrollUntilVisible(find.text('Send the contract'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the day agenda');

    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('calendar-collapse')), -200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-collapse')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'collapsed to a week');
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the calendar fits 320 at 1.5x in ${locale.languageCode}',
        (tester) async {
      for (final brightness in Brightness.values) {
        await _pumpCalendar(tester,
            locale: locale,
            size: const Size(320, 568),
            scale: 1.5,
            brightness: brightness);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(_day(3, 20));
        await tester.pumpAndSettle();
        await tester.longPress(_day(3, 20));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'the add sheet');
        expect(
            find.byKey(const ValueKey('calendar-create-task')), findsOneWidget);
        await tester.tapAt(const Offset(160, 20));
        await tester.pumpAndSettle();
      }
    });
  }
}
