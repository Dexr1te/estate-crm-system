import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/goal/goal_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/goal_ring_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/pipeline_card.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// What every screen shows while it waits.
///
/// A skeleton earns its place by being the shape of what is coming: the same
/// cards, in the same order, at the same heights. Anything less is a grey slab
/// that moves the whole page the moment the data lands — so these tests check
/// for the pieces of the layout, not merely that a shimmer is on screen, and
/// they run the acceptance matrix because a skeleton is a layout too and can
/// overflow like any other.
///
/// Each case pumps exactly one frame: the fakes answer on the next microtask,
/// so the first frame is the loading state and nothing else.

/// A repository that is still thinking.
///
/// The screens answer from their fakes on the next microtask, which the first
/// pump already flushes — so a test that wants to look at the waiting state has
/// to hold the answer back. These never arrive, which is the point: the
/// skeleton stays on screen for as long as the test needs it.
final Future<Never> _stillLoading = Completer<Never>().future;

class _StalledDashboard extends FakeDashboardRepository {
  _StalledDashboard()
      : super(const DashboardSummary(
          totalDeals: 0,
          activeDeals: 0,
          closedDeals: 0,
          totalClients: 0,
          upcomingMeetings: 0,
        ));

  @override
  Future<DashboardSummary> getDashboardSummary() => _stillLoading;
}

class _StalledMeetings extends FakeMeetingsRepository {
  _StalledMeetings() : super(const []);

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) => _stillLoading;
  @override
  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() => _stillLoading;
}

class _StalledDeals extends FakeDealsRepository {
  _StalledDeals() : super(const []);

  @override
  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status}) =>
      _stillLoading;
}

class _StalledClients extends FakeClientsRepository {
  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) =>
      _stillLoading;

  @override
  Future<List<ClientListItem>> getClientsWithDetails() => _stillLoading;
}

class _StalledProperties extends FakePropertiesRepository {
  _StalledProperties() : super(const []);

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
      _stillLoading;
}

Widget _dashboard() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => GoalBloc()),
        BlocProvider(
          create: (_) => DashboardBloc(
            _StalledDashboard(),
            _StalledMeetings(),
            _StalledDeals(),
          ),
        ),
      ],
      child: const DashboardScreen(),
    );

Widget _meetings() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => MeetingsBloc(_StalledMeetings())),
      ],
      child: const MeetingsScreen(),
    );

Widget _clients() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(_StalledClients())),
      ],
      child: const ClientsScreen(),
    );

Widget _properties() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_StalledProperties())),
      ],
      child: const PropertiesScreen(),
    );

Widget _deals() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(_StalledDeals())),
      ],
      child: const DealsScreen(),
    );

void _installFakes() {
  Injector.meetingsRepository = _StalledMeetings();
  Injector.clientsRepository = _StalledClients();
  Injector.dealsRepository = _StalledDeals();
}

void main() {
  setUp(_installFakes);

  forEachAcceptanceCase('the dashboard skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _dashboard(),
        size: size, brightness: brightness, textScale: scale);
  });

  testWidgets('the dashboard skeleton is the dashboard, card for card',
      (tester) async {
    await expectNoOverflow(tester, _dashboard(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);

    expect(find.byType(ShimmerHeroCard), findsOneWidget,
        reason: 'the next meeting arrives in a hero with two buttons');
    expect(find.byType(GoalRingCardBone), findsOneWidget);
    expect(find.byType(ShimmerMetricsCard), findsOneWidget);
    expect(find.byType(PipelineCardBone), findsOneWidget);
    expect(find.byType(ShimmerSectionHeader), findsOneWidget);
    expect(find.byType(MeetingRowBone), findsWidgets);
  });

  forEachAcceptanceCase('the meetings skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _meetings(),
        size: size, brightness: brightness, textScale: scale);
  });

  testWidgets('the meetings skeleton keeps its day label and rows',
      (tester) async {
    await expectNoOverflow(tester, _meetings(),
        size: const Size(390, 844),
        brightness: Brightness.dark,
        textScale: 1.0);

    expect(find.byType(ShimmerHeroCard), findsOneWidget);
    expect(find.byType(MeetingRowBone), findsWidgets);
  });

  forEachAcceptanceCase('the clients skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _clients(),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('the properties skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _properties(),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('the deals skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _deals(),
        size: size, brightness: brightness, textScale: scale);
  });

  testWidgets('every list waits as the card it is about to show',
      (tester) async {
    for (final (screen, bone) in [
      (_clients(), ClientCardBone),
      (_properties(), PropertyCardBone),
      (_deals(), DealCardBone),
    ]) {
      await expectNoOverflow(tester, screen,
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);

      expect(find.byType(bone), findsWidgets, reason: 'should wait as $bone');
      // The bones are drawn inside cards, not as one slab per row.
      expect(find.byType(ShimmerCard), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
  });
}
