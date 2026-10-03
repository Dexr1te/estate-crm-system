import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/leases_ending_card.dart';
import 'package:real_estate_crm/features/leases/presentation/bloc/leases_ending_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Thursday 1 October 2026, half past nine.
final leaseNow = DateTime(2026, 10, 1, 9, 30);

DateTime leaseDay(int days) =>
    DateTime(leaseNow.year, leaseNow.month, leaseNow.day + days);

/// A won rent on the checklist fixtures' deal 1, held by their agent, ending
/// in 25 days.
final rentDeal = DealResponse(
  id: 1,
  title: 'Dostyk 5, flat 12',
  status: DealStatus.CLOSED_WON,
  clientId: 1,
  clientName: 'Irina Sokolova',
  agentId: 5,
  agentName: 'Aigul Bekova',
  kind: DealKind.rent,
  monthlyRent: 350000,
  commissionPercent: 100,
  commission: 350000,
  leaseStart: leaseDay(-340),
  leaseEnd: leaseDay(25),
  leaseReminderDaysEffective: 30,
  landlordId: 2,
  landlordName: 'Bolat Ospanov-Nurmukhambetov',
);

/// The running-out list as the server sends it, soonest first.
final endingLeases = [
  LeaseEnding(
    dealId: 11,
    dealTitle: 'Esentai Park, apartment 12 with a deliberately long name',
    propertyTitle: 'Esentai Park, apartment 12 with a deliberately long name',
    monthlyRent: 1500000,
    leaseStart: leaseDay(-365),
    leaseEnd: leaseDay(0),
    tenantId: 1,
    tenantName: 'Irina Sokolova-Bekmukhambetova',
    tenantPhone: '+7 701 555 12 34',
    landlordId: 2,
    landlordName: 'Bolat Ospanov-Nurmukhambetov',
    landlordPhone: '+7 701 555 56 78',
    agentName: 'Aigerim Serikbaykyzy-Nurmukhambetova',
  ),
  LeaseEnding(
    dealId: 12,
    dealTitle: 'Dostyk 5',
    monthlyRent: 300000,
    leaseEnd: leaseDay(1),
    tenantId: 3,
    tenantName: 'Arman Ospanov',
    agentName: 'Daniyar Abenov',
  ),
  LeaseEnding(
    dealId: 13,
    dealTitle: 'Kok-Tobe house',
    monthlyRent: 800000,
    leaseEnd: leaseDay(12),
    tenantId: 4,
    tenantName: 'Dana Ermekova',
    landlordId: 5,
    landlordName: 'Erlan Abenov',
  ),
  LeaseEnding(
    dealId: 14,
    dealTitle: 'Abaya 10',
    monthlyRent: 200000,
    leaseEnd: leaseDay(29),
    tenantId: 6,
    tenantName: 'Madina Aliyeva',
  ),
];

/// The running-out card alone on a page, under a router that names where a
/// tap went.
Widget leasesCardApp(LeasesEndingBloc bloc,
        {Locale locale = const Locale('en'), VoidCallback? onSeeAll}) =>
    MaterialApp.router(
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: BlocProvider.value(
                  value: bloc,
                  child: LeasesEndingCard(onSeeAll: onSeeAll ?? () {}),
                ),
              ),
            ),
          ),
          GoRoute(
              path: '/deals/:id',
              builder: (_, s) =>
                  Scaffold(body: Text('deal ${s.pathParameters['id']}'))),
        ],
      ),
    );
