import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _now = DateTime(2026, 3, 12, 9, 0);

final _deals = [
  DealResponse(
    id: 1,
    title: 'Severny Residence, apartment 84 — a long deal title for wrapping',
    status: DealStatus.LEAD,
    clientId: 1,
    clientName: 'Irina Alexandrovna Sokolova',
    agentId: 5,
    agentName: 'Maria Kim-Doroshenko',
    dealPrice: 12300000,
    createdAt: _now.subtract(const Duration(days: 21)),
  ),
  const DealResponse(
    id: 2,
    title: 'Дом в Ромашково',
    status: DealStatus.NEGOTIATION,
    clientId: 2,
    clientName: 'Алексей Петров',
    agentId: 6,
    dealPrice: 26000000,
  ),
  const DealResponse(
    id: 3,
    title: 'Офис, Тверская 12',
    status: DealStatus.CLOSED_WON,
    clientId: 3,
    clientName: 'ООО «Гранит»',
    agentId: 7,
    dealPrice: 54800000,
  ),
];

/// Records the moves the board asks for, and answers them, which the shared
/// fake refuses to do.
class _MovableDeals extends FakeDealsRepository {
  final moves = <(int, DealStatus)>[];

  _MovableDeals(super.deals);

  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status,
      {DealLostReason? lostReason, String? lostNote}) async {
    moves.add((id, status));
    final i = deals.indexWhere((d) => d.id == id);
    return deals[i] = deals[i].copyWith(status: status);
  }
}

_MovableDeals _repo() => _MovableDeals(List.of(_deals));

Widget _wrap(_MovableDeals repo, {DealStatus? initialStatus}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(repo)),
      ],
      child: DealsScreen(initialStatus: initialStatus),
    );

final _boardToggle = find.byIcon(Icons.view_kanban_outlined);
final _listToggle = find.byIcon(Icons.view_agenda_outlined);

Future<void> _openBoard(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(_boardToggle);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  forEachAcceptanceCase('deals board', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(_repo()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await _openBoard(tester);
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the board renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(_repo()),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await _openBoard(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the board opens on the stage the list was filtered to',
      (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(_repo(), initialStatus: DealStatus.NEGOTIATION),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _openBoard(tester);

    expect(find.text('Дом в Ромашково'), findsOneWidget);
    expect(find.text('Офис, Тверская 12'), findsNothing);
  });

  testWidgets('a stage pill swipes the board to that column', (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(_repo()),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _openBoard(tester);

    expect(find.text('Дом в Ромашково'), findsNothing);

    await tester.tap(find.text('Negotiation 1'));
    await tester.pumpAndSettle();

    expect(find.text('Дом в Ромашково'), findsOneWidget);
  });

  testWidgets('dropping a card on a stage moves the deal there',
      (tester) async {
    final repo = _repo();
    await expectNoOverflow(
      tester,
      _wrap(repo),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _openBoard(tester);

    final card = find.text(
        'Severny Residence, apartment 84 — a long deal title for wrapping');
    expect(card, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));

    // The rail only exists while a card is lifted.
    final slot = find.text('Negotiation');
    expect(slot, findsOneWidget);

    await gesture.moveTo(tester.getCenter(slot));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(repo.moves, [(1, DealStatus.NEGOTIATION)]);
    // The card follows the drop before the reload lands, then stays put — and
    // the stage pill counts it under its new stage.
    expect(card, findsNothing);
    await tester.tap(find.text('Negotiation 2'));
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);
  });

  testWidgets('the toggle goes back to the list', (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(_repo()),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _openBoard(tester);
    expect(_listToggle, findsOneWidget);

    await tester.tap(_listToggle);
    await tester.pumpAndSettle();

    // Back to one scroll of everything, not one column.
    expect(_boardToggle, findsOneWidget);
    expect(find.text('Дом в Ромашково'), findsOneWidget);
    expect(find.text('Офис, Тверская 12'), findsOneWidget);
  });
}
