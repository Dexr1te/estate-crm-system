import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/tasks/domain/task_repeat_rule.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/record_tasks_card.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_form.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_repeat_labels.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_repeat_sheet.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Repeating tasks on the phone: the picker in the task form, the rule said
/// in words on the card and in the sheet, and stopping a series. Where the
/// next occurrence falls is the server's arithmetic and is tested there; the
/// phone only has to send the rule it was given and say it back correctly,
/// the 31st and 29 February included.

final _now = DateTime(2026, 9, 25, 15, 30);

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

final _en = lookupAppLocalizations(const Locale('en'));
final _ru = lookupAppLocalizations(const Locale('ru'));
final _kk = lookupAppLocalizations(const Locale('kk'));

/// 2026-10-01 is a Thursday.
final _due = DateTime(2026, 10, 1, 9, 30);

TaskResponse _repeating(int id, String title, TaskRepeat repeat,
        {DateTime? due}) =>
    TaskResponse(
      id: id,
      title: title,
      dueAt: due ?? _due,
      clientId: 1,
      clientName: 'Irina Sokolova',
      assigneeId: 5,
      assigneeName: 'Maria Kim',
      seriesId: 40 + id,
      occurrence: 3,
      repeat: repeat,
    );

final _weekly = TaskRepeat(
  frequency: RepeatFrequency.weekly,
  weekdays: const ['MONDAY', 'THURSDAY'],
  anchorAt: _due,
);

final _monthly31 = TaskRepeat(
  frequency: RepeatFrequency.monthly,
  anchorAt: DateTime(2026, 8, 31, 9, 30),
  count: 12,
);

late FakeTasksRepository _tasks;

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844)}) async {
  final auth = AuthBloc(FakeAuthRepository(user: _agent))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  await expectNoOverflow(
    tester,
    BlocProvider.value(value: auth, child: child),
    size: size,
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

Widget _record() => const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child:
            RecordTasksCard(client: PickerItem(id: 1, title: 'Irina Sokolova')),
      ),
    );

Widget _inSheet(Widget child) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(title: 'Repeat', child: child),
      ),
    );

Widget _repeatSheet(TaskRepeat? initial) =>
    _inSheet(TaskRepeatForm(initial: initial, due: _due, onDone: (_) {}));

Widget _editForm(TaskResponse task) => _inSheet(TaskForm(
      task: task,
      onSave: (_) async {},
      onDelete: () async {},
      onStopRepeating: () async {},
    ));

Widget _rows() => Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TaskRow(
            task: _repeating(
                1,
                'Call the landlord about the meter readings for the flat',
                _weekly)),
        const SizedBox(height: 8),
        TaskRow(task: _repeating(2, 'Collect the rent', _monthly31)),
      ]),
    );

void main() {
  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(_now);
    _tasks = FakeTasksRepository([
      _repeating(1, 'Call the landlord', _weekly),
    ]);
    Injector.tasksRepository = _tasks;
  });
  tearDown(AppClock.reset);

  group('the rule in words', () {
    String en(TaskRepeat r, [DateTime? due]) =>
        repeatLabel(_en, r, due ?? _due, 'en');

    test('each frequency', () {
      expect(
          en(const TaskRepeat(frequency: RepeatFrequency.daily)), 'Every day');
      expect(en(_weekly), 'Every week on Mon, Thu');
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.monthly,
              anchorAt: DateTime(2026, 1, 2))),
          'Every month on the 2nd');
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.quarterly,
              anchorAt: DateTime(2026, 1, 15))),
          'Every 3 months on the 15th');
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.yearly,
              anchorAt: DateTime(2026, 3, 8))),
          'Every year on March 8');
    });

    test('a weekly rule without days falls on the due day', () {
      expect(en(const TaskRepeat(frequency: RepeatFrequency.weekly), _due),
          'Every week on Thu');
    });

    test('English ordinals, 11th to 13th included', () {
      String day(int d) => en(TaskRepeat(
          frequency: RepeatFrequency.monthly, anchorAt: DateTime(2026, 1, d)));
      expect(day(1), 'Every month on the 1st');
      expect(day(3), 'Every month on the 3rd');
      expect(day(11), 'Every month on the 11th');
      expect(day(12), 'Every month on the 12th');
      expect(day(13), 'Every month on the 13th');
      expect(day(21), 'Every month on the 21st');
      expect(day(22), 'Every month on the 22nd');
    });

    test('the 31st, and 29 February, say what happens in shorter months', () {
      expect(en(_monthly31.copyWith(count: null)),
          'Every month on the 31st (last day in shorter months)');
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.yearly,
              anchorAt: DateTime(2028, 2, 29))),
          'Every year on February 29 (28 February in other years)');
      // Every quarter from 31 January passes through 30 April; from the 15th
      // nothing is short.
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.quarterly,
              anchorAt: DateTime(2026, 1, 31))),
          'Every 3 months on the 31st (last day in shorter months)');
      expect(
          clampsInShortMonths(RepeatFrequency.quarterly, DateTime(2026, 1, 30)),
          isFalse,
          reason: 'January, April, July and October all have a 30th');
      expect(
          clampsInShortMonths(RepeatFrequency.monthly, DateTime(2026, 1, 29)),
          isTrue);
      expect(
          clampsInShortMonths(RepeatFrequency.monthly, DateTime(2026, 1, 28)),
          isFalse);
    });

    test('the end: a day, or a number of times', () {
      expect(
          en(TaskRepeat(
              frequency: RepeatFrequency.daily, until: DateTime(2026, 10, 30))),
          'Every day, until Oct 30');
      expect(en(const TaskRepeat(frequency: RepeatFrequency.daily, count: 1)),
          'Every day, once');
      expect(en(const TaskRepeat(frequency: RepeatFrequency.daily, count: 5)),
          'Every day, 5 times');
    });

    test('Russian and Kazakh, with their plurals', () {
      String ru(TaskRepeat r) => repeatLabel(_ru, r, _due, 'ru');
      String kk(TaskRepeat r) => repeatLabel(_kk, r, _due, 'kk');

      expect(ru(_monthly31.copyWith(count: null)),
          'Каждый месяц, 31-го числа (в коротких месяцах — в последний день)');
      expect(ru(const TaskRepeat(frequency: RepeatFrequency.daily, count: 2)),
          'Каждый день, 2 раза');
      expect(ru(const TaskRepeat(frequency: RepeatFrequency.daily, count: 5)),
          'Каждый день, 5 раз');
      expect(ru(const TaskRepeat(frequency: RepeatFrequency.daily, count: 21)),
          'Каждый день, 21 раз');
      expect(ru(_weekly), startsWith('Каждую неделю: '));
      expect(kk(_monthly31.copyWith(count: null)),
          'Ай сайын, 31-күні (қысқа айларда — соңғы күні)');
      expect(kk(const TaskRepeat(frequency: RepeatFrequency.daily, count: 3)),
          'Күн сайын, 3 рет');
    });

    test('no frequency shows as its picker name, never as an enum', () {
      for (final l10n in [_en, _ru, _kk]) {
        for (final f in RepeatFrequency.values) {
          final label = repeatOptionLabel(l10n, f);
          expect(label, isNot(contains(f.name)));
          expect(label, isNotEmpty);
        }
      }
    });
  });

  group('what the form sends', () {
    test('a rule, its days Monday first, and one end', () {
      expect(
          repeatRequest(TaskRepeat(
              frequency: RepeatFrequency.weekly,
              weekdays: const ['THURSDAY', 'monday', 'FUNDAY'],
              until: DateTime(2026, 12, 1, 23, 59),
              count: 4)),
          {
            'frequency': 'WEEKLY',
            'weekdays': ['MONDAY', 'THURSDAY'],
            'until': '2026-12-01',
          });
      expect(
          repeatRequest(const TaskRepeat(
              frequency: RepeatFrequency.monthly,
              weekdays: ['MONDAY'],
              count: 6)),
          {'frequency': 'MONTHLY', 'count': 6});
      expect(repeatRequest(null), {'frequency': 'NONE'});
    });

    test('an unknown frequency from a newer server reads as none', () {
      final task = TaskResponse.fromJson({
        'id': 1,
        'dueAt': '2026-10-01T09:30:00',
        'repeat': {'frequency': 'FORTNIGHTLY'},
      });
      expect(task.repeats, isFalse);
      final known = TaskResponse.fromJson({
        'id': 2,
        'dueAt': '2026-10-01T09:30:00',
        'seriesId': 9,
        'occurrence': 2,
        'repeat': {
          'frequency': 'WEEKLY',
          'weekdays': ['MONDAY'],
          'until': '2026-12-01',
          'anchorAt': '2026-09-28T09:30:00',
        },
      });
      expect(known.repeats, isTrue);
      expect(known.repeat!.until, DateTime(2026, 12, 1));
      expect(weekdayNumbers(known.repeat!.weekdays), [DateTime.monday]);
    });
  });

  group('on the card and in the sheet', () {
    testWidgets('a repeating task says how it repeats under its title',
        (tester) async {
      await _pump(tester, _record());

      expect(find.text('Call the landlord'), findsOneWidget);
      expect(find.text('Every week on Mon, Thu'), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
    });

    testWidgets('a new task picks weekly on two days, ending after 4 times',
        (tester) async {
      _tasks.tasks = const [];
      await _pump(tester, _record());

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Water plants');
      await tester.tap(find.text('Tomorrow morning'));
      await tester.pump();
      expect(find.text('Does not repeat'), findsOneWidget);

      await tester.tap(find.text('Does not repeat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly'));
      await tester.pump();
      // Tomorrow, 26 September 2026, is a Saturday: it starts chosen.
      await tester.tap(find.text('Mon'));
      await tester.pump();
      await tester.tap(find.text('After'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextFormField, '5'), '4');
      await tester.pump();
      expect(find.text('Every week on Mon, Sat, 4 times'), findsOneWidget);
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Every week on Mon, Sat, 4 times'), findsOneWidget,
          reason: 'the form shows the rule it will send');
      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();

      expect(_tasks.sent.single['repeat'], {
        'frequency': 'WEEKLY',
        'weekdays': ['MONDAY', 'SATURDAY'],
        'count': 4,
      });
      expect(find.text('Every week on Mon, Sat, 4 times'), findsOneWidget,
          reason: 'the new task on the card says how it repeats');
    });

    testWidgets('a plain new task says nothing about repeats', (tester) async {
      _tasks.tasks = const [];
      await _pump(tester, _record());

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Call');
      await tester.tap(find.text('Tomorrow morning'));
      await tester.pump();
      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();

      expect(_tasks.sent.single.containsKey('repeat'), isFalse);
    });

    testWidgets('a count outside 1-999 is refused in the picker',
        (tester) async {
      TaskRepeat? done;
      await _pump(
          tester,
          _inSheet(TaskRepeatForm(
              initial: const TaskRepeat(frequency: RepeatFrequency.daily),
              due: _due,
              onDone: (r) => done = r)));

      await tester.tap(find.text('After'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextFormField, '5'), '0');
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(find.text('From 1 to 999'), findsOneWidget);
      expect(done, isNull);
    });

    testWidgets('editing a repeating task shows its rule and can stop it',
        (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.text('Call the landlord'));
      await tester.pumpAndSettle();
      expect(find.text('Every week on Mon, Thu'), findsWidgets);

      await tester.ensureVisible(find.text('Stop repeating'));
      await tester.tap(find.text('Stop repeating'));
      await tester.pumpAndSettle();
      expect(find.text('Stop repeating this task?'), findsOneWidget);
      await tester.tap(find.text('Stop repeating').last);
      await tester.pumpAndSettle();

      expect(_tasks.stopped, [1]);
      expect(find.text('The task no longer repeats'), findsOneWidget);
      expect(find.text('Every week on Mon, Thu'), findsNothing);
      expect(find.text('Call the landlord'), findsOneWidget,
          reason: 'the task itself stays');
    });

    testWidgets('choosing "Does not repeat" on a repeating task sends NONE',
        (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.text('Call the landlord'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.repeat_rounded).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Does not repeat'));
      await tester.pump();
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();

      expect(_tasks.sent.single['repeat'], {'frequency': 'NONE'});
    });

    testWidgets('a last day before the due day is refused on save',
        (tester) async {
      Map<String, dynamic>? saved;
      await _pump(
          tester,
          _inSheet(TaskForm(
            task: _repeating(
                1,
                'Call',
                TaskRepeat(
                    frequency: RepeatFrequency.daily,
                    until: DateTime(2026, 9, 30),
                    anchorAt: DateTime(2026, 9, 20, 9, 30))),
            onSave: (data) async => saved = data,
          )));

      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pump();

      expect(find.text('The last day cannot be before the task is due'),
          findsOneWidget);
      expect(saved, isNull);
    });
  });

  group('layout', () {
    forEachAcceptanceCase('repeat picker, weekly ending after a count',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester,
          _repeatSheet(const TaskRepeat(
              frequency: RepeatFrequency.weekly,
              weekdays: [
                'MONDAY',
                'TUESDAY',
                'WEDNESDAY',
                'THURSDAY',
                'FRIDAY'
              ],
              count: 999)),
          size: size,
          brightness: brightness,
          textScale: scale);
    });

    forEachAcceptanceCase('repeat picker, monthly on the 31st until a day',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester,
          _repeatSheet(TaskRepeat(
              frequency: RepeatFrequency.monthly,
              anchorAt: DateTime(2026, 8, 31),
              until: DateTime(2027, 12, 31))),
          size: size,
          brightness: brightness,
          textScale: scale);
    });

    forEachAcceptanceCase('task sheet of a repeating task',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _editForm(_repeating(1, 'Call', _monthly31)),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('task rows that repeat',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _rows(),
          size: size, brightness: brightness, textScale: scale);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('everything renders in ${locale.languageCode}',
          (tester) async {
        for (final child in [
          _repeatSheet(null),
          _repeatSheet(_weekly.copyWith(count: 12)),
          _repeatSheet(_monthly31.copyWith(count: null, until: DateTime(2027))),
          _editForm(_repeating(1, 'Call', _monthly31)),
          _rows(),
        ]) {
          await expectNoOverflow(tester, child,
              size: const Size(320, 568),
              brightness: Brightness.dark,
              textScale: 1.5,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
