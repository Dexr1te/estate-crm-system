import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'going_cold_fixtures.dart';

FakeTasksRepository get _tasks =>
    Injector.tasksRepository as FakeTasksRepository;
FakeColdClientsRepository get _cold =>
    Injector.coldClientsRepository as FakeColdClientsRepository;

Future<void> _pumpCard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final bloc = coldBloc();
  addTearDown(bloc.close);
  await tester.pumpWidget(coldCardApp(bloc));
  await tester.pumpAndSettle();
}

void main() {
  late List<Uri> opened;

  setUp(() {
    AppClock.freeze(coldNow);
    addTearDown(AppClock.reset);
    installCold(coldClients);
    opened = [];
    ContactActions.opener = (uri, _) async {
      opened.add(uri);
      return true;
    };
    addTearDown(ContactActions.resetOpener);
  });

  group('the dashboard card', () {
    testWidgets('shows the top three, how long each is silent and why',
        (tester) async {
      await _pumpCard(tester);

      expect(find.byType(ColdClientRow), findsNWidgets(3));
      expect(find.text('Aigerim Serikbaykyzy'), findsOneWidget);
      expect(find.text('Daniyar Abenov'), findsOneWidget);
      expect(find.text('Madina Nurlanovna'), findsNothing);
      expect(find.text('Silent 23 days'), findsOneWidget);
      expect(find.text('Never contacted'), findsOneWidget);
      expect(find.text('Deal in negotiation'), findsOneWidget);
      expect(find.text('4 matches'), findsOneWidget);
      expect(find.text('Open deal'), findsOneWidget);
      expect(find.text('1 match'), findsOneWidget);
      expect(find.text('Timur Aliev'), findsNothing,
          reason: 'eight days is not fourteen');
      expect(find.text('4 in all'), findsOneWidget);
      expect(_cold.queries.single, (14, 20));
    });

    testWidgets('is not there at all when nobody is going cold',
        (tester) async {
      installCold(const []);
      await _pumpCard(tester);

      expect(find.byKey(const ValueKey('going-cold-card')), findsNothing);
      expect(find.byKey(const ValueKey('going-cold-hidden')), findsOneWidget);
    });

    testWidgets('waits with a skeleton, not a spinner', (tester) async {
      final gate = Completer<void>();
      _cold.hold = gate.future;
      final bloc = coldBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(coldCardApp(bloc));

      expect(find.byType(ColdClientRowBone), findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ColdClientRowBone), findsNothing);
    });

    testWidgets('a failure stays inside the card, with a retry',
        (tester) async {
      _cold.readError = Exception('down');
      await _pumpCard(tester);

      expect(find.byKey(const ValueKey('going-cold-card')), findsOneWidget);
      expect(find.text('Could not load who is going cold'), findsOneWidget);

      _cold.readError = null;
      await tester.tap(find.byKey(const ValueKey('going-cold-retry')));
      await tester.pumpAndSettle();
      expect(find.byType(ColdClientRow), findsNWidgets(3));
    });

    testWidgets('Call dials the client', (tester) async {
      await _pumpCard(tester);
      await tester.tap(find.byKey(const ValueKey('cold-call-1')));
      await tester.pumpAndSettle();

      expect(opened.single.scheme, 'tel');
      expect(opened.single.path, contains('7011112233'));
    });

    testWidgets('a client without a phone says so instead of dialling',
        (tester) async {
      await _pumpCard(tester);
      await tester.tap(find.byKey(const ValueKey('cold-call-3')));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(find.text('No phone number on file'), findsOneWidget);
    });

    testWidgets(
        'Remind me makes a task to call them tomorrow at ten, and undo '
        'takes it back', (tester) async {
      await _pumpCard(tester);
      await tester.tap(find.byKey(const ValueKey('cold-remind-1')));
      await tester.pumpAndSettle();

      expect(_tasks.sent.single, {
        'title': 'Call Aigerim Serikbaykyzy',
        'dueAt': DateTime(2026, 3, 11, 10).toIso8601String(),
        'clientId': 1,
      });
      expect(_tasks.tasks.single.clientId, 1);
      expect(find.byKey(const ValueKey('cold-client-1')), findsNothing,
          reason: 'someone is on it now');
      expect(find.textContaining('Reminder set for tomorrow'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cold-undo')));
      await tester.pumpAndSettle();

      expect(_tasks.tasks, isEmpty);
      expect(find.byKey(const ValueKey('cold-client-1')), findsOneWidget);
    });

    testWidgets(
        "the summary's total drops with each reminder and comes back on undo",
        (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bloc = coldBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(coldCardApp(bloc, total: 12));
      await tester.pumpAndSettle();
      expect(find.text('12 in all'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cold-remind-1')));
      await tester.pumpAndSettle();
      expect(find.text('11 in all'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cold-undo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cold-client-1')), findsOneWidget);
      expect(find.text('12 in all'), findsOneWidget);
    });

    testWidgets('a tap opens the client', (tester) async {
      await _pumpCard(tester);
      await tester.tap(find.text('Daniyar Abenov'));
      await tester.pumpAndSettle();

      expect(find.text('client 3'), findsOneWidget);
    });
  });

  group('plural copy', () {
    Future<AppLocalizations> l10n(String code) =>
        AppLocalizations.delegate.load(Locale(code));

    test('English', () async {
      final en = await l10n('en');
      expect(en.clientsColdSilentDays(1), 'Silent 1 day');
      expect(en.clientsColdSilentDays(23), 'Silent 23 days');
      expect(en.clientsColdReasonMatches(1), '1 match');
      expect(en.clientsColdDaysOption(7), '7 days');
    });

    test('Russian', () async {
      final ru = await l10n('ru');
      expect(ru.clientsColdSilentDays(1), 'Без связи 1 день');
      expect(ru.clientsColdSilentDays(21), 'Без связи 21 день');
      expect(ru.clientsColdSilentDays(23), 'Без связи 23 дня');
      expect(ru.clientsColdSilentDays(5), 'Без связи 5 дней');
      expect(ru.clientsColdSilentDays(11), 'Без связи 11 дней');
      expect(ru.clientsColdReasonMatches(3), '3 подходящих объекта');
      expect(ru.clientsColdDaysOption(30), '30 дней');
    });

    test('Kazakh', () async {
      final kk = await l10n('kk');
      expect(kk.clientsColdSilentDays(1), '1 күн хабарсыз');
      expect(kk.clientsColdSilentDays(23), '23 күн хабарсыз');
      expect(kk.clientsColdReasonMatches(5), '5 сәйкес нысан');
      expect(kk.clientsColdDaysOption(14), '14 күн');
    });
  });
}
