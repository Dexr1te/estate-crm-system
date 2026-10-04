import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/out_today_card.dart';
import 'package:real_estate_crm/features/time_off/presentation/bloc/time_off_list_bloc.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/my_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/team_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/time_off_form_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_row.dart';

import 'fakes.dart';
import 'responsive_harness.dart';
import 'time_off_fakes.dart';
import 'time_off_fixtures.dart';

/// Time off wherever it shows — my list, who's out, the form with the
/// meetings on those days, a colleague's as a summary, and the dashboard
/// chip — at every acceptance size, both themes, larger text and all three
/// languages, with the longest names in the fixtures.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  late FakeTimeOffRepository repo;

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

  forEachAcceptanceCase('my time off', (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        signedIn(MyTimeOffScreen(key: ValueKey(locale)), user: timeOffAgent),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'mine, ${locale.languageCode}');
      expect(find.byType(TimeOffRow), findsWidgets);
    }
  });

  forEachAcceptanceCase("who's out", (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        signedIn(TeamTimeOffScreen(key: ValueKey(locale))),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'team, ${locale.languageCode}');
      expect(find.byType(TimeOffRow), findsNWidgets(3));
    }
  });

  forEachAcceptanceCase('the form with meetings on those days',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        signedIn(TimeOffFormScreen(key: ValueKey(locale), id: 11)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'form, ${locale.languageCode}');
      final conflicts = find.byKey(const ValueKey('time-off-conflicts'));
      await tester.ensureVisible(conflicts);
      await _settle(tester, 'conflicts, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('time-off-hand-over')), findsOneWidget);
    }
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'a new one, a colleague\'s summary, the cover picker and the chip, '
          '${locale.languageCode} ${brightness.name} at 320 and 1.5x',
          (tester) async {
        await expectNoOverflow(
          tester,
          signedIn(const TimeOffFormScreen()),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'new, ${locale.languageCode}');
        final cover = find.byKey(const ValueKey('time-off-cover'));
        await tester.ensureVisible(cover);
        await _settle(tester, 'cover field, ${locale.languageCode}');
        await tester.tap(cover);
        await _settle(tester, 'cover picker, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('picker-badge-2')), findsOneWidget);

        await expectNoOverflow(
          tester,
          signedIn(const TimeOffFormScreen(key: ValueKey('summary'), id: 12),
              user: timeOffAgent),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'summary, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('time-off-summary')), findsOneWidget);

        repo.items = [aigulHoliday, longSickLeave];
        final bloc = TimeOffListBloc(repo, daysAhead: 60)
          ..add(TimeOffListLoadEvent());
        addTearDown(bloc.close);
        await expectNoOverflow(
          tester,
          Scaffold(
            key: const ValueKey('chip'),
            body: Builder(
              builder: (context) => Padding(
                padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
                child: BlocProvider.value(
                    value: bloc, child: OutTodayCard(onTap: () {})),
              ),
            ),
          ),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'chip, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('out-today')), findsOneWidget);
      });
    }
  }
}
