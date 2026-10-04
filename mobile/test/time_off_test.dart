import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/out_today_card.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';
import 'package:real_estate_crm/features/time_off/presentation/bloc/time_off_list_bloc.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/my_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/team_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/time_off_form_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'time_off_fakes.dart';
import 'time_off_fixtures.dart';

/// Time off with a cover: an agent's own list, the team's "who's out", the
/// form that writes one down, changes or cancels it and warns about the
/// meetings on those days, the away badge in the agent pickers, the dashboard
/// chip, and a cover's notifications reading as covering for somebody.

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

/// Taps a date field and accepts the day the picker opens on.
Future<void> _acceptDate(WidgetTester tester, Key field) async {
  await _tap(tester, find.byKey(field));
  await _tap(tester, find.text('OK'));
}

void main() {
  late FakeTimeOffRepository repo;

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(timeOffNow);
    repo = FakeTimeOffRepository(items: timeOffItems);
    Injector.timeOffRepository = repo;
    Injector.agentsRepository = FakeAgentsRepository(timeOffAgents);
  });
  tearDown(() {
    AppClock.reset();
    Injector.timeOffRepository = FakeTimeOffRepository();
    Injector.agentsRepository = const FakeAgentsRepository([]);
  });

  group('where an absence stands', () {
    test('out today, starting this week, later, or over', () {
      expect(timeOffWhen(aigulHoliday, timeOffNow), TimeOffWhen.today);
      expect(timeOffWhen(timurDayOff, timeOffNow), TimeOffWhen.thisWeek);
      expect(timeOffWhen(longSickLeave, timeOffNow), TimeOffWhen.later);
      expect(timeOffWhen(aigulPast, timeOffNow), TimeOffWhen.past);
      expect(timeOffLength(offDay(0), offDay(6)), 7);
    });

    test('an agent is away on a day their time off takes in', () {
      final timur = timeOffAgents[2];
      expect(agentAwayOn(timur, offDay(9).add(const Duration(hours: 18))),
          isNotNull);
      expect(agentAwayOn(timur, offDay(8)), isNull);
      expect(agentAwayOn(timur, offDay(10)), isNull);
    });

    test('a draft is sent in the server\'s words', () {
      final json = TimeOffDraft(
        userId: 3,
        kind: TimeOffKind.sickLeave,
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 16),
        coverId: 4,
        note: '  ',
      ).toJson();
      expect(json, {
        'userId': 3,
        'kind': 'SICK_LEAVE',
        'startDate': '2026-10-12',
        'endDate': '2026-10-16',
        'coverId': 4,
      });
    });
  });

  group('my time off', () {
    testWidgets('what is on and coming up, then what is over; each opens',
        (tester) async {
      await _pump(
          tester, timeOffApp(const MyTimeOffScreen(), user: timeOffAgent));

      final (from, to, userId) = repo.asked.single;
      expect(userId, 2);
      expect(from, offDay(-kTimeOffPastDays));
      expect(to, offDay(kTimeOffAheadDays));
      expect(find.byType(TimeOffRow), findsNWidgets(2));
      expect(find.text('Now and coming up'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Away now'), findsOneWidget);
      expect(find.text('Covered by Timur Aliev'), findsOneWidget);
      expect(find.text('2 meetings on these days'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('time-off-row-11')));
      expect(find.text('time off 11'), findsOneWidget);
    });

    testWidgets('nothing yet says so, and offers to add one', (tester) async {
      repo.items = const [];
      await _pump(
          tester, timeOffApp(const MyTimeOffScreen(), user: timeOffAgent));
      expect(find.text('No time off yet'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('time-off-empty-add')));
      expect(find.text('new time off'), findsOneWidget);
    });

    testWidgets('the way to who is out', (tester) async {
      await _pump(
          tester, timeOffApp(const MyTimeOffScreen(), user: timeOffAgent));
      await _tap(tester, find.byKey(const ValueKey('time-off-whos-out')));
      expect(find.text('team list'), findsOneWidget);
    });
  });

  group("who's out", () {
    testWidgets('out today, this week and later, with who covers',
        (tester) async {
      await _pump(tester, timeOffApp(const TeamTimeOffScreen()));

      expect(repo.asked.single.$3, isNull);
      expect(
          find.byKey(const ValueKey('time-off-section-today')), findsOneWidget);
      expect(find.byKey(const ValueKey('time-off-section-thisWeek')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('time-off-section-later')), findsOneWidget);
      expect(find.text('Aigul Bekova'), findsOneWidget);
      expect(find.text('Timur Aliev'), findsOneWidget);
      expect(find.text('Nobody covers'), findsOneWidget);
      expect(find.byKey(const ValueKey('time-off-row-14')), findsNothing,
          reason: 'what is over is not on the list');
      expect(find.byKey(const ValueKey('time-off-team-add')), findsOneWidget);
    });

    testWidgets('an agent sees it too, but writes down only their own',
        (tester) async {
      await _pump(
          tester, timeOffApp(const TeamTimeOffScreen(), user: timeOffAgent));
      expect(find.byType(TimeOffRow), findsNWidgets(3));
      expect(find.byKey(const ValueKey('time-off-team-add')), findsNothing);
    });

    testWidgets('everybody in reads as such; a failure offers a retry',
        (tester) async {
      repo.items = const [];
      await _pump(tester, timeOffApp(const TeamTimeOffScreen()));
      expect(find.text('Everyone is in'), findsOneWidget);

      repo.failReads = true;
      await _pump(tester, timeOffApp(const TeamTimeOffScreen()));
      expect(find.text('Could not load time off'), findsOneWidget);
    });
  });

  group('writing it down', () {
    testWidgets(
        "a manager writes down a colleague's sick leave; the picker says who is away",
        (tester) async {
      await _pump(tester, timeOffApp(null, form: const TimeOffFormScreen()));

      await _tap(tester, find.byKey(const ValueKey('time-off-person')));
      await _tap(tester, find.text('Timur Aliev'));
      await _tap(tester, find.byKey(const ValueKey('time-off-kind-sickLeave')));
      await _acceptDate(tester, const ValueKey('time-off-start'));
      expect(find.text('1 day'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('time-off-cover')));
      expect(find.byKey(const ValueKey('picker-badge-2')), findsOneWidget,
          reason: 'Aigul is away today');
      expect(find.byKey(const ValueKey('picker-badge-3')), findsNothing,
          reason: 'the person away cannot cover themselves');
      await _tap(tester, find.text('Aigerim Serikbaykyzy-Nurmukhambetova'));
      await tester.enterText(
          find.byKey(const ValueKey('time-off-note')), 'Flu');
      await _tap(tester, find.byKey(const ValueKey('time-off-save')));

      final draft = repo.created.single;
      expect(draft.userId, 3);
      expect(draft.kind, TimeOffKind.sickLeave);
      expect(draft.startDate, offDay(0));
      expect(draft.endDate, offDay(0));
      expect(draft.coverId, 4);
      expect(draft.note, 'Flu');
      expect(find.text('home'), findsOneWidget,
          reason: 'with nothing on those days the form closes');
    });

    testWidgets('the days and, for a manager, the person are asked for',
        (tester) async {
      await _pump(tester, timeOffApp(null, form: const TimeOffFormScreen()));
      await _tap(tester, find.byKey(const ValueKey('time-off-save')));
      expect(find.text('Choose the first and the last day'), findsOneWidget);
      expect(find.text('Choose who is away'), findsWidgets);
      expect(repo.created, isEmpty);
    });

    testWidgets('an agent writes down their own; an overlap is said in words',
        (tester) async {
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(), user: timeOffAgent));
      expect(find.byKey(const ValueKey('time-off-person')), findsNothing);
      await _acceptDate(tester, const ValueKey('time-off-start'));

      repo.failWith = 'TIME_OFF_OVERLAPS';
      await _tap(tester, find.byKey(const ValueKey('time-off-save')));
      expect(find.text('There is already time off on some of these days'),
          findsOneWidget);
      expect(find.byType(TimeOffFormScreen), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('time-off-save')));
      expect(repo.created.single.userId, isNull,
          reason: "the server takes it as the caller's own");
    });

    testWidgets(
        'the answer carrying meetings on those days keeps the form open',
        (tester) async {
      repo.answer = aigulHoliday;
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(), user: timeOffAgent));
      await _acceptDate(tester, const ValueKey('time-off-start'));
      await _tap(tester, find.byKey(const ValueKey('time-off-save')));
      expect(find.byKey(const ValueKey('time-off-conflicts')), findsOneWidget);
      expect(find.text('Time off saved'), findsOneWidget);
    });
  });

  group('changing it', () {
    testWidgets(
        'the meetings on those days are a warning and open; saving changes it',
        (tester) async {
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(id: 11), user: timeOffAgent));

      expect(find.text('Phone off, Timur has the keys to Dostyk 5'),
          findsOneWidget);
      expect(find.text('Timur Aliev'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('time-off-conflict-41')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('time-off-conflict-42')), findsOneWidget);
      expect(find.byKey(const ValueKey('time-off-hand-over')), findsNothing,
          reason: 'handing work over is the manager\'s');

      await _tap(tester, find.byKey(const ValueKey('time-off-kind-dayOff')));
      await _tap(tester, find.byKey(const ValueKey('time-off-save')));
      final (id, draft) = repo.updated.single;
      expect(id, 11);
      expect(draft.userId, isNull);
      expect(draft.kind, TimeOffKind.dayOff);
      expect(draft.coverId, 3);
      expect(draft.startDate, offDay(-2));
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a meeting on those days opens', (tester) async {
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(id: 11), user: timeOffAgent));
      await _tap(tester, find.byKey(const ValueKey('time-off-conflict-41')));
      expect(find.text('meeting 41'), findsOneWidget);
    });

    testWidgets("a manager can hand the absent person's work over",
        (tester) async {
      await _pump(
          tester, timeOffApp(null, form: const TimeOffFormScreen(id: 11)));
      await _tap(tester, find.byKey(const ValueKey('time-off-hand-over')));
      expect(find.text('handover 2'), findsOneWidget);
    });

    testWidgets('cancelling asks first', (tester) async {
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(id: 11), user: timeOffAgent));
      await _tap(tester, find.byKey(const ValueKey('time-off-cancel')));
      expect(find.text('Cancel this time off?'), findsOneWidget);
      await _tap(tester, find.text('Keep it'));
      expect(repo.cancelled, isEmpty);

      await _tap(tester, find.byKey(const ValueKey('time-off-cancel')));
      await _tap(
          tester,
          find.descendant(
              of: find.byType(Dialog), matching: find.byType(AppFilledButton)));
      expect(repo.cancelled, [11]);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets("somebody else's reads as a summary", (tester) async {
      await _pump(
          tester,
          timeOffApp(null,
              form: const TimeOffFormScreen(id: 12), user: timeOffAgent));
      expect(find.byKey(const ValueKey('time-off-summary')), findsOneWidget);
      expect(find.byKey(const ValueKey('time-off-save')), findsNothing);
      expect(find.byKey(const ValueKey('time-off-cancel')), findsNothing);
    });
  });

  group('away in the pickers', () {
    testWidgets(
        'an agent away today carries a badge; a meeting on their day '
        'off is a warning', (tester) async {
      late BuildContext ctx;
      await _pump(tester, timeOffApp(Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      })));
      expect(agentPickerItem(ctx, timeOffAgents[1]).badge, contains('Away'));
      expect(agentPickerItem(ctx, timeOffAgents[2]).badge, isNull);

      final warning = agentAwayWarning(ctx, timeOffAgents[2], offDay(9));
      expect(warning, contains('Timur Aliev'));
      expect(warning, contains('Day off'));
      expect(agentAwayWarning(ctx, timeOffAgents[2], offDay(10)), isNull);
      expect(agentAwayWarning(ctx, null, offDay(9)), isNull);
    });
  });

  group('the meeting form', () {
    testWidgets('warns, without refusing, when the agent is away that day',
        (tester) async {
      final meetings = FakeMeetingsRepository(const []);
      await _pump(
          tester,
          timeOffApp(BlocProvider(
            create: (_) => MeetingsBloc(meetings),
            child: MeetingFormScreen(initialDate: offDay(9)),
          )));
      expect(find.byKey(const ValueKey('meeting-agent-away')), findsNothing);

      await _tap(tester, find.text('Not selected').at(1));
      expect(find.byKey(const ValueKey('picker-badge-2')), findsOneWidget,
          reason: 'Aigul is away today');
      expect(find.byKey(const ValueKey('picker-badge-3')), findsNothing,
          reason: 'Timur is in today; only the day of the meeting clashes');
      await _tap(tester, find.text('Timur Aliev'));

      expect(find.byKey(const ValueKey('meeting-agent-away')), findsOneWidget);
      expect(
          find.textContaining('Timur Aliev is away that day'), findsOneWidget);
    });
  });

  group('the dashboard chip', () {
    testWidgets('says who is out today and opens the list', (tester) async {
      repo.items = [aigulHoliday];
      final bloc = TimeOffListBloc.today(repo)..add(TimeOffListLoadEvent());
      addTearDown(bloc.close);
      await _pump(
          tester,
          timeOffApp(Builder(
            builder: (context) => Scaffold(
              body: BlocProvider.value(
                value: bloc,
                child:
                    OutTodayCard(onTap: () => context.push('/time-off/team')),
              ),
            ),
          )));
      expect(find.text('Out today: 1'), findsOneWidget);
      expect(find.text('Aigul Bekova'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('out-today')));
      expect(find.text('team list'), findsOneWidget);
    });

    testWidgets('is not there when everybody is in', (tester) async {
      repo.items = const [];
      final bloc = TimeOffListBloc.today(repo)..add(TimeOffListLoadEvent());
      addTearDown(bloc.close);
      await _pump(
          tester,
          timeOffApp(Scaffold(
            body: BlocProvider.value(
                value: bloc, child: OutTodayCard(onTap: () {})),
          )));
      expect(find.byKey(const ValueKey('out-today')), findsNothing);
      expect(repo.asked.single.$1, offDay(0));
      expect(repo.asked.single.$2, offDay(0));
    });
  });

  group('a cover\'s notifications', () {
    test('say whom they are covering for, and a request opens the absence',
        () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final copy = notificationCopy(
          en,
          AppNotification(
            id: 1,
            type: NotificationType.clientBirthday,
            targetId: 5,
            params: const {
              'clientName': 'Irina',
              'years': 36,
              'coveringForName': 'Aigul Bekova',
            },
            createdAt: timeOffNow,
          ));
      expect(copy.detail, startsWith('Covering for Aigul Bekova · '));

      final asked = AppNotification(
        id: 2,
        type: NotificationType.timeOffCover,
        targetId: 11,
        params: const {
          'absentName': 'Aigul Bekova',
          'kind': 'VACATION',
          'startDate': '2026-10-12',
          'endDate': '2026-10-16',
        },
        createdAt: timeOffNow,
      );
      expect(notificationCopy(en, asked).title,
          'You are covering for Aigul Bekova');
      expect(notificationCopy(en, asked).detail, startsWith('Vacation · '));
      expect(notificationTarget(asked)?.location, '/time-off/11');
    });
  });
}
