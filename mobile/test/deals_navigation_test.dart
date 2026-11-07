import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// The deals list and a deal opened from it, inside the real tab shell: what
/// the list still shows when the deal closes.

const _agent = AuthResponse(
    userId: 5,
    fullName: 'Aigul Bekova',
    email: 'aigul@estate.crm',
    role: Role.AGENT,
    teamId: 1,
    teamName: 'Downtown desk');

/// Answers moves and counts reads; [deals] is what the server holds now.
class _Deals extends FakeDealsRepository {
  _Deals()
      : super([
          const DealResponse(
            id: 1,
            title: 'Dostyk 5, flat 12',
            status: DealStatus.NEGOTIATION,
            clientId: 1,
            clientName: 'Irina Sokolova',
            agentId: 5,
            dealPrice: 42000000,
            checklistDone: 0,
            checklistTotal: 1,
          ),
          const DealResponse(
            id: 2,
            title: 'Abay 10, office',
            status: DealStatus.LEAD,
            clientId: 2,
            clientName: 'Timur Aliev',
            agentId: 5,
            dealPrice: 18000000,
          ),
        ]);

  int reads = 0;

  /// What a status move throws instead of being answered.
  Object? refuseMoves;

  @override
  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status}) {
    reads++;
    return super.getDeals(agentId: agentId, status: status);
  }

  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status,
      {DealLostReason? lostReason, String? lostNote}) async {
    if (refuseMoves case final failure?) throw failure;
    final i = deals.indexWhere((d) => d.id == id);
    return deals[i] = deals[i].copyWith(status: status);
  }
}

void main() {
  late _Deals deals;
  late GoRouter router;

  setUp(() {
    AppClock.freeze(DateTime(2026, 9, 29, 10));
    deals = _Deals();
    Injector.dealsRepository = deals;
  });
  tearDown(() {
    AppClock.reset();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final auth = AuthBloc(FakeAuthRepository(user: _agent))
      ..add(AuthCheckEvent());
    addTearDown(auth.close);
    router = createRouter(auth);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider(
          create: (_) => DashboardBloc(
            FakeDashboardRepository(const DashboardSummary()),
            FakeMeetingsRepository(const []),
            FakeDealsRepository(const []),
          ),
        ),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
        BlocProvider(create: (_) => DealsBloc(deals)),
        BlocProvider(
            create: (_) => MeetingsBloc(FakeMeetingsRepository(const []))),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openDeal(WidgetTester tester, String title) async {
    await tester.tap(find.widgetWithText(DealCard, title));
    await tester.pumpAndSettle();
    expect(find.byType(DealDetailScreen), findsOneWidget);
  }

  Future<void> closeDeal(WidgetTester tester) async {
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(DealDetailScreen), findsNothing);
  }

  testWidgets('the stage filter the list came with is still on after a deal',
      (tester) async {
    await pumpApp(tester);
    router.go('/deals?status=NEGOTIATION');
    await tester.pumpAndSettle();
    expect(find.byType(DealCard), findsOneWidget);

    await openDeal(tester, 'Dostyk 5, flat 12');
    await closeDeal(tester);

    expect(find.byType(DealCard), findsOneWidget);
    expect(find.text('Abay 10, office'), findsNothing,
        reason: 'the filter must not fall back to "All"');

    router.go('/deals');
    await tester.pumpAndSettle();
    expect(find.byType(DealCard), findsNWidgets(2),
        reason: 'going to the plain list still shows them all');
  });

  testWidgets('a refused move says so once, with the Deals tab built too',
      (tester) async {
    await pumpApp(tester);
    router.go('/deals');
    await tester.pumpAndSettle();
    await openDeal(tester, 'Dostyk 5, flat 12');

    final lead = find.widgetWithText(FilterPill, 'Lead');
    await tester.ensureVisible(lead);
    await tester.tap(lead);
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(tester.element(lead)).clearSnackBars();
    await tester.pumpAndSettle();

    deals.refuseMoves = StateError('offline');
    await tester.tap(find.widgetWithText(FilterPill, 'Negotiation'));
    await tester.pumpAndSettle();

    const said = 'Something went wrong. Please try again.';
    expect(find.text(said), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(said), findsNothing,
        reason: 'no second copy waits behind the first');
  });
}
