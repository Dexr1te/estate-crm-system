import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _size = Size(390, 844);

class _GatedClients extends FakeClientsRepository {
  final _gate = Completer<List<ClientResponse>>();
  void release() => _gate.complete(const [
        ClientResponse(id: 1, fullName: 'A'),
        ClientResponse(id: 2, fullName: 'B'),
      ]);

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) =>
      _gate.future;

  @override
  Future<List<ClientListItem>> getClientsWithDetails() async => const [];
}

class _GatedDeals extends FakeDealsRepository {
  _GatedDeals() : super(const []);
  final _gate = Completer<List<DealResponse>>();
  void release() =>
      _gate.complete(const [DealResponse(id: 1, clientId: 1, agentId: 1)]);

  @override
  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status}) =>
      _gate.future;
}

class _GatedProperties extends FakePropertiesRepository {
  _GatedProperties() : super(const []);
  final _gate = Completer<PagedResponse<PropertyResponse>>();
  void release() => _gate.complete(const PagedResponse(
        content: [PropertyResponse(id: 1, title: 'A')],
        page: 0,
        totalPages: 1,
        totalElements: 1,
        isLast: true,
      ));

  @override
  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int size = 20,
  }) =>
      _gate.future;
}

Future<void> _expectHeaderHolds(
  WidgetTester tester,
  Widget screen,
  void Function() release, {
  double textScale = 1.0,
}) async {
  await expectNoOverflow(
    tester,
    screen,
    size: _size,
    brightness: Brightness.light,
    textScale: textScale,
  );

  final loading = tester.getRect(find.byType(AppHeaderAction));
  release();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final loaded = tester.getRect(find.byType(AppHeaderAction));

  expect(loaded.top, moreOrLessEquals(loading.top, epsilon: 0.5),
      reason: 'the header must not move when the counter subtitle arrives — '
          'it drags the search field, the pills and the list down with it');
}

void main() {
  setUp(() {
    Injector.clientsRepository = FakeClientsRepository(clients: const []);
    Injector.propertiesRepository = FakePropertiesRepository(const []);
  });

  testWidgets('clients header holds its place through loading', (tester) async {
    final repo = _GatedClients();
    await _expectHeaderHolds(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) => ClientsBloc(repo)..add(ClientsLoadEvent())),
        ],
        child: const ClientsScreen(),
      ),
      repo.release,
    );
  });

  testWidgets('deals header holds its place through loading', (tester) async {
    final repo = _GatedDeals();
    await _expectHeaderHolds(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(create: (_) => DealsBloc(repo)..add(DealsLoadEvent())),
        ],
        child: const DealsScreen(),
      ),
      repo.release,
    );
  });

  testWidgets('properties header holds its place through loading',
      (tester) async {
    final repo = _GatedProperties();
    await _expectHeaderHolds(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) => PropertiesBloc(repo)..add(PropertiesLoadEvent())),
        ],
        child: const PropertiesScreen(),
      ),
      repo.release,
    );
  });

  testWidgets('the reserved line scales with the text size too',
      (tester) async {
    final repo = _GatedClients();
    await _expectHeaderHolds(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) => ClientsBloc(repo)..add(ClientsLoadEvent())),
        ],
        child: const ClientsScreen(),
      ),
      repo.release,
      textScale: 1.3,
    );
  });

  testWidgets('a title with no subtitle carries no empty line', (tester) async {
    await expectNoOverflow(
      tester,
      const Scaffold(
        body: Column(
            mainAxisSize: MainAxisSize.min, children: [ScreenTitle('Admin')]),
      ),
      size: _size,
      brightness: Brightness.light,
      textScale: 1.0,
    );
    final plain = tester.getRect(find.byType(ScreenTitle)).height;

    await expectNoOverflow(
      tester,
      const Scaffold(
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          ScreenTitle('Admin', reserveSubtitle: true),
        ]),
      ),
      size: _size,
      brightness: Brightness.light,
      textScale: 1.0,
    );
    final reserved = tester.getRect(find.byType(ScreenTitle)).height;

    expect(reserved, greaterThan(plain));
  });
}
