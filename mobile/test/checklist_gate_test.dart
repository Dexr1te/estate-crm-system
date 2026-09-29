import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_sheets.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';

import 'checklist_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// The soft gate: every way a deal moves on — the stage pills on the deal, a
/// drop on the board, the stage picker in the form — says how many required
/// lines it leaves behind and asks first. Saying no leaves the deal where it
/// was; saying yes moves it, because the server never refuses the move.

late FakeChecklistRepository _checklist;
late RecordingChecklistDeals _deals;

final _gateTitle = find.text('Required items are open');

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844), double scale = 1.0}) async {
  await expectNoOverflow(tester, withChecklistBlocs(child, _deals),
      size: size, brightness: Brightness.light, textScale: scale);
  await tester.pumpAndSettle();
}

Widget _routed(Widget form) => Router.withConfig(
      config: GoRouter(initialLocation: '/form', routes: [
        GoRoute(path: '/form', builder: (_, __) => form),
        GoRoute(path: '/deals', builder: (_, __) => const SizedBox()),
      ]),
    );

/// The Negotiation pill of the stage card: it comes before the checklist's
/// own Negotiation heading.
Future<void> _tapNegotiationPill(WidgetTester tester) async {
  final pill = find.text('Negotiation').first;
  await tester.ensureVisible(pill);
  await tester.tap(pill);
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
    Injector.clientsRepository = FakeClientsRepository(clients: const [
      ClientResponse(id: 1, fullName: 'Irina Sokolova', type: ClientType.BUYER),
    ]);
    Injector.agentsRepository = const FakeAgentsRepository(
        [AgentOption(id: 5, fullName: 'Aigul Bekova')]);
  });
  tearDown(() {
    AppClock.reset();
    Injector.checklistRepository = FakeChecklistRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
    Injector.documentsRepository = FakeDocumentsRepository();
    Injector.clientsRepository = FakeClientsRepository();
    Injector.agentsRepository = const FakeAgentsRepository([]);
  });

  group('what a move leaves behind', () {
    test('only the stages before the target, and only moving forward', () {
      expect(stagesBehind(DealStatus.LEAD, DealStatus.NEGOTIATION),
          [ChecklistStage.LEAD]);
      expect(stagesBehind(DealStatus.LEAD, DealStatus.CLOSED_WON),
          [ChecklistStage.LEAD, ChecklistStage.NEGOTIATION]);
      expect(
          stagesBehind(DealStatus.CLOSED_WON, DealStatus.NEGOTIATION), isEmpty);
      expect(stagesBehind(DealStatus.NEGOTIATION, DealStatus.CLOSED_LOST),
          isEmpty);
      expect(stagesBehind(DealStatus.CLOSED_LOST, DealStatus.NEGOTIATION),
          [ChecklistStage.LEAD]);
      expect(openRequiredForMove(checklistDeal, DealStatus.CLOSED_WON), 2);
      expect(
          openRequiredInItems(
              checklistItems(), DealStatus.LEAD, DealStatus.NEGOTIATION),
          1);
    });
  });

  testWidgets('on the deal: no leaves it, yes moves it', (tester) async {
    await _pump(tester, const DealDetailScreen(id: 1));
    await _tapNegotiationPill(tester);
    expect(_gateTitle, findsOneWidget);
    expect(find.text('1 required item is not done yet. Move the deal anyway?'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(_deals.moves, isEmpty);

    await _tapNegotiationPill(tester);
    await tester.tap(find.text('Move anyway'));
    await tester.pumpAndSettle();
    expect(_deals.moves, [(1, DealStatus.NEGOTIATION)]);
  });

  testWidgets('on the deal: a line ticked here counts at once', (tester) async {
    await _pump(tester, const DealDetailScreen(id: 1));
    await tester
        .ensureVisible(find.byKey(const ValueKey('checklist-toggle-1')));
    await tester.tap(find.byKey(const ValueKey('checklist-toggle-1')));
    await tester.pumpAndSettle();
    await _tapNegotiationPill(tester);
    expect(_gateTitle, findsNothing);
    expect(_deals.moves, [(1, DealStatus.NEGOTIATION)]);
  });

  testWidgets('on the board: a drop asks first', (tester) async {
    await _pump(tester, const DealsScreen());
    await tester.tap(find.byIcon(Icons.view_kanban_outlined));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('deal-checklist-progress')), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    final card = find.text('Dostyk 5, flat 12');
    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text('Won').last));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
        find.text('2 required items are not done yet. Move the deal anyway?'),
        findsOneWidget);
    expect(_deals.moves, isEmpty);
    await tester.tap(find.text('Move anyway'));
    await tester.pumpAndSettle();
    expect(_deals.moves, [(1, DealStatus.CLOSED_WON)]);
  });

  testWidgets('in the list: each card shows its progress', (tester) async {
    _deals = RecordingChecklistDeals([
      checklistDeal,
      checklistDeal.copyWith(
          id: 2, title: 'No checklist', checklistDone: 0, checklistTotal: 0),
    ]);
    Injector.dealsRepository = _deals;
    await _pump(tester, const DealsScreen());
    expect(find.text('1/3'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('deal-checklist-progress')), findsOneWidget,
        reason: 'a deal with nothing to collect shows no badge');
  });

  testWidgets('in the form: picking a stage asks first', (tester) async {
    await _pump(tester, _routed(const DealFormScreen(dealId: 1)));
    await tester.ensureVisible(find.text('Negotiation'));
    await tester.tap(find.text('Negotiation'));
    await tester.pumpAndSettle();
    expect(_gateTitle, findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update Deal'));
    await tester.pumpAndSettle();
    expect(_deals.updates.single['status'], 'LEAD');
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the warning in ${locale.languageCode} at 320 and 1.5x',
        (tester) async {
      await expectNoOverflow(
          tester,
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmChecklistGate(context, 3),
                child: const Text('move'),
              ),
            ),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.tap(find.text('move'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
