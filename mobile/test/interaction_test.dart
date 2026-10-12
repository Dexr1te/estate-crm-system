import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_form_screen.dart';
import 'package:real_estate_crm/features/compare/presentation/widgets/compare_header.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppThemeDark.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Widget _hostAll(List<Widget> children) => _app(Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              ...children,
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ));

Widget _host(Widget child) => _hostAll([child]);

List<String?> _recordHaptics(WidgetTester tester) {
  final log = <String?>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      log.add(call.arguments as String?);
    }
    return null;
  });
  addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
  return log;
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Widget _pickerLauncher(Future<void> Function(BuildContext context) open) =>
    Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

class _Saved with ActionSucceeded {
  @override
  ActionMessage get message => ActionMessage.clientCreated;
}

class _Failed with ActionFailed {
  @override
  ApiFailure get failure => const ApiFailure(ApiFailureKind.server);
}

void main() {
  group('touch targets', () {
    testWidgets('a filter pill answers taps up to 44pt tall', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(FilterPill(
          key: const Key('pill'),
          label: 'All',
          selected: false,
          onTap: () => taps++)));

      final pill = tester.getRect(find.byKey(const Key('pill')));
      expect(pill.height, lessThan(AppMetrics.minHitTarget));
      final slop = (AppMetrics.minHitTarget - pill.height) / 2;

      await tester.tapAt(pill.topCenter - Offset(0, slop - 1));
      await tester.tapAt(pill.bottomCenter + Offset(0, slop - 1));
      expect(taps, 2);

      await tester.tapAt(pill.topCenter - Offset(0, slop + 3));
      expect(taps, 2);
    });

    testWidgets('pills in a row and a wrap keep the taller hit area',
        (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(_hostAll([
        FilterPillRow(pills: [
          for (final l in ['One', 'Two'])
            FilterPill(
                key: Key('row-$l'),
                label: l,
                selected: false,
                onTap: () => tapped.add('row-$l')),
        ]),
        const SizedBox(height: 30),
        FilterPillWrap(pills: [
          for (final l in ['Three', 'Four'])
            FilterPill(
                key: Key('wrap-$l'),
                label: l,
                selected: false,
                onTap: () => tapped.add('wrap-$l')),
        ]),
      ]));

      final two = tester.getRect(find.byKey(const Key('row-Two')));
      final four = tester.getRect(find.byKey(const Key('wrap-Four')));
      await tester.tapAt(two.topCenter - const Offset(0, 4));
      await tester.tapAt(four.bottomCenter + const Offset(0, 4));
      expect(tapped, ['row-Two', 'wrap-Four']);
    });

    testWidgets('a segmented control answers taps up to 44pt tall',
        (tester) async {
      final picked = <int>[];
      await tester.pumpWidget(_host(SegmentedTabs(
          key: const Key('tabs'),
          labels: const ['Day', 'Week'],
          selectedIndex: 0,
          onSelected: picked.add)));

      final tabs = tester.getRect(find.byKey(const Key('tabs')));
      expect(tabs.height, lessThan(AppMetrics.minHitTarget));
      final slop = (AppMetrics.minHitTarget - tabs.height) / 2;

      await tester.tapAt(Offset(tabs.right - 40, tabs.top + 1));
      await tester.tapAt(Offset(tabs.left + 40, tabs.bottom - 1));
      await tester.tapAt(Offset(tabs.right - 40, tabs.top - slop / 2));
      await tester.tapAt(Offset(tabs.left + 40, tabs.bottom + slop / 2));
      expect(picked, [1, 0, 1, 0]);

      await tester.tapAt(Offset(tabs.right - 40, tabs.top - slop - 2));
      expect(picked, hasLength(4));
    });

    testWidgets('the compare cross is a 44pt target', (tester) async {
      var removed = 0;
      var opened = 0;
      await tester.pumpWidget(_app(Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            height: compareHeaderHeight(TextScaler.noScaling),
            child: CompareHeader(
              property: const PropertyResponse(id: 2, title: 'Satpaev 5'),
              onOpen: () => opened++,
              onRemove: () => removed++,
            ),
          ),
        ),
      )));

      final cross = find.byKey(const ValueKey('compare-remove-2'));
      final rect = tester.getRect(cross);
      expect(rect.width, greaterThanOrEqualTo(AppMetrics.minHitTarget));
      expect(rect.height, greaterThanOrEqualTo(AppMetrics.minHitTarget));

      await tester.tapAt(rect.topRight + const Offset(-2, 2));
      await tester.tapAt(rect.bottomLeft + const Offset(2, -2));
      expect(removed, 2);
      expect(opened, 0);
    });

    testWidgets('the sign-up consent is one row: tapping its words ticks it',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(BlocProvider(
        create: (_) =>
            AuthBloc(FakeAuthRepository(), verifier: FakeEmailVerifier())
              ..add(AuthCheckEvent()),
        child: const RegisterFormScreen(role: Role.AGENT),
      )));
      await tester.pumpAndSettle();

      final consent = find.byKey(const Key('register-consent'));
      await tester.ensureVisible(consent);
      await tester.pumpAndSettle();
      expect(tester.getSize(consent).height,
          greaterThanOrEqualTo(AppMetrics.minHitTarget));

      bool ticked() =>
          tester.widget<Checkbox>(find.byType(Checkbox)).value ?? false;
      expect(ticked(), isFalse);

      final words = tester.getRect(
          find.descendant(of: consent, matching: find.byType(RichText)).first);
      await tester.tapAt(words.topLeft + const Offset(6, 6));
      await tester.pump();
      expect(ticked(), isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(ticked(), isFalse);
    });
  });

  group('haptics', () {
    testWidgets('buttons tap lightly, danger presses harder', (tester) async {
      final log = _recordHaptics(tester);
      await tester.pumpWidget(_host(Column(children: [
        AppFilledButton(label: 'Save', onPressed: () {}),
        AppGhostButton(label: 'Later', onPressed: () {}),
        AppDangerButton(label: 'Remove', onPressed: () {}),
        AppIconTile(icon: Icons.edit_outlined, onPressed: () {}),
        const AppFilledButton(label: 'Off', onPressed: null),
      ])));

      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Later'));
      await tester.tap(find.text('Remove'));
      await tester.tap(find.byType(AppIconTile));
      await tester.tap(find.text('Off'));
      expect(log, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.selectionClick',
      ]);
    });

    testWidgets('pills and segments click on a change', (tester) async {
      final log = _recordHaptics(tester);
      await tester.pumpWidget(_host(Column(children: [
        FilterPill(label: 'All', selected: false, onTap: () {}),
        const SizedBox(height: 20),
        SegmentedTabs(
            labels: const ['Day', 'Week'],
            selectedIndex: 0,
            onSelected: (_) {}),
      ])));

      await tester.tap(find.text('All'));
      await tester.tap(find.text('Day'));
      await tester.tap(find.text('Week'));
      expect(log, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.selectionClick',
      ]);
    });

    testWidgets('confirming a destructive dialog presses harder',
        (tester) async {
      final log = _recordHaptics(tester);
      bool? confirmed;
      await tester.pumpWidget(_app(_pickerLauncher((context) async {
        confirmed = await showConfirmDialog(context,
            title: 'Delete client?', content: 'This cannot be undone.');
      })));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      log.clear();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
      expect(log, ['HapticFeedbackType.mediumImpact']);
    });

    testWidgets('an outcome snackbar confirms success and warns on failure',
        (tester) async {
      final log = _recordHaptics(tester);
      late BuildContext context;
      await tester.pumpWidget(_app(Scaffold(body: Builder(builder: (c) {
        context = c;
        return const SizedBox.expand();
      }))));

      showActionOutcome(context, _Saved());
      showActionOutcome(context, _Failed());
      showActionOutcome(context, 'not an outcome');
      await tester.pump();
      expect(log, [
        'HapticFeedbackType.successNotification',
        'HapticFeedbackType.warningNotification',
      ]);
    });
  });

  group('adaptive controls', () {
    testWidgets('the switch is Material with a selection click on Android',
        (tester) async {
      final log = _recordHaptics(tester);
      var value = false;
      await tester.pumpWidget(_host(StatefulBuilder(
          builder: (context, setState) => AppSwitch(
              value: value, onChanged: (v) => setState(() => value = v)))));

      expect(find.byType(CupertinoSwitch), findsNothing);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(log, ['HapticFeedbackType.selectionClick']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('the switch is Cupertino on iOS, with its own single tick',
        (tester) async {
      final log = _recordHaptics(tester);
      var value = false;
      await tester.pumpWidget(_host(StatefulBuilder(
          builder: (context, setState) => AppSwitch(
              value: value, onChanged: (v) => setState(() => value = v)))));

      final cupertino =
          tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch));
      expect(cupertino.activeTrackColor, AppTokens.light.primary);
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(log, ['HapticFeedbackType.lightImpact']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('on Android the date and time pickers are Material dialogs',
        (tester) async {
      DateTime? date;
      TimeOfDay? time;
      await tester.pumpWidget(_app(_pickerLauncher((context) async {
        date = await showAppDatePicker(
            context: context,
            initialDate: DateTime(2026, 9, 20),
            firstDate: DateTime(2026),
            lastDate: DateTime(2026, 12, 31));
        if (!context.mounted) return;
        time = await showAppTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 9, minute: 30));
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.byType(CupertinoDatePicker), findsNothing);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(date, DateTime(2026, 9, 20));

      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(time, const TimeOfDay(hour: 9, minute: 30));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('on iOS the date picker is a wheel in a sheet, date only',
        (tester) async {
      DateTime? date;
      var closed = false;
      await tester.pumpWidget(_app(_pickerLauncher((context) async {
        date = await showAppDatePicker(
            context: context,
            initialDate: DateTime(2026, 9, 28, 15, 30),
            firstDate: DateTime(2025),
            lastDate: DateTime(2026, 9, 28));
        closed = true;
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
      final wheel =
          tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      expect(wheel.mode, CupertinoDatePickerMode.date);
      expect(wheel.maximumDate, DateTime(2026, 9, 28));

      await tester.tap(find.byKey(const Key('app-picker-done')));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(date, DateTime(2026, 9, 28));
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('on iOS a wheel turned and dismissed gives nothing back',
        (tester) async {
      DateTime? date = DateTime(1999);
      await tester.pumpWidget(_app(_pickerLauncher((context) async {
        date = await showAppDatePicker(
            context: context,
            initialDate: DateTime(2026, 9, 20),
            firstDate: DateTime(2025),
            lastDate: DateTime(2027));
      })));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);
      expect(date, isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('on iOS the time wheel follows the locale clock',
        (tester) async {
      for (final (locale, twentyFour) in [
        (const Locale('en'), false),
        (const Locale('ru'), true),
      ]) {
        TimeOfDay? time;
        await tester.pumpWidget(_app(
          _pickerLauncher((context) async {
            time = await showAppTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 30));
          }),
          locale: locale,
        ));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final wheel = tester
            .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
        expect(wheel.mode, CupertinoDatePickerMode.time);
        expect(wheel.use24hFormat, twentyFour, reason: locale.languageCode);

        await tester.tap(find.byKey(const Key('app-picker-done')));
        await tester.pumpAndSettle();
        expect(time, const TimeOfDay(hour: 9, minute: 30));
      }
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    for (final locale in const [Locale('en'), Locale('ru'), Locale('kk')]) {
      testWidgets(
          'the iOS wheels fit at 320pt and 1.5x — ${locale.languageCode}',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        for (final time in [false, true]) {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppThemeDark.dark,
            themeMode: ThemeMode.dark,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: _pickerLauncher((context) async {
              if (time) {
                await showAppTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 21, minute: 45));
              } else {
                await showAppDatePicker(
                    context: context,
                    initialDate: DateTime(2026, 9, 28),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030));
              }
            }),
          ));
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '${locale.languageCode} ${time ? 'time' : 'date'}');
          expect(find.byKey(const Key('app-picker-done')), findsOneWidget);
          await tester.tap(find.byKey(const Key('app-picker-done')));
          await tester.pumpAndSettle();
        }
      }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
    }
  });

  group('dark mode', () {
    Future<(AppTokens, ThemeData)> darkOf(WidgetTester tester) async {
      late AppTokens tokens;
      late ThemeData theme;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppThemeDark.dark,
        themeMode: ThemeMode.dark,
        home: Builder(builder: (context) {
          tokens = context.tokens;
          theme = Theme.of(context);
          return const SizedBox();
        }),
      ));
      return (tokens, theme);
    }

    testWidgets('Android gets Material greys', (tester) async {
      final (t, theme) = await darkOf(tester);
      expect(t.background, const Color(0xFF121212));
      expect(t.surface, const Color(0xFF1E1E1E));
      expect(t.surfaceVariant, const Color(0xFF2A2A2A));
      expect(theme.cardTheme.color, t.surface);
      expect(theme.inputDecorationTheme.fillColor, t.surfaceVariant);
      expect(theme.colorScheme.surface, t.surface);
      expect(t.heroSurface, t.surface);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('iOS keeps true black with raised cards', (tester) async {
      final (t, theme) = await darkOf(tester);
      expect(t.background, const Color(0xFF000000));
      expect(t.surface, const Color(0xFF1C1C1E));
      expect(t.surfaceVariant, const Color(0xFF2C2C2E));
      expect(theme.cardTheme.color, t.surface);
      expect(theme.inputDecorationTheme.fillColor, t.surfaceVariant);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('light mode is the same on both platforms', (tester) async {
      late AppTokens tokens;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppThemeDark.dark,
        home: Builder(builder: (context) {
          tokens = context.tokens;
          return const SizedBox();
        }),
      ));
      expect(tokens, same(AppTokens.light));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    test('the dark gold is calmer and still reads at AA', () {
      final light = HSLColor.fromColor(AppColors.accent);
      for (final t in [AppTokens.dark, AppTokens.darkMaterial]) {
        final gold = HSLColor.fromColor(t.primary);
        expect(gold.saturation, lessThan(light.saturation));
        expect(_contrast(t.onPrimary, t.primary), greaterThanOrEqualTo(4.5));
        expect(_contrast(t.primary, t.background), greaterThanOrEqualTo(4.5));
        expect(_contrast(t.primary, t.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(t.onAccent, t.accent), greaterThanOrEqualTo(4.5));
        expect(t.heroActionFill, t.primary);
        expect(
            _contrast(t.heroActionLabel, t.heroActionFill), greaterThan(4.5));
      }
    });
  });
}
