import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/attention_card.dart';
import 'package:real_estate_crm/features/search/presentation/widgets/search_result_tile.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _rent = DealResponse(
  id: 4,
  title: 'Abay 10, apartment 12',
  status: DealStatus.NEGOTIATION,
  clientId: 1,
  agentId: 5,
  kind: DealKind.rent,
  budget: 300000,
  monthlyRent: 250000,
);

const _bare = DealResponse(
  id: 5,
  title: 'Romashkovo house',
  status: DealStatus.LEAD,
  clientId: 1,
  agentId: 5,
);

Future<void> _show(WidgetTester tester, Widget child) => expectNoOverflow(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) =>
                  ClientsBloc(FakeClientsRepository(clients: const []))),
        ],
        child: Scaffold(body: child),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );

void main() {
  testWidgets('a rent in search reads as its monthly rent', (tester) async {
    await _show(tester, DealResultTile(deal: _rent, onTap: () {}));

    expect(find.text('\$250,000 a month'), findsOneWidget);
    expect(find.textContaining('300,000'), findsNothing);
  });

  testWidgets('a deal with no amount in search shows none, not \$0',
      (tester) async {
    await _show(tester, DealResultTile(deal: _bare, onTap: () {}));

    expect(find.textContaining('\$0'), findsNothing);
  });

  testWidgets('a rent that needs attention reads as its monthly rent',
      (tester) async {
    await _show(
        tester, AttentionRow(item: const StaleDeal(_rent, 12), onTap: () {}));

    expect(find.text('\$250,000 a month'), findsOneWidget);
  });

  testWidgets('a client\'s rent reads as its monthly rent', (tester) async {
    Injector.clientsRepository = FakeClientsRepository(clients: const [
      ClientResponse(
          id: 1, fullName: 'Aigerim Sadykova', phone: '+7 701 555 0101'),
    ]);
    Injector.dealsRepository = FakeDealsRepository(const [_rent]);

    await _show(tester, const ClientDetailScreen(id: 1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(_rent.title), 200,
        scrollable: find.byType(Scrollable).first);

    expect(find.text('\$250,000 a month'), findsOneWidget);
  });
}
