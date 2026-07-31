import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _clients = [
  const ClientResponse(
    id: 1,
    fullName: 'Irina Alexandrovna Sokolova',
    phone: '+7 916 220-84-11',
    email: 'sokolova@mail.ru',
    type: ClientType.BUYER,
    agentName: 'Maria Kim-Doroshenko',
  ),
  const ClientResponse(
    id: 2,
    fullName: 'Алексей Петров',
    phone: '+7 903 118-02-40',
    type: ClientType.SELLER,
    agentName: 'Андрей Волк',
  ),
  const ClientResponse(
      id: 3, fullName: 'Семья Дорошенко', type: ClientType.BUYER),
];

final _details = [
  const ClientListItem(
      id: 1,
      fullName: 'Irina Alexandrovna Sokolova',
      status: DealStatus.CLOSED_WON,
      budget: 12300000,
      propertyTitle: 'Severny Residence, apt 84'),
  const ClientListItem(
      id: 1,
      fullName: 'Irina Alexandrovna Sokolova',
      status: DealStatus.NEGOTIATION,
      budget: 12500000,
      propertyTitle: 'Romashkovo house'),
  const ClientListItem(
      id: 2,
      fullName: 'Алексей Петров',
      status: DealStatus.NEGOTIATION,
      budget: 18000000),
];

Widget _clientsScreen({
  List<ClientResponse> clients = const [],
  List<ClientListItem> details = const [],
}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
          create: (_) => ClientsBloc(
            FakeClientsRepository(clients: clients, listItems: details),
          ),
        ),
      ],
      child: const ClientsScreen(),
    );

void main() {
  forEachAcceptanceCase('clients list',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _clientsScreen(clients: _clients, details: _details),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('clients list — empty',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _clientsScreen(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('clients list renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _clientsScreen(clients: _clients, details: _details),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  test('ClientSummary.join folds detail rows into one row per client', () {
    final joined = ClientSummary.join(_clients, _details);

    expect(joined, hasLength(3));

    final irina = joined.firstWhere((c) => c.id == 1);
    expect(irina.dealCount, 2);
    expect(irina.totalBudget, 24800000);
    expect(irina.type, ClientType.BUYER);
    expect(irina.agentName, 'Maria Kim-Doroshenko');
    expect(irina.status, DealStatus.CLOSED_WON);

    final family = joined.firstWhere((c) => c.id == 3);
    expect(family.dealCount, 0);
    expect(family.totalBudget, 0);
    expect(family.status, isNull);
  });

  test('ClientSummary.matches searches name, email and phone', () {
    final irina = ClientSummary.join(_clients, _details).first;
    expect(irina.matches('sokolova'), isTrue);
    expect(irina.matches('SOKOLOVA@MAIL'.toLowerCase()), isTrue);
    expect(irina.matches('220-84'), isTrue);
    expect(irina.matches('petrov'), isFalse);
  });

  testWidgets('type filter narrows the list', (tester) async {
    await expectNoOverflow(
      tester,
      _clientsScreen(clients: _clients, details: _details),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsNWidgets(3));

    await tester.tap(find.text('Sellers'));
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsOneWidget);
    expect(find.text('Алексей Петров'), findsOneWidget);
  });
}
