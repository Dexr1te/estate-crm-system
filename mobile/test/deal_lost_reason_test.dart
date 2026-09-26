import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/lost_reason_sheet.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Every way a deal can be lost — the stage pills on the deal, a drop on the
/// board, the stage picker in the form — asks why first, and walking away
/// from the question leaves the deal where it was.

final _now = DateTime(2026, 9, 25, 10, 0);

List<DealResponse> _seed() => [
      const DealResponse(
        id: 1,
        title: 'Severny Residence, apartment 84',
        status: DealStatus.NEGOTIATION,
        clientId: 1,
        clientName: 'Irina Sokolova',
        agentId: 5,
        agentName: 'Maria Kim',
        dealPrice: 12300000,
      ),
      const DealResponse(
        id: 2,
        title: 'Office, Tverskaya 12',
        status: DealStatus.CLOSED_LOST,
        clientId: 2,
        clientName: 'Granit LLC',
        agentId: 5,
        lostReason: DealLostReason.CHOSE_ANOTHER,
        lostNote: 'Went with a developer offering a two-year instalment plan '
            'and a free parking space in the same building',
      ),
      const DealResponse(
        id: 3,
        title: 'House in Romashkovo',
        status: DealStatus.CLOSED_LOST,
        clientId: 3,
        clientName: 'Aleksey Petrov',
        agentId: 5,
      ),
    ];

/// Answers status moves and edits, and remembers what each one carried.
class _RecordingDeals extends FakeDealsRepository {
  final moves = <(int, DealStatus, DealLostReason?, String?)>[];
  final updates = <(int, Map<String, dynamic>)>[];

  _RecordingDeals() : super(_seed());

  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status,
      {DealLostReason? lostReason, String? lostNote}) async {
    moves.add((id, status, lostReason, lostNote));
    final i = deals.indexWhere((d) => d.id == id);
    return deals[i] = deals[i]
        .copyWith(status: status, lostReason: lostReason, lostNote: lostNote);
  }

  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) async {
    updates.add((id, data));
    return deals.firstWhere((d) => d.id == id);
  }
}

late _RecordingDeals _repo;

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(_repo)),
      ],
      child: child,
    );

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844),
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, _wrap(child),
      size: size, brightness: Brightness.light, textScale: 1.0, locale: locale);
  await tester.pumpAndSettle();
}

/// The form leaves for the deals list once saved, so it needs a router.
Widget _routed(Widget form) => Router.withConfig(
      config: GoRouter(initialLocation: '/form', routes: [
        GoRoute(path: '/form', builder: (_, __) => form),
        GoRoute(path: '/deals', builder: (_, __) => const SizedBox()),
      ]),
    );

final _sheetTitle = find.text('Why was the deal lost?');
final _confirm = find.text('Mark as lost');

Future<void> _answer(WidgetTester tester, String reason, {String? note}) async {
  expect(_sheetTitle, findsOneWidget);
  await tester.tap(find.text(reason));
  await tester.pump();
  if (note != null) {
    await tester.enterText(
        find.descendant(
            of: find.byType(LostReasonForm), matching: find.byType(TextField)),
        note);
  }
  await tester.tap(_confirm);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = _RecordingDeals();
    Injector.dealsRepository = _repo;
    Injector.documentsRepository = FakeDocumentsRepository();
    Injector.fileGateway = FakeFileGateway();
    Injector.tasksRepository = FakeTasksRepository(const []);
    Injector.clientsRepository = FakeClientsRepository(clients: const [
      ClientResponse(id: 1, fullName: 'Irina Sokolova', type: ClientType.BUYER),
    ]);
    Injector.agentsRepository =
        const FakeAgentsRepository([AgentOption(id: 5, fullName: 'Maria Kim')]);
    Injector.propertiesRepository = FakePropertiesRepository(const []);
  });
  tearDown(AppClock.reset);

  group('on the deal', () {
    testWidgets('losing it asks why, then sends the reason and the note',
        (tester) async {
      await _pump(tester, const DealDetailScreen(id: 1));

      await tester.ensureVisible(find.text('Lost'));
      await tester.tap(find.text('Lost'));
      await tester.pumpAndSettle();

      final button = tester.widget<AppFilledButton>(
          find.ancestor(of: _confirm, matching: find.byType(AppFilledButton)));
      expect(button.onPressed, isNull, reason: 'no reason picked yet');

      await _answer(tester, 'Price', note: 'Found it 5% cheaper nearby');

      expect(_repo.moves, [
        (
          1,
          DealStatus.CLOSED_LOST,
          DealLostReason.PRICE,
          'Found it 5% cheaper nearby'
        )
      ]);
      expect(find.text('WHY IT WAS LOST'), findsOneWidget);
      expect(find.text('Found it 5% cheaper nearby'), findsOneWidget);
    });

    testWidgets('walking away from the question leaves the deal as it was',
        (tester) async {
      await _pump(tester, const DealDetailScreen(id: 1));

      await tester.ensureVisible(find.text('Lost'));
      await tester.tap(find.text('Lost'));
      await tester.pumpAndSettle();
      expect(_sheetTitle, findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(_sheetTitle, findsNothing);
      expect(_repo.moves, isEmpty);
      expect(find.text('WHY IT WAS LOST'), findsNothing);
    });

    testWidgets('a lost deal shows why, and an old one says it was not given',
        (tester) async {
      await _pump(tester, const DealDetailScreen(id: 2));
      expect(find.text('WHY IT WAS LOST'), findsOneWidget);
      expect(find.text('Chose another option'), findsOneWidget);
      expect(find.textContaining('two-year instalment'), findsOneWidget);
      expect(find.text('CHOSE_ANOTHER'), findsNothing);

      await _pump(tester, const DealDetailScreen(key: ValueKey(3), id: 3));
      expect(find.text('Not specified'), findsOneWidget);
    });
  });

  testWidgets('a drop on Lost on the board asks why before moving',
      (tester) async {
    await _pump(tester, const DealsScreen());
    await tester.tap(find.byIcon(Icons.view_kanban_outlined));
    await tester.pumpAndSettle();

    final card = find.text('Severny Residence, apartment 84');
    await tester.tap(find.text('Negotiation 1'));
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text('Lost')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_repo.moves, isEmpty, reason: 'nothing moves before the answer');
    await _answer(tester, 'Stopped responding');

    expect(_repo.moves,
        [(1, DealStatus.CLOSED_LOST, DealLostReason.NO_RESPONSE, null)]);
  });

  testWidgets('picking Lost in the form asks why and saves it with the deal',
      (tester) async {
    await _pump(tester, _routed(const DealFormScreen(dealId: 1)));

    await tester.ensureVisible(find.text('Lost'));
    await tester.tap(find.text('Lost'));
    await tester.pumpAndSettle();
    await _answer(tester, 'Financing fell through', note: 'Bank said no');

    expect(
        find.text('Why it was lost: Financing fell through'), findsOneWidget);

    await tester.tap(find.text('Update Deal'));
    await tester.pumpAndSettle();

    expect(_repo.updates, hasLength(1));
    final data = _repo.updates.single.$2;
    expect(data['status'], 'CLOSED_LOST');
    expect(data['lostReason'], 'FINANCING');
    expect(data['lostNote'], 'Bank said no');
  });

  testWidgets('dismissing the question in the form keeps the stage',
      (tester) async {
    await _pump(tester, _routed(const DealFormScreen(dealId: 1)));

    await tester.ensureVisible(find.text('Lost'));
    await tester.tap(find.text('Lost'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update Deal'));
    await tester.pumpAndSettle();
    expect(_repo.updates.single.$2['status'], 'NEGOTIATION');
    expect(_repo.updates.single.$2.containsKey('lostReason'), isFalse);
  });

  forEachAcceptanceCase('the lost-reason sheet and a lost deal',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AppSheetShell(
              title: 'Why was the deal lost?',
              child: LostReasonForm(
                initialReason: DealLostReason.CHOSE_ANOTHER,
                initialNote: 'A long note about a developer offering a '
                    'two-year instalment plan',
                onConfirm: (_) {},
              ),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await expectNoOverflow(
        tester,
        _wrap(DealDetailScreen(key: ValueKey(locale), id: 2)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} after load');
    }
  });
}
