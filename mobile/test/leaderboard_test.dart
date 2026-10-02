import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/widgets/leaderboard_settings_row.dart';

import 'responsive_harness.dart';

/// The leaderboard with figures known in advance: who is ranked where and by
/// what, the money in the agency's own currency, the period it asks for, a
/// column sort, an agent's own figures, the deactivated kept apart, and that it
/// fits every acceptance size in every language.

final _now = DateTime(2026, 9, 25, 15, 30);

const _timur = LeaderboardRow(
    rank: 1,
    agentId: 11,
    fullName: 'Timur Aliev',
    role: 'AGENT',
    dealsWon: 2,
    wonValue: 45000000,
    commission: 1200000,
    viewingsHeld: 1,
    newClients: 0,
    winRate: 1);
const _aigul = LeaderboardRow(
    rank: 2,
    agentId: 12,
    fullName: 'Aigul Bekova',
    role: 'AGENT',
    dealsWon: 2,
    dealsLost: 1,
    wonValue: 30000000,
    commission: 800000,
    viewingsHeld: 4,
    newClients: 2,
    winRate: 2 / 3);
const _dana = LeaderboardRow(
    rank: 3, agentId: 13, fullName: 'Dana Seitova', role: 'AGENT');
const _bolat = LeaderboardRow(
    rank: 1,
    agentId: 14,
    fullName: 'Bolat Omarov',
    role: 'AGENT',
    dealsWon: 1,
    wonValue: 10000000,
    commission: 100000,
    winRate: 1);

const _board = AgentLeaderboard(
  currency: 'KZT',
  agents: [_timur, _aigul, _dana],
  inactive: [_bolat],
  totals: LeaderboardRow(
      dealsWon: 5,
      dealsLost: 1,
      commission: 2100000,
      wonValue: 85000000,
      viewingsHeld: 5,
      newClients: 2,
      winRate: 5 / 6),
);

class _FakeLeaderboard implements LeaderboardRepository {
  AgentLeaderboard board;
  Object? error;
  final requests = <({DateTime from, DateTime to})>[];
  _FakeLeaderboard(this.board);

  @override
  Future<AgentLeaderboard> getLeaderboard(
      {required DateTime from, required DateTime to}) async {
    requests.add((from: from, to: to));
    if (error != null) throw error!;
    return board;
  }
}

class _Gated implements LeaderboardRepository {
  final Future<AgentLeaderboard> gate;
  _Gated(this.gate);

  @override
  Future<AgentLeaderboard> getLeaderboard(
          {required DateTime from, required DateTime to}) =>
      gate;
}

late _FakeLeaderboard _repo;

Future<void> _show(WidgetTester tester,
    {Size size = const Size(390, 1100),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(
    tester,
    LeaderboardScreen(key: ValueKey('$locale$size$brightness$scale')),
    size: size,
    brightness: brightness,
    textScale: scale,
    locale: locale,
  );
  await tester.pump(const Duration(milliseconds: 50));
}

List<String> _names(WidgetTester tester) {
  final cards = tester.widgetList<Text>(find.descendant(
      of: find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('leaderboard-row-')),
      matching: find.byType(Text)));
  return [
    for (final t in cards)
      if (['Timur Aliev', 'Aigul Bekova', 'Dana Seitova', 'Bolat Omarov']
          .contains(t.data))
        t.data!,
  ];
}

Future<void> _sortBy(WidgetTester tester, String sort) async {
  final pill = find.byKey(ValueKey('leaderboard-sort-$sort'));
  await tester.ensureVisible(pill);
  await tester.pumpAndSettle();
  await tester.tap(pill);
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = _FakeLeaderboard(_board);
    Injector.leaderboardRepository = _repo;
  });
  tearDown(AppClock.reset);

  testWidgets('ranks by commission, in the agency currency', (tester) async {
    await _show(tester);

    expect(_names(tester),
        ['Timur Aliev', 'Aigul Bekova', 'Dana Seitova', 'Bolat Omarov']);
    expect(find.text('1.2M ₸'), findsOneWidget);
    expect(find.text('800,000 ₸'), findsOneWidget);
    expect(find.text('2.1M ₸'), findsOneWidget);
    expect(find.text('Agency commission'), findsOneWidget);
    expect(find.text('83%'), findsOneWidget);
    expect(find.text('Won 2 · Viewings 4 · Clients 2'), findsOneWidget);
    expect(find.text('Sep 1, 2026 – Sep 30, 2026'), findsOneWidget);
  });

  testWidgets('the deactivated are listed apart, without a place',
      (tester) async {
    await _show(tester);
    expect(find.text('Deactivated'), findsOneWidget);
    final bolat = find.byKey(const ValueKey('leaderboard-row-14'));
    expect(
        find.descendant(of: bolat, matching: find.text('—')), findsOneWidget);
    expect(find.descendant(of: bolat, matching: find.text('1')), findsNothing);
  });

  testWidgets('the period tabs ask for this month, last month and the quarter',
      (tester) async {
    await _show(tester);
    expect(
        _repo.requests.last, (from: DateTime(2026, 9), to: DateTime(2026, 10)));

    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    expect(
        _repo.requests.last, (from: DateTime(2026, 8), to: DateTime(2026, 9)));
    expect(find.text('Aug 1, 2026 – Aug 31, 2026'), findsOneWidget);

    await tester.tap(find.text('Quarter'));
    await tester.pumpAndSettle();
    expect(
        _repo.requests.last, (from: DateTime(2026, 7), to: DateTime(2026, 10)));
  });

  testWidgets('a column sorts the board and re-ranks it; again flips it',
      (tester) async {
    await _show(tester);

    await _sortBy(tester, 'viewings');
    await tester.pumpAndSettle();
    expect(_names(tester).take(3),
        ['Aigul Bekova', 'Timur Aliev', 'Dana Seitova']);
    expect(find.text('Viewings ↓'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('leaderboard-row-12')),
            matching: find.text('1')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('leaderboard-value-12')), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('leaderboard-value-12')))
            .data,
        '4');

    await _sortBy(tester, 'viewings');
    await tester.pumpAndSettle();
    expect(_names(tester).take(3),
        ['Dana Seitova', 'Timur Aliev', 'Aigul Bekova']);
    expect(find.text('Viewings ↑'), findsOneWidget);
    expect(_repo.requests, hasLength(1), reason: 'sorting is on the phone');
  });

  testWidgets('tapping an agent shows all their figures', (tester) async {
    await _show(tester);
    await tester.tap(find.text('Aigul Bekova'));
    await tester.pumpAndSettle();

    final sheet = find.byKey(const ValueKey('leaderboard-agent-sheet'));
    expect(sheet, findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('800,000 ₸')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('30,000,000 ₸')),
        findsOneWidget);
    expect(
        find.descendant(of: sheet, matching: find.text('67%')), findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('Deals lost')),
        findsOneWidget);
    expect(find.text('Agent · Sep 1, 2026 – Sep 30, 2026'), findsOneWidget);
  });

  testWidgets('a win rate with nothing closed reads as a dash and sorts last',
      (tester) async {
    await _show(tester);
    await _sortBy(tester, 'winRate');
    await tester.pumpAndSettle();
    expect(_names(tester).take(3),
        ['Timur Aliev', 'Aigul Bekova', 'Dana Seitova']);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('leaderboard-value-13')))
            .data,
        '—');
  });

  testWidgets('waits with a skeleton, not a spinner', (tester) async {
    final gate = Completer<AgentLeaderboard>();
    Injector.leaderboardRepository = _Gated(gate.future);
    await _show(tester);
    expect(find.byType(ShimmerGroup), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    gate.complete(_board);
    await tester.pumpAndSettle();
    expect(find.byType(ShimmerGroup), findsNothing);
    expect(find.text('Timur Aliev'), findsOneWidget);
  });

  testWidgets('an agency with nobody in it says so', (tester) async {
    _repo.board = const AgentLeaderboard(currency: 'KZT');
    await _show(tester);
    expect(find.text('No agents yet'), findsOneWidget);
  });

  testWidgets('a failed load says so and offers a retry', (tester) async {
    _repo.error = Exception('network down');
    await _show(tester);
    expect(find.text('Could not load the leaderboard'), findsOneWidget);

    _repo.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Timur Aliev'), findsOneWidget);
  });

  test('picked dates include the last day', () async {
    final bloc = LeaderboardBloc(_repo);
    addTearDown(bloc.close);
    bloc.add(LeaderboardCustomRange(
        DateTime(2026, 3, 10, 14), DateTime(2026, 4, 2, 9)));
    final loaded = await bloc.stream.firstWhere((s) => s is LeaderboardLoaded);
    expect(loaded.period, LeaderboardPeriod.custom);
    expect(_repo.requests.last,
        (from: DateTime(2026, 3, 10), to: DateTime(2026, 4, 3)));

    bloc.add(LeaderboardLoadEvent());
    await bloc.stream.firstWhere((s) => s is LeaderboardLoaded);
    expect(_repo.requests.last.to, DateTime(2026, 4, 3),
        reason: 'a refresh keeps the picked dates');
  });

  test('last month in January is December of the year before', () {
    final r =
        LeaderboardRange.of(LeaderboardPeriod.lastMonth, DateTime(2027, 1, 5));
    expect(r.from, DateTime(2026, 12));
    expect(r.to, DateTime(2027));
  });

  test('only a manager reaches the leaderboard', () {
    String? go(Role role) => resolveRedirect(
        location: '/leaderboard',
        sessionResolved: true,
        authenticated: true,
        role: role,
        hasTeam: true);
    expect(go(Role.MANAGER), isNull);
    expect(go(Role.AGENT), '/dashboard');
  });

  testWidgets('the manager console row opens the leaderboard', (tester) async {
    await expectNoOverflow(
      tester,
      const Scaffold(body: LeaderboardSettingsRow()),
      size: const Size(320, 568),
      brightness: Brightness.dark,
      textScale: 1.3,
      locale: const Locale('kk'),
    );
    expect(find.text('Агенттер рейтингі'), findsOneWidget);
  });

  forEachAcceptanceCase('leaderboard', (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      _repo.board = _board;
      await _show(tester,
          size: size, brightness: brightness, scale: scale, locale: locale);
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} loaded');
      final aigul = find.byKey(const ValueKey('leaderboard-row-12'));
      await tester.ensureVisible(aigul);
      await tester.pumpAndSettle();
      await tester.tap(aigul);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} sheet');
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      _repo.board = const AgentLeaderboard();
      await _show(tester,
          size: size,
          brightness: brightness,
          scale: scale,
          locale: Locale(locale.languageCode, 'X'));
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} empty');
    }
  });
}
