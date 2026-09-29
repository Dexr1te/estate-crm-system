import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';

import 'fakes.dart';

/// The listing being priced: 3 rooms, 94 m², in Almaty.
const priceListing = PropertyResponse(
  id: 1,
  title: 'Dostyk Residence, apartment 210 with a view of the mountains',
  address: 'Dostyk avenue 210, Medeu district',
  city: 'Almaty',
  price: 63168000,
  rooms: 3,
  areaSqm: 94,
);

const priceComparables = [
  PriceComparable(
      id: 2,
      title: 'Abay 2, a long title that has to give way on a narrow phone',
      price: 25000000,
      areaSqm: 50,
      pricePerSqm: 500000,
      status: PropertyStatus.RESERVED),
  PriceComparable(
      id: 3,
      title: 'Sold by a deal',
      price: 27500000,
      areaSqm: 50,
      pricePerSqm: 550000,
      status: PropertyStatus.AVAILABLE,
      sold: true),
];

/// Seven comparables; this listing's 672 000 per m² sits [vs] percent off
/// the active median of 600 000.
PriceInsight priceInsight({double vs = 12, bool lowConfidence = false}) =>
    PriceInsight(
      count: 7,
      lowConfidence: lowConfidence,
      criteria: const PriceInsightCriteria(
          city: 'Almaty', type: PropertyType.APARTMENT, rooms: 3),
      active: const PriceInsightStats(
          count: 5, p25PerSqm: 500000, medianPerSqm: 600000, p75PerSqm: 700000),
      sold: const PriceInsightStats(
          count: 2, medianPerSqm: 500000, medianDaysOnMarket: 30),
      suggested: const PriceInsightRange(
          low: 28500000, median: 33000000, high: 39000000),
      position: PriceInsightPosition(
          pricePerSqm: 600000 * (1 + vs / 100),
          percentile: 80,
          vsMedianPercent: vs),
      comparables: priceComparables,
    );

late FakePropertiesRepository priceRepository;

void installPriceInsight({PriceInsight? detail, PriceInsight? form}) {
  priceRepository = FakePropertiesRepository([priceListing]);
  if (detail != null) priceRepository.priceInsight = detail;
  if (form != null) priceRepository.formInsight = form;
  Injector.propertiesRepository = priceRepository;
  Injector.clientsRepository = FakeClientsRepository();
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget wrapPriceInsight(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(priceRepository)),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      ],
      child: child,
    );
