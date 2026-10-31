import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/deal_checklist_card.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_history_card.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/deal_commission_split_card.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_discussion_card.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deal_deposit_card.dart';
import 'package:real_estate_crm/features/documents/presentation/widgets/deal_documents_card.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/property_expenses_card.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/property_keys_card.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/deal_lease_card.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_card.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/client_offers_card.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/property_offers_card.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/property_open_houses_card.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/client_partners_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_photos_card.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_share_link_card.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/record_tasks_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'more_section_expect.dart';
import 'responsive_harness.dart';

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84 with a deliberately long name',
  address: 'Dmitrovskoye shosse, 107k2',
  city: 'Almaty',
  type: PropertyType.APARTMENT,
  price: 28000000,
  areaSqm: 62,
  rooms: 3,
  floor: 5,
  totalFloors: 24,
  description: 'Bright flat with a finished interior, park views.',
);

const _otherListing = PropertyResponse(
  id: 8,
  title: 'Tverskaya 12, apartment 5',
  address: 'Tverskaya 12',
  price: 31500000,
);

final _deal = DealResponse(
  id: 1,
  title: 'Severny Residence, apartment 84',
  status: DealStatus.NEGOTIATION,
  kind: DealKind.rent,
  clientId: 1,
  clientName: 'Irina Alexandrovna Sokolova',
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  dealPrice: 12300000,
  commissionPercent: 3,
  notes: 'Wants the keys before the end of the month.',
  createdAt: DateTime(2026, 9, 1, 10),
);

const _lostDeal = DealResponse(
  id: 2,
  title: 'Office, Tverskaya 12',
  status: DealStatus.CLOSED_LOST,
  clientId: 1,
  agentId: 5,
  lostReason: DealLostReason.CHOSE_ANOTHER,
  lostNote: 'Went with a developer offering an instalment plan',
);

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  email: 'sokolova@mail.ru',
  type: ClientType.BUYER,
  agentName: 'Maria Kim-Doroshenko',
  wantedCity: 'Almaty',
  budgetMax: 30000000,
  notes: 'Ready to close in August, mortgage pre-approved.',
);

const _seller = ClientResponse(
  id: 2,
  fullName: 'Pavel Sergeevich Orlov',
  phone: '+7 916 555-12-12',
  type: ClientType.SELLER,
);

void _installFakes() {
  Injector.propertiesRepository =
      FakePropertiesRepository(const [_listing, _otherListing]);
  Injector.dealsRepository = FakeDealsRepository([_deal, _lostDeal]);
  Injector.clientsRepository = FakeClientsRepository(
    clients: const [_buyer, _seller],
    matches: const [PropertyMatch(property: _listing)],
  );
  Injector.documentsRepository = FakeDocumentsRepository();
  Injector.fileGateway = FakeFileGateway();
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
        BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(const []))),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      ],
      child: child,
    );

Future<void> _open(WidgetTester tester, Widget screen) async {
  await expectNoOverflow(tester, _wrap(screen),
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

Future<void> _openMoreAndSettle(WidgetTester tester) async {
  await openMore(tester);
  await tester.pumpAndSettle();
}

Finder _anywhere(Type type) => find.byType(type, skipOffstage: false);

void _expectShown(List<Type> types, String why) {
  for (final type in types) {
    expect(_anywhere(type), findsWidgets, reason: '$type $why');
  }
}

void _expectHidden(List<Type> types, String why) {
  for (final type in types) {
    expect(_anywhere(type), findsNothing, reason: '$type $why');
  }
}

/// What the line under "More" says, word for word.
String _summary(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(MoreSection.summaryKey)).data!;

/// Where [finder]'s first match starts down the page, laid out or not.
double _top(Finder finder) =>
    (finder.evaluate().first.renderObject! as RenderBox)
        .localToGlobal(Offset.zero)
        .dy;

Finder _label(String text) => find.text(text, skipOffstage: false);

Widget _section(String memoryKey, {List<String> summary = const []}) =>
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(children: [
          MoreSection(memoryKey: memoryKey, summary: summary, children: const [
            Text('first secondary', maxLines: 1),
            Text('second secondary', maxLines: 1),
          ]),
        ]),
      ),
    );

void main() {
  setUp(() {
    MoreSection.forgetAll();
    _installFakes();
  });

  group('MoreSection', () {
    testWidgets('starts folded behind a 44pt "More" row', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_section('a'));

      expect(find.text('More'), findsOneWidget);
      expect(find.text('first secondary'), findsNothing);
      expect(tester.getSize(find.byKey(MoreSection.toggleKey)).height,
          greaterThanOrEqualTo(44));
      expect(
          tester.getSemantics(find.byKey(MoreSection.toggleKey)),
          isSemantics(
              isButton: true, hasExpandedState: true, isExpanded: false));
      semantics.dispose();
    });

    testWidgets('opens with a tap and folds again with "Show less"',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_section('a'));

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('first secondary'), findsOneWidget);
      expect(find.text('second secondary'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('More'), findsNothing);
      expect(
          tester.getSemantics(find.byKey(MoreSection.toggleKey)),
          isSemantics(
              isButton: true, hasExpandedState: true, isExpanded: true));

      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(find.text('first secondary'), findsNothing);
      expect(find.text('More'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('remembers being open for the same kind of screen only',
        (tester) async {
      await tester.pumpWidget(_section('a'));
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_section('a'));
      expect(find.text('first secondary'), findsOneWidget,
          reason: 'opened once, it stays open for the session');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_section('b'));
      expect(find.text('first secondary'), findsNothing,
          reason: 'another kind of screen keeps its own state');
    });

    testWidgets('names what it holds under the toggle, folded or open',
        (tester) async {
      await tester.pumpWidget(
          _section('a', summary: const ['Offers', 'Partners', 'History']));

      expect(find.text('Offers · Partners · History'), findsOneWidget);
      expect(_top(find.byKey(MoreSection.summaryKey)),
          greaterThan(_top(find.text('More'))),
          reason: 'the names sit under "More", not beside it');

      await tester.tap(find.byKey(MoreSection.summaryKey));
      await tester.pumpAndSettle();
      expect(find.text('first secondary'), findsOneWidget,
          reason: 'the names are part of the toggle');
      expect(find.text('Offers · Partners · History'), findsOneWidget);
    });

    testWidgets('a long list of names stops at two lines', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_section('a',
          summary: List.filled(12, 'A section with a long name')));

      final line = tester.widget<Text>(find.byKey(MoreSection.summaryKey));
      expect(line.maxLines, 2);
      expect(line.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('without names it is the one line it always was',
        (tester) async {
      await tester.pumpWidget(_section('a'));
      expect(find.byKey(MoreSection.summaryKey), findsNothing);
    });

    testWidgets('with nothing to hide it draws nothing', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MoreSection(memoryKey: 'empty', children: [])),
      ));
      expect(find.byKey(MoreSection.toggleKey), findsNothing);
    });
  });

  group('a listing', () {
    const secondary = [
      PropertyMortgageCard,
      PropertyShareLinkCard,
      PropertyKeysCard,
      PropertyOpenHousesCard,
      PropertyExpensesCard,
    ];

    testWidgets('keeps its daily cards on top and the rest under More',
        (tester) async {
      await _open(tester, const PropertyDetailScreen(id: 7));

      _expectShown([PropertyPhotosCard, PropertyOffersCard], 'is daily work');
      expect(find.text('STATUS', skipOffstage: false), findsOneWidget);
      expect(find.text('BUYERS LOOKING FOR THIS', skipOffstage: false),
          findsOneWidget);
      expect(find.text('VIEWINGS', skipOffstage: false), findsOneWidget);
      expect(
          find.byKey(const ValueKey('property-brochure'), skipOffstage: false),
          findsOneWidget);
      _expectHidden(secondary, 'waits under More');
      expect(find.byKey(const ValueKey('change-history'), skipOffstage: false),
          findsNothing);

      await _openMoreAndSettle(tester);

      _expectShown(secondary, 'is one tap away');
      expect(find.byKey(const ValueKey('change-history'), skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('says what waits under More, and only that', (tester) async {
      await _open(tester, const PropertyDetailScreen(id: 7));

      expect(
          _summary(tester),
          'Mortgage · Public link · Keys · Open houses · Expenses · '
          'History of changes');
    });

    testWidgets('opens the next listing the way the last one was left',
        (tester) async {
      await _open(tester, const PropertyDetailScreen(id: 7));
      await _openMoreAndSettle(tester);

      await tester.pumpWidget(const SizedBox());
      await _open(tester, const PropertyDetailScreen(id: 8));
      _expectShown([PropertyKeysCard], 'stays open for listings');

      await tester.pumpWidget(const SizedBox());
      await _open(tester, const ClientDetailScreen(id: 1));
      _expectHidden([ClientPartnersCard], 'a client has its own More');
    });
  });

  group('a deal', () {
    const secondary = [
      DealLeaseCard,
      DealCommissionSplitCard,
      DealDepositCard,
    ];

    testWidgets('keeps the work on top and the paperwork under More',
        (tester) async {
      await _open(tester, const DealDetailScreen(id: 1));

      _expectShown([
        DealChecklistCard,
        RecordTasksCard,
        DealDocumentsCard,
        DealDiscussionCard,
      ], 'is daily work');
      expect(
          find.text('PEOPLE & PROPERTY', skipOffstage: false), findsOneWidget);
      expect(find.text('PIPELINE STAGE', skipOffstage: false), findsOneWidget);
      expect(find.text('NOTES', skipOffstage: false), findsOneWidget);
      _expectHidden(secondary, 'waits under More');
      expect(find.text('COMMISSION', skipOffstage: false), findsNothing);
      expect(find.text('TIMELINE', skipOffstage: false), findsNothing);

      await _openMoreAndSettle(tester);

      _expectShown(secondary, 'is one tap away');
      expect(find.text('COMMISSION', skipOffstage: false), findsOneWidget);
      expect(find.text('TIMELINE', skipOffstage: false), findsOneWidget);
    });

    testWidgets('the checklist a stage move warns about sits under the stage',
        (tester) async {
      await _open(tester, const DealDetailScreen(id: 1));

      final checklist = _anywhere(DealChecklistCard);
      expect(_top(checklist), greaterThan(_top(_label('PIPELINE STAGE'))));
      expect(_top(checklist), lessThan(_top(_label('PEOPLE & PROPERTY'))));
      expect(
          _top(_label('NOTES')), greaterThan(_top(_label('PEOPLE & PROPERTY'))),
          reason: 'the notes follow the people they are about');
      expect(find.byKey(MoreSection.contentKey), findsNothing);
    });

    testWidgets('says what waits under More, and only that', (tester) async {
      await _open(tester, const DealDetailScreen(id: 1));
      expect(
          _summary(tester),
          'Lease · Commission · Commission split · Deposit · Timeline · '
          'History of changes');

      await tester.pumpWidget(const SizedBox());
      await _open(tester, const DealDetailScreen(id: 2));
      expect(_summary(tester),
          'Commission split · Deposit · Timeline · History of changes',
          reason: 'a sale with no commission set has no lease or commission');
    });

    testWidgets('the edit button says what it does', (tester) async {
      await _open(tester, const DealDetailScreen(id: 1));
      expect(find.byTooltip('Edit deal'), findsOneWidget);
    });

    testWidgets('a lost deal says why on top, without More', (tester) async {
      await _open(tester, const DealDetailScreen(id: 2));

      expect(find.text('WHY IT WAS LOST', skipOffstage: false), findsOneWidget);
      expect(
          find.text('Went with a developer offering an instalment plan',
              skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(MoreSection.contentKey), findsNothing);
    });
  });

  group('a client', () {
    const secondary = [ClientOffersCard, ClientPartnersCard];

    testWidgets('keeps who and what on top and the extras under More',
        (tester) async {
      await _open(tester, const ClientDetailScreen(id: 1));

      _expectShown([ClientHistoryCard, RecordTasksCard], 'is daily work');
      expect(find.text('CONTACT', skipOffstage: false), findsOneWidget);
      expect(find.text('DEALS', skipOffstage: false), findsOneWidget);
      _expectHidden(secondary, 'waits under More');

      await _openMoreAndSettle(tester);

      _expectShown(secondary, 'is one tap away');
    });

    testWidgets('what was written about them shows without opening More',
        (tester) async {
      await _open(tester, const ClientDetailScreen(id: 1));

      expect(_label('NOTES'), findsOneWidget);
      expect(_label('Ready to close in August, mortgage pre-approved.'),
          findsOneWidget);
      expect(_top(_label('NOTES')), greaterThan(_top(_label('CONTACT'))));
      expect(_top(_label('NOTES')), lessThan(_top(_label('HISTORY'))),
          reason: 'the notes follow the contact card');
      expect(find.byKey(MoreSection.contentKey), findsNothing);
    });

    testWidgets('a buyer\'s matches show without opening More', (tester) async {
      await _open(tester, const ClientDetailScreen(id: 1));

      expect(_label('MATCHING LISTINGS'), findsOneWidget);
      expect(_label(_listing.title), findsWidgets);
      expect(
          _top(_label('MATCHING LISTINGS')), greaterThan(_top(_label('DEALS'))),
          reason: 'the matches follow the deals');
      expect(find.byKey(MoreSection.contentKey), findsNothing);
    });

    testWidgets('says what waits under More, and only that', (tester) async {
      await _open(tester, const ClientDetailScreen(id: 1));
      expect(_summary(tester), 'Offers · Partners · History of changes');

      await tester.pumpWidget(const SizedBox());
      await _open(tester, const ClientDetailScreen(id: 2));
      expect(_summary(tester), 'Partners · History of changes',
          reason: 'offers are a buyer\'s');
      expect(_label('MATCHING LISTINGS'), findsNothing);
      expect(_label('NOTES'), findsNothing);
    });
  });

  for (final (name, screen) in [
    ('listing', const PropertyDetailScreen(id: 7)),
    ('deal', const DealDetailScreen(id: 1)),
    ('client', const ClientDetailScreen(id: 1)),
  ]) {
    forEachAcceptanceCase('$name detail — More open',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
        tester,
        _wrap(screen),
        size: size,
        brightness: brightness,
        textScale: scale,
      );
      await tester.pumpAndSettle();
      await _openMoreAndSettle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byKey(MoreSection.contentKey), findsOneWidget);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('$name detail — More open in ${locale.languageCode}',
          (tester) async {
        await expectNoOverflow(
          tester,
          _wrap(screen),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale,
        );
        await tester.pumpAndSettle();
        await _openMoreAndSettle(tester);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
