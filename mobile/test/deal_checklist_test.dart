import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';

import 'checklist_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// The checklist on a deal: grouped by stage with the current one open, a
/// box to tick that remembers who and when, a document of the deal to prove
/// a line, and lines of the deal's own that its agent can add and remove.

late FakeChecklistRepository _checklist;
late RecordingChecklistDeals _deals;

Future<void> _pump(WidgetTester tester,
    {AuthResponse user = checklistAgent,
    Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester,
      withChecklistBlocs(const DealDetailScreen(id: 1), _deals, user: user),
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('deal-checklist-card')));
  await tester.pumpAndSettle();
}

Finder _inCard(Finder f) => find.descendant(
    of: find.byKey(const Key('deal-checklist-card')), matching: f);

Future<void> _menu(WidgetTester tester, int itemId, String action) async {
  await tester.ensureVisible(find.byKey(ValueKey('checklist-menu-$itemId')));
  await tester.tap(find.byKey(ValueKey('checklist-menu-$itemId')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(DateTime(2026, 9, 29, 10));
    _checklist = FakeChecklistRepository(byDeal: {1: checklistItems()});
    _deals = RecordingChecklistDeals();
    Injector.checklistRepository = _checklist;
    Injector.dealsRepository = _deals;
    Injector.documentsRepository = FakeDocumentsRepository(checklistDocuments);
    Injector.fileGateway = FakeFileGateway();
  });
  tearDown(() {
    AppClock.reset();
    Injector.checklistRepository = FakeChecklistRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
    Injector.documentsRepository = FakeDocumentsRepository();
  });

  testWidgets('grouped by stage, the current one open, progress up to it',
      (tester) async {
    await _pump(tester);
    expect(find.text('CHECKLIST'), findsOneWidget);
    expect(find.text('1 of 3 done'), findsOneWidget);
    expect(find.text("Copy of the buyer's ID"), findsOneWidget);
    expect(find.byKey(const ValueKey('checklist-required-1')), findsOneWidget);
    expect(find.text('Timur Aliev · Sep 12'), findsOneWidget);
    expect(_inCard(find.text('halyk-preapproval.pdf')), findsOneWidget);
    expect(find.text('Signed deposit agreement'), findsNothing,
        reason: 'a later stage starts folded');

    await tester.tap(find.byKey(const ValueKey('checklist-stage-NEGOTIATION')));
    await tester.pumpAndSettle();
    expect(find.text('Signed deposit agreement'), findsOneWidget);
    expect(find.text('NEGOTIATION'), findsNothing, reason: 'no raw enum names');
  });

  testWidgets('ticking says who and when; un-ticking takes it back',
      (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('checklist-toggle-1')));
    await tester.pumpAndSettle();
    expect(_checklist.updates.single.done, isTrue);
    expect(find.text('2 of 3 done'), findsOneWidget);
    expect(find.byKey(const ValueKey('checklist-required-1')), findsNothing);
    expect(find.text('Aigul Bekova · Sep 12'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('checklist-toggle-2')));
    await tester.pumpAndSettle();
    expect(_checklist.updates.last.done, isFalse);
    expect(find.text('Timur Aliev · Sep 12'), findsNothing);
  });

  testWidgets('a failed tick is put back and says so', (tester) async {
    _checklist.writeError = Exception('offline');
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('checklist-toggle-1')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 done'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a line is proven with one of the deal\'s documents, and let go',
      (tester) async {
    await _pump(tester);
    await _menu(tester, 1, 'Attach document');
    expect(find.text('Choose a document'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('checklist-doc-71')));
    await tester.pumpAndSettle();
    expect(_checklist.updates.single.documentId, 71);
    expect(find.text('document-71.pdf'), findsOneWidget);

    await _menu(tester, 1, 'Remove document');
    expect(_checklist.updates.last.detach, isTrue);
    expect(find.text('document-71.pdf'), findsNothing);
  });

  testWidgets('with no documents yet, the picker says where to upload one',
      (tester) async {
    Injector.documentsRepository = FakeDocumentsRepository();
    await _pump(tester);
    await _menu(tester, 1, 'Attach document');
    expect(
        find.textContaining('Upload the file under Documents'), findsOneWidget);
  });

  testWidgets('the agent adds a line of the deal\'s own and removes it',
      (tester) async {
    await _pump(tester);
    await tester.ensureVisible(find.byKey(const Key('deal-checklist-add')));
    await tester.tap(find.byKey(const Key('deal-checklist-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('checklist-line-title')), 'Utility bills paid');
    await tester.tap(find.byKey(const Key('checklist-line-required')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('checklist-line-save')));
    await tester.pumpAndSettle();
    expect(_checklist.added.single.title, 'Utility bills paid');
    expect(_checklist.added.single.required, isTrue);
    expect(_checklist.added.single.stage, ChecklistStage.LEAD);
    expect(find.text('Utility bills paid'), findsOneWidget);

    await _menu(tester, 5, 'Delete item');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(_checklist.deleted, [5]);
    expect(find.text('Parking permit'), findsNothing);
  });

  testWidgets('a colleague ticks lines but does not add or delete them',
      (tester) async {
    await _pump(tester, user: checklistColleague);
    expect(find.byKey(const Key('deal-checklist-add')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('checklist-menu-5')));
    await tester.pumpAndSettle();
    expect(find.text('Delete item'), findsNothing);
    expect(find.text('Attach document'), findsOneWidget);
  });

  testWidgets('a checklist that did not load offers to try again',
      (tester) async {
    _checklist.readError = Exception('offline');
    await _pump(tester);
    expect(find.text('Could not load the checklist'), findsOneWidget);
    _checklist.readError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text("Copy of the buyer's ID"), findsOneWidget);
  });

  forEachAcceptanceCase('the checklist card', (tester, size, b, scale) async {
    await _pump(tester, size: size, brightness: b, scale: scale);
    await tester.ensureVisible(
        find.byKey(const ValueKey('checklist-stage-NEGOTIATION')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('checklist-stage-NEGOTIATION')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the checklist card in ${locale.languageCode} at 320 and 1.5x',
        (tester) async {
      await _pump(tester,
          size: const Size(320, 568), scale: 1.5, locale: locale);
      await tester.ensureVisible(find.byKey(const Key('deal-checklist-add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('deal-checklist-add')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
