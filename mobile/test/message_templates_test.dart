import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/message_templates/presentation/screens/message_templates_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The manager keeps the agency's message templates: added, rewritten and
/// deleted one at a time, each straight to the server; placeholders put in
/// with a tap, and a name the app could not fill caught before saving.

const _templates = [
  MessageTemplate(
      id: 1,
      title: 'Introduction',
      body: 'Hello, {client}! This is {agent}, your real estate agent.'),
  MessageTemplate(
      id: 2,
      title: 'A listing for you',
      body: 'Hello, {client}! I have a property that may suit you:\n'
          '{listing}\n{address}\n{price}\n{link}\n{agent}'),
];

late FakeMessageTemplatesRepository _repo;

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(390, 1000),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, const MessageTemplatesScreen(),
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
}

AppFilledButton _save(WidgetTester tester) =>
    tester.widget<AppFilledButton>(find.byKey(const Key('template-save')));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _repo = FakeMessageTemplatesRepository(List.of(_templates));
    Injector.messageTemplatesRepository = _repo;
  });
  tearDown(() =>
      Injector.messageTemplatesRepository = FakeMessageTemplatesRepository());

  testWidgets('the templates are listed by title with the start of the text',
      (tester) async {
    await _pump(tester);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('A listing for you'), findsOneWidget);
    expect(find.textContaining('This is {agent}'), findsOneWidget,
        reason: 'the manager sees the placeholders as written');
  });

  testWidgets('a new template is written, placeholders tapped in, and saved',
      (tester) async {
    await _pump(tester);
    await _tap(tester, find.byKey(const Key('template-new')));
    expect(find.text('New template'), findsOneWidget);
    expect(_save(tester).onPressed, isNull, reason: 'nothing written yet');

    await tester.enterText(
        find.byKey(const Key('template-title-field')), 'Keys ready');
    await tester.enterText(
        find.byKey(const Key('template-body-field')), 'Hello, ');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('placeholder-client')));
    await tester.enterText(find.byKey(const Key('template-body-field')),
        '${_bodyText(tester)}! The keys to ');
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('placeholder-listing')));
    await _tap(tester, find.byKey(const Key('template-save')));

    expect(_repo.saved.single, (
      id: null,
      title: 'Keys ready',
      body: 'Hello, {client}! The keys to {listing}'
    ));
    expect(find.text('Keys ready'), findsOneWidget);
    expect(find.text('Template saved'), findsOneWidget);
  });

  testWidgets('a placeholder the app cannot fill is named and blocks saving',
      (tester) async {
    await _pump(tester);
    await _tap(tester, find.byKey(const Key('template-new')));
    await tester.enterText(
        find.byKey(const Key('template-title-field')), 'Greeting');
    await tester.enterText(
        find.byKey(const Key('template-body-field')), 'Dear {name}, hello');
    await tester.pump();

    expect(find.text('Unknown placeholder: {name}. Use the ones below.'),
        findsOneWidget);
    expect(_save(tester).onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('template-body-field')), 'Dear {Client}, hello');
    await tester.pump();
    expect(find.byKey(const Key('template-unknown')), findsNothing);
    expect(_save(tester).onPressed, isNotNull);
  });

  testWidgets('tapping a template opens it for rewriting', (tester) async {
    await _pump(tester);
    await _tap(tester, find.text('Introduction'));
    expect(find.text('Edit template'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('template-title-field')), 'First hello');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('template-save')));

    expect(_repo.saved.single.id, 1);
    expect(_repo.saved.single.body, _templates.first.body);
    expect(find.text('First hello'), findsOneWidget);
    expect(find.text('Introduction'), findsNothing);
  });

  testWidgets('deleting asks first, then the template is gone', (tester) async {
    await _pump(tester);
    await _tap(tester, find.byKey(const ValueKey('template-delete-2')));
    expect(find.text('Delete template?'), findsOneWidget);
    expect(
        find.text('"A listing for you" will no longer be offered to agents.'),
        findsOneWidget);

    await _tap(tester, find.text('Cancel'));
    expect(_repo.deleted, isEmpty);

    await _tap(tester, find.byKey(const ValueKey('template-delete-2')));
    await _tap(tester, find.text('Delete'));
    expect(_repo.deleted, [2]);
    expect(find.text('A listing for you'), findsNothing);
    expect(find.text('Template deleted'), findsOneWidget);
  });

  testWidgets('a failed save keeps the list as it was and says so',
      (tester) async {
    await _pump(tester);
    _repo.writeError = Exception('offline');
    await _tap(tester, find.text('Introduction'));
    await tester.enterText(
        find.byKey(const Key('template-title-field')), 'Changed');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('template-save')));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Changed'), findsNothing);
  });

  testWidgets('an agency with none says so', (tester) async {
    _repo.templates = const [];
    await _pump(tester);
    expect(find.text('No templates yet'), findsOneWidget);
  });

  testWidgets('a failed read offers a retry', (tester) async {
    _repo.readError = Exception('offline');
    await _pump(tester);
    expect(find.text('Could not load templates'), findsOneWidget);
    _repo.readError = null;
    _repo.templates = List.of(_templates);
    await _tap(tester, find.text('Retry'));
    expect(find.text('Introduction'), findsOneWidget);
  });

  forEachAcceptanceCase('the message templates screen',
      (tester, size, brightness, scale) async {
    await _pump(tester, size: size, brightness: brightness, scale: scale);
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the screen and its editor in ${locale.languageCode} at 1.5x',
        (tester) async {
      await _pump(tester,
          size: const Size(320, 568), scale: 1.5, locale: locale);
      expect(tester.takeException(), isNull);
      await _tap(tester, find.byKey(const ValueKey('template-2')));
      expect(tester.takeException(), isNull);
      await tester.enterText(
          find.byKey(const Key('template-body-field')), 'Dear {name}');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

String _bodyText(WidgetTester tester) => tester
    .widget<EditableText>(find.descendant(
        of: find.byKey(const Key('template-body-field')),
        matching: find.byType(EditableText)))
    .controller
    .text;
