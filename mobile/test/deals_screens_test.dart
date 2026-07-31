import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _deals = [
  DealResponse(
    id: 1,
    title: 'Severny Residence, apartment 84 — a long deal title for wrapping',
    status: DealStatus.CLOSED_WON,
    clientId: 1,
    clientName: 'Irina Alexandrovna Sokolova',
    agentId: 5,
    agentName: 'Maria Kim-Doroshenko',
    propertyTitle: 'Severny Residence, apt 84',
    dealPrice: 12300000,
    budget: 13000000,
    createdAt: DateTime(2026, 7, 18, 9, 12),
    closedAt: DateTime(2026, 7, 30, 12, 30),
  ),
  DealResponse(
    id: 2,
    title: 'Дом в Ромашково',
    status: DealStatus.NEGOTIATION,
    clientId: 2,
    clientName: 'Алексей Петров',
    agentId: 6,
    agentName: 'Андрей Волк',
    dealPrice: 26000000,
    // Untouched for a fortnight — the card must flag it.
    updatedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  const DealResponse(
    id: 3,
    title: 'Офис, Тверская 12',
    status: DealStatus.LEAD,
    clientId: 3,
    clientName: 'ООО «Гранит»',
    agentId: 7,
    dealPrice: 54800000,
  ),
];

void _installFakes() {
  Injector.dealsRepository = FakeDealsRepository(_deals);
  Injector.clientsRepository = FakeClientsRepository(clients: const [
    ClientResponse(id: 1, fullName: 'Irina Sokolova', type: ClientType.BUYER),
  ]);
  Injector.propertiesRepository = FakePropertiesRepository(const []);
}

Widget _wrap(Widget child, {List<DealResponse> deals = const []}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(deals))),
      ],
      child: child,
    );

void main() {
  setUp(_installFakes);

  forEachAcceptanceCase('deals list', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const DealsScreen(), deals: _deals),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('deal detail', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const DealDetailScreen(id: 1)),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('deal form', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const DealFormScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('deals render in ${locale.languageCode}', (tester) async {
      for (final screen in [
        const DealsScreen(),
        const DealDetailScreen(id: 1),
        const DealFormScreen(),
      ]) {
        await expectNoOverflow(
          tester,
          _wrap(screen, deals: _deals),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${screen.runtimeType} in ${locale.languageCode}');
      }
    });
  }

  test('parseStatus maps the query parameter, ignoring junk', () {
    expect(DealsScreen.parseStatus('LEAD'), DealStatus.LEAD);
    expect(DealsScreen.parseStatus('CLOSED_WON'), DealStatus.CLOSED_WON);
    expect(DealsScreen.parseStatus('nonsense'), isNull);
    expect(DealsScreen.parseStatus(null), isNull);
    expect(DealsScreen.parseStatus(''), isNull);
  });

  testWidgets('?status= preselects the stage filter', (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(const DealsScreen(initialStatus: DealStatus.NEGOTIATION),
          deals: _deals),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(DealCard), findsOneWidget);
    expect(find.text('Дом в Ромашково'), findsOneWidget);
  });

  testWidgets('a stale deal is called out, a closed one is not',
      (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(const DealsScreen(), deals: _deals),
      size: const Size(430, 932),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('no activity for'), findsOneWidget);
  });
}
