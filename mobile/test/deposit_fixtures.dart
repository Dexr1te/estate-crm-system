import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/deposits_ending_card.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deposits_ending_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Thursday 1 October 2026, half past nine.
final depositNow = DateTime(2026, 10, 1, 9, 30);

DateTime depositDay(int days) =>
    DateTime(depositNow.year, depositNow.month, depositNow.day + days);

/// The active deposit on the checklist fixtures' deal 1.
DealDeposit activeDepositFixture() => DealDeposit(
      id: 7,
      dealId: 1,
      dealTitle: 'Dostyk 5, flat 12',
      clientName: 'Irina Sokolova',
      propertyId: 3,
      propertyTitle: 'Dostyk 5',
      agentName: 'Aigul Bekova',
      amount: 500000,
      receivedOn: depositDay(-9),
      holdUntil: depositDay(5),
      holder: DepositHolder.NOTARY,
      note: 'Receipt 12, signed at the notary on Abaya',
    );

/// One that ended before it, refunded.
DealDeposit pastDepositFixture() => DealDeposit(
      id: 6,
      dealId: 1,
      amount: 200000,
      receivedOn: depositDay(-40),
      holdUntil: depositDay(-20),
      active: false,
      outcome: DepositOutcome.REFUNDED,
      closedOn: depositDay(-25),
    );

/// The running-out list as the server sends it: soonest first, the one that
/// has already ended at the top.
final endingDeposits = [
  DealDeposit(
    id: 21,
    dealId: 11,
    dealTitle: 'Esentai Park, apartment 12 with a deliberately long name',
    propertyTitle: 'Esentai Park, apartment 12 with a deliberately long name',
    clientName: 'Irina Sokolova-Bekmukhambetova',
    agentName: 'Aigerim Serikbaykyzy-Nurmukhambetova',
    amount: 1500000,
    receivedOn: depositDay(-30),
    holdUntil: depositDay(-3),
  ),
  DealDeposit(
    id: 22,
    dealId: 12,
    dealTitle: 'Dostyk 5',
    clientName: 'Arman Ospanov',
    agentName: 'Daniyar Abenov',
    amount: 300000,
    receivedOn: depositDay(-10),
    holdUntil: depositDay(0),
  ),
  DealDeposit(
    id: 23,
    dealId: 13,
    dealTitle: 'Kok-Tobe house',
    amount: 800000,
    receivedOn: depositDay(-10),
    holdUntil: depositDay(4),
  ),
  DealDeposit(
    id: 24,
    dealId: 14,
    dealTitle: 'Abaya 10',
    amount: 100000,
    receivedOn: depositDay(-2),
    holdUntil: depositDay(7),
  ),
];

/// The running-out card alone on a page, under a router that names where a
/// tap went.
Widget depositsCardApp(DepositsEndingBloc bloc,
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
                  child: DepositsEndingCard(onSeeAll: onSeeAll ?? () {}),
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
