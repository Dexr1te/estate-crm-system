import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/goal_ring_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/my_goal_card.dart';
import 'package:real_estate_crm/features/goals/domain/goal_pace.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_bloc.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_event.dart';
import 'package:real_estate_crm/features/goals/presentation/screens/team_goals_screen.dart';
import 'package:real_estate_crm/features/goals/presentation/widgets/goal_target_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

import 'goals_fakes.dart';
import 'responsive_harness.dart';

/// Monthly targets: the dashboard card counts the month against the target
/// that wins (the manager's over the agent's own) and says what each day
/// left has to bring; the agent sets their own only while the manager has
/// not; the manager sets everybody's and the agency's, a month at a time,
/// and brings last month's forward.

final _now = DateTime(2026, 3, 12, 9);
final _l10n = AppLocalizationsEn();

const _managerSet = GoalProgress(
  month: '2026-03',
  currency: 'USD',
  agentId: 7,
  agentName: 'Aigul Bekova',
  source: 'MANAGER',
  commissionTarget: 4000000,
  dealsTarget: 4,
  commissionAchieved: 1000000,
  dealsWon: 2,
  commissionPercent: 25,
  dealsPercent: 50,
  daysLeft: 20,
  commissionPerDay: 150000,
  dealsPerDay: 0.1,
);

const _team = TeamGoals(
  month: '2026-03',
  currency: 'USD',
  daysLeft: 20,
  agency: GoalProgress(
    month: '2026-03',
    commissionTarget: 9000000,
    commissionAchieved: 1400000,
    commissionPercent: 15,
    dealsWon: 3,
    daysLeft: 20,
    source: 'MANAGER',
    commissionPerDay: 380000,
  ),
  agents: [
    _managerSet,
    GoalProgress(
      month: '2026-03',
      agentId: 8,
      agentName: 'Timur Aliev',
      source: 'PERSONAL',
      dealsTarget: 5,
      dealsWon: 1,
      dealsPercent: 20,
      commissionAchieved: 400000,
      daysLeft: 20,
    ),
    GoalProgress(
      month: '2026-03',
      agentId: 9,
      agentName: 'Dana Seitova',
      daysLeft: 20,
    ),
  ],
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _card(GoalProgress goal, {VoidCallback? onTap}) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GoalRingCard(goal: goal, onTap: onTap),
      ),
    );

void main() {
  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  group('pace', () {
    test('says what each remaining day has to bring', () {
      expect(goalPace(_l10n, _managerSet),
          '20 days left · ${formatPrice(150000)} a day · a deal every 10 days');
    });

    test('counts deals per day once there are more of them than days', () {
      const goal = GoalProgress(dealsTarget: 9, dealsWon: 1, daysLeft: 3);
      expect(goalPace(_l10n, goal), '3 days left · 3 deals a day');
    });

    test('a month gone has no pace, only that it is over', () {
      const goal = GoalProgress(dealsTarget: 9, dealsWon: 1);
      expect(goalPace(_l10n, goal), 'The month is over');
    });

    test('reached once every target set is met', () {
      expect(goalReached(_managerSet), isFalse);
      expect(
          goalReached(
              _managerSet.copyWith(commissionAchieved: 4000000, dealsWon: 4)),
          isTrue);
      expect(
          goalReached(const GoalProgress(dealsTarget: 2, dealsWon: 2)), isTrue);
      expect(goalReached(const GoalProgress()), isFalse);
    });

    test('the ring follows the commission, or the deals without one', () {
      expect(goalPercent(_managerSet), 25);
      expect(goalFraction(_managerSet), 0.25);
      expect(goalPercent(_team.agents[1]), 20);
      expect(
          goalFraction(const GoalProgress(dealsTarget: 1, dealsPercent: 300)),
          1.0);
    });
  });

  group('amounts typed in', () {
    test('read the way people write them', () {
      expect(parseGoalAmount('1500000'), 1500000);
      expect(parseGoalAmount('1 500 000'), 1500000);
      expect(parseGoalAmount('1,500,000'), 1500000);
      expect(parseGoalAmount('1500000,50'), 1500000.5);
      expect(parseGoalAmount('2500.75'), 2500.75);
      expect(parseGoalAmount('12abc'), isNull);
      expect(parseGoalAmount('1.234'), isNull);
      expect(parseGoalAmount(''), isNull);
    });
  });

  group('dashboard card', () {
    testWidgets('shows the month against the manager\'s target',
        (tester) async {
      await expectNoOverflow(tester, _card(_managerSet),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.text('25'), findsOneWidget);
      expect(find.text(formatPrice(1000000)), findsOneWidget);
      expect(find.text('/ ${formatPrice(4000000)}'), findsOneWidget);
      expect(find.text('2 of 4 deals won'), findsOneWidget);
      expect(find.textContaining('20 days left'), findsOneWidget);
      expect(find.text('Set by your manager'), findsOneWidget);
    });

    testWidgets('without a target, says how to set one', (tester) async {
      await expectNoOverflow(tester, _card(kEmptyGoal, onTap: () {}),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(find.text('No deals won yet'), findsOneWidget);
      expect(find.textContaining('Tap to set your own'), findsOneWidget);
    });

    testWidgets('a target met says so', (tester) async {
      await expectNoOverflow(
          tester,
          _card(_managerSet.copyWith(
              commissionAchieved: 5000000,
              commissionPercent: 125,
              dealsWon: 4,
              dealsPercent: 100)),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.text('125'), findsOneWidget);
      expect(find.textContaining('Target reached'), findsOneWidget);
    });

    forEachAcceptanceCase('goal card with a target',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
        tester,
        _card(_managerSet.copyWith(
            commissionAchieved: 1234567890, commissionTarget: 2000000000)),
        size: size,
        brightness: brightness,
        textScale: scale,
      );
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('goal card in ${locale.languageCode}', (tester) async {
        await expectNoOverflow(tester, _card(_managerSet),
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
      });
    }
  });

  group('the agent\'s own target', () {
    late FakeGoalsRepository repo;

    Future<void> pump(WidgetTester tester) async {
      await expectNoOverflow(
        tester,
        Scaffold(
          body: BlocProvider(
            create: (_) => MyGoalBloc(repo)..add(MyGoalLoadEvent()),
            child:
                const Padding(padding: EdgeInsets.all(16), child: MyGoalCard()),
          ),
        ),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('is set from the card and counted at once', (tester) async {
      repo = FakeGoalsRepository(
          mine: kEmptyGoal.copyWith(commissionAchieved: 500000, dealsWon: 1));
      await pump(tester);

      await _tap(tester, find.byKey(const ValueKey('goal-card')));
      expect(find.text('Monthly target'), findsOneWidget);
      expect(find.byKey(const Key('goal-remove')), findsNothing);

      await _tap(tester, find.byKey(const Key('goal-save')));
      expect(find.byKey(const Key('goal-error')), findsOneWidget,
          reason: 'a target needs a figure');
      expect(repo.lastWritten, isNull);

      await tester.enterText(find.byKey(const Key('goal-commission')), '0');
      await _tap(tester, find.byKey(const Key('goal-save')));
      expect(find.text('Enter an amount above zero'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('goal-commission')), '2 000 000');
      await tester.enterText(find.byKey(const Key('goal-deals')), '4');
      await _tap(tester, find.byKey(const Key('goal-save')));

      expect(repo.calls, contains('setMyGoal null'));
      expect(repo.lastWritten, (commission: 2000000.0, deals: 4));
      expect(find.text('Target saved'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Your own target'), findsOneWidget);
    });

    testWidgets('is taken off from the same sheet', (tester) async {
      repo = FakeGoalsRepository(
          mine: kEmptyGoal.copyWith(source: 'PERSONAL', dealsTarget: 3));
      await pump(tester);

      await _tap(tester, find.byKey(const ValueKey('goal-card')));
      expect(
          tester
              .widget<EditableText>(find.descendant(
                  of: find.byKey(const Key('goal-deals')),
                  matching: find.byType(EditableText)))
              .controller
              .text,
          '3');
      await _tap(tester, find.byKey(const Key('goal-remove')));

      expect(repo.calls, contains('clearMyGoal null'));
      expect(find.text('Target removed'), findsOneWidget);
      expect(find.textContaining('Tap to set your own'), findsOneWidget);
    });

    testWidgets('cannot be set while the manager\'s counts', (tester) async {
      repo = FakeGoalsRepository(mine: _managerSet);
      await pump(tester);

      await tester.tap(find.byKey(const ValueKey('goal-card')));
      await tester.pumpAndSettle();
      expect(find.text('Monthly target'), findsNothing);
      expect(repo.calls, ['getMyGoal null']);
    });

    testWidgets('a failure to load stays inside the card', (tester) async {
      repo = FakeGoalsRepository()..readError = Exception('offline');
      await pump(tester);
      expect(find.text('Could not load the targets'), findsOneWidget);

      repo.readError = null;
      await _tap(tester, find.text('Retry'));
      expect(find.byKey(const ValueKey('goal-card')), findsOneWidget);
    });
  });

  group('the manager\'s month', () {
    late FakeGoalsRepository repo;

    setUp(() {
      repo = FakeGoalsRepository(team: _team, copyCount: 2);
      Injector.goalsRepository = repo;
      addTearDown(() => Injector.goalsRepository = FakeGoalsRepository());
    });

    Future<void> pump(WidgetTester tester,
        {Size size = const Size(390, 1400),
        Brightness brightness = Brightness.light,
        double scale = 1.0,
        Locale locale = const Locale('en')}) async {
      await expectNoOverflow(tester, const TeamGoalsScreen(),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      await tester.pumpAndSettle();
    }

    testWidgets('lists the agency and every member with their progress',
        (tester) async {
      await pump(tester);
      expect(repo.calls.first, 'getTeamGoals 2026-03');
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('Whole agency'), findsOneWidget);
      expect(find.text('Aigul Bekova'), findsOneWidget);
      expect(find.text('Timur Aliev'), findsOneWidget);
      expect(find.text('Dana Seitova'), findsOneWidget);
      expect(find.text("Agent's own target"), findsOneWidget);
      expect(find.text('No target'), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('goal-commission-7')))
              .data,
          '${formatPrice(1000000)} of ${formatPrice(4000000)}');
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('goal-deals-8'))).data,
          '1 / 5');
    });

    testWidgets('sets a member\'s target, which replaces their own',
        (tester) async {
      await pump(tester);
      await _tap(tester, find.byKey(const ValueKey('goal-agent-8')));
      expect(find.text('Target for Timur Aliev'), findsOneWidget);
      expect(find.byKey(const Key('goal-remove')), findsNothing,
          reason: 'the manager has not set one to take off');

      await tester.enterText(find.byKey(const Key('goal-deals')), '6');
      await _tap(tester, find.byKey(const Key('goal-save')));

      expect(repo.calls, contains('setMemberGoal 8 2026-03'));
      expect(repo.lastWritten, (commission: null, deals: 6));
      expect(find.text('Target saved'), findsOneWidget);
      expect(find.text("Agent's own target"), findsNothing);
    });

    testWidgets('takes the manager\'s target off a member', (tester) async {
      await pump(tester);
      await _tap(tester, find.byKey(const ValueKey('goal-agent-7')));
      await _tap(tester, find.byKey(const Key('goal-remove')));
      expect(repo.calls, contains('clearMemberGoal 7 2026-03'));
      expect(find.text('Target removed'), findsOneWidget);
    });

    testWidgets('sets the agency-wide target', (tester) async {
      await pump(tester);
      await _tap(tester, find.byKey(const ValueKey('goal-agency')));
      await tester.enterText(
          find.byKey(const Key('goal-commission')), '12000000');
      await _tap(tester, find.byKey(const Key('goal-save')));
      expect(repo.calls, contains('setAgencyGoal 2026-03'));
      expect(repo.lastWritten, (commission: 12000000.0, deals: null));
    });

    testWidgets('copies last month\'s targets forward', (tester) async {
      await pump(tester);
      await _tap(tester, find.byKey(const Key('goals-copy')));
      expect(repo.calls, contains('copyPreviousMonth 2026-03'));
      expect(find.text('2 targets copied'), findsOneWidget);
    });

    testWidgets('a month gone is read-only; next month can be planned',
        (tester) async {
      await pump(tester);
      await _tap(tester, find.byKey(const Key('goals-month-previous')));
      expect(repo.calls.last, 'getTeamGoals 2026-02');
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.byKey(const Key('goals-month-over')), findsOneWidget);
      expect(find.byKey(const Key('goals-copy')), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('goal-agent-8')));
      expect(find.byKey(const Key('goal-save')), findsNothing);

      await _tap(tester, find.byKey(const Key('goals-month-next')));
      await _tap(tester, find.byKey(const Key('goals-month-next')));
      expect(repo.calls.last, 'getTeamGoals 2026-04');
      expect(find.text('April 2026'), findsOneWidget);
      expect(find.byKey(const Key('goals-month-next')), findsNothing,
          reason: 'no further than next month');
      expect(find.byKey(const Key('goals-copy')), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (tester) async {
      repo.readError = Exception('offline');
      await pump(tester);
      expect(find.text('Could not load the targets'), findsOneWidget);
      repo.readError = null;
      await _tap(tester, find.text('Retry'));
      expect(find.text('Whole agency'), findsOneWidget);
    });

    forEachAcceptanceCase('team goals',
        (tester, size, brightness, scale) async {
      await pump(tester, size: size, brightness: brightness, scale: scale);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('team goals in ${locale.languageCode}', (tester) async {
        await pump(tester,
            size: const Size(320, 568),
            brightness: Brightness.dark,
            scale: 1.5,
            locale: locale);
      });
    }
  });

  test('only a manager reaches the goals editor', () {
    String? redirect(Role role) => resolveRedirect(
          location: '/team-goals',
          sessionResolved: true,
          authenticated: true,
          role: role,
          hasTeam: true,
        );
    expect(redirect(Role.MANAGER), isNull);
    expect(redirect(Role.AGENT), '/dashboard');
    expect(redirect(Role.ADMIN), '/dashboard');
  });
}
