import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/cold_clients_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/going_cold_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// Tuesday mid-morning, so "tomorrow at ten" is an ordinary Wednesday.
final coldNow = DateTime(2026, 3, 10, 9, 30);

/// Clients going cold, most valuable first — the order the server sends. At
/// 7 days all five, at 14 the first four, at 30 only Aleksandr and Madina.
final coldClients = [
  ColdClient(
    id: 1,
    fullName: 'Aigerim Serikbaykyzy',
    phone: '+7 701 111 22 33',
    type: ClientType.BUYER,
    agentName: 'Aigul Bekova',
    lastContactAt: coldNow.subtract(const Duration(days: 23)),
    silentDays: 23,
    reasons: const [
      ColdReason(
          code: ColdReasonCode.openDeal,
          dealTitle: 'Flat on Dostyk',
          dealStatus: DealStatus.NEGOTIATION),
      ColdReason(code: ColdReasonCode.matches, matchCount: 4),
    ],
    nextStep: ColdNextStep.pushDeal,
  ),
  const ColdClient(
    id: 2,
    fullName: 'Aleksandr Konstantinovich Vishnevsky-Ponomaryov',
    phone: '+7 702 000 00 00',
    type: ClientType.SELLER,
    silentDays: 40,
    reasons: [
      ColdReason(
          code: ColdReasonCode.openDeal,
          dealTitle: 'House in Talgar',
          dealStatus: DealStatus.LEAD),
    ],
    nextStep: ColdNextStep.firstCall,
  ),
  ColdClient(
    id: 3,
    fullName: 'Daniyar Abenov',
    type: ClientType.BUYER,
    lastContactAt: coldNow.subtract(const Duration(days: 19)),
    silentDays: 19,
    reasons: const [ColdReason(code: ColdReasonCode.matches, matchCount: 1)],
    nextStep: ColdNextStep.sendMatches,
  ),
  ColdClient(
    id: 4,
    fullName: 'Madina Nurlanovna',
    phone: '+7 705 555 55 55',
    type: ClientType.BUYER,
    lastContactAt: coldNow.subtract(const Duration(days: 31)),
    silentDays: 31,
    reasons: const [ColdReason(code: ColdReasonCode.newLead)],
    nextStep: ColdNextStep.checkIn,
  ),
  ColdClient(
    id: 5,
    fullName: 'Timur Aliev',
    phone: '+7 700 123 45 67',
    type: ClientType.BUYER,
    lastContactAt: coldNow.subtract(const Duration(days: 8)),
    silentDays: 8,
    reasons: const [ColdReason(code: ColdReasonCode.newLead)],
    nextStep: ColdNextStep.checkIn,
  ),
];

/// The going-cold card alone on a page, under a router that names where a
/// tap went.
Widget coldCardApp(ColdClientsBloc bloc,
        {Locale locale = const Locale('en'), int? total}) =>
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
                  child: GoingColdCard(onSeeAll: () {}, total: total),
                ),
              ),
            ),
          ),
          GoRoute(
              path: '/clients/cold',
              builder: (_, __) => const ColdClientsScreen()),
          GoRoute(
              path: '/clients/:id',
              builder: (_, s) =>
                  Scaffold(body: Text('client ${s.pathParameters['id']}'))),
        ],
      ),
    );

ColdClientsBloc coldBloc() =>
    ColdClientsBloc(Injector.coldClientsRepository, Injector.tasksRepository)
      ..add(ColdClientsLoadEvent());

void installCold(List<ColdClient> clients) {
  Injector.coldClientsRepository = FakeColdClientsRepository(clients);
  Injector.tasksRepository = FakeTasksRepository();
}
