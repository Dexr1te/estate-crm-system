import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _client = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  email: 'sokolova@mail.ru',
  type: ClientType.BUYER,
  agentName: 'Maria Kim-Doroshenko',
  notes:
      'Looking for a 2-room flat up to 13M, north of the city. Ready to close '
      'in August, mortgage pre-approved.',
);

final _deals = [
  const DealResponse(
      id: 1,
      title: 'Severny Residence, apt 84',
      status: DealStatus.CLOSED_WON,
      clientId: 1,
      agentId: 5,
      dealPrice: 12300000,
      propertyTitle: 'Severny Residence, apt 84'),
  const DealResponse(
      id: 2,
      title: 'Romashkovo house',
      status: DealStatus.NEGOTIATION,
      clientId: 1,
      agentId: 5,
      dealPrice: 12500000,
      propertyTitle: 'Romashkovo house'),
];

void _installFakes() {
  Injector.clientsRepository = FakeClientsRepository(clients: const [_client]);
  Injector.dealsRepository = FakeDealsRepository(_deals);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) =>
                ClientsBloc(FakeClientsRepository(clients: const []))),
      ],
      child: child,
    );

void main() {
  setUp(_installFakes);

  forEachAcceptanceCase('client detail',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const ClientDetailScreen(id: 1)),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('client form — new',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const ClientFormScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('client detail renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const ClientDetailScreen(id: 1)),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('client form renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const ClientFormScreen()),
        size: const Size(320, 568),
        brightness: Brightness.light,
        textScale: 1.3,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
