import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/mandates_ending_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/mandates_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// Thursday 1 October 2026, half past nine.
final mandateNow = DateTime(2026, 10, 1, 9, 30);

/// The agency's running-out list as the server sends it: soonest first, the
/// one that has already ended at the top.
final mandateListings = [
  PropertyResponse(
    id: 11,
    title: 'Esentai Park, apartment 12 with a deliberately long name',
    address: 'Al-Farabi 77',
    status: PropertyStatus.RESERVED,
    price: 28000000,
    agentName: 'Aigerim Serikbaykyzy-Nurmukhambetova',
    mandateType: MandateType.EXCLUSIVE,
    mandateEndDate: DateTime(2026, 9, 24),
  ),
  PropertyResponse(
    id: 12,
    title: 'Dostyk 5',
    address: 'Dostyk 5',
    price: 41000000,
    agentName: 'Daniyar Abenov',
    mandateType: MandateType.OPEN,
    mandateEndDate: DateTime(2026, 10, 1),
  ),
  PropertyResponse(
    id: 13,
    title: 'Kok-Tobe house',
    address: 'Kok-Tobe 5',
    type: PropertyType.HOUSE,
    price: 54000000,
    agentName: 'Madina Nurlanovna',
    mandateType: MandateType.EXCLUSIVE,
    mandateEndDate: DateTime(2026, 10, 6),
  ),
  PropertyResponse(
    id: 14,
    title: 'Abaya 10',
    address: 'Abaya 10',
    price: 19000000,
    mandateType: MandateType.EXCLUSIVE,
    mandateEndDate: DateTime(2026, 10, 15),
  ),
];

FakePropertiesRepository installMandates(List<PropertyResponse> listings,
    {bool fail = false}) {
  final repo = FakePropertiesRepository(listings)
    ..mandatesEnding = listings
    ..failMandates = fail;
  Injector.propertiesRepository = repo;
  return repo;
}

MandatesBloc mandatesBloc() =>
    MandatesBloc(Injector.propertiesRepository)..add(MandatesLoadEvent());

/// The running-out card alone on a page, under a router that names where a
/// tap went.
Widget mandatesCardApp(MandatesBloc bloc,
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
                  child: MandatesEndingCard(onSeeAll: onSeeAll ?? () {}),
                ),
              ),
            ),
          ),
          GoRoute(
              path: '/properties/:id',
              builder: (_, s) =>
                  Scaffold(body: Text('listing ${s.pathParameters['id']}'))),
        ],
      ),
    );
