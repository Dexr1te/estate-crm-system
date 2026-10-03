import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';
import 'package:real_estate_crm/features/offers/presentation/screens/offer_screen.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/client_offers_card.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_sheets.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/property_offers_card.dart';

import 'fakes.dart';
import 'offer_fakes.dart';
import 'responsive_harness.dart';

/// Offers on a listing: the listing's card, highest first, with the accepted
/// one and the backups told apart; the buyer's card; one offer with its
/// negotiation and the decisions on it; and the sheets that record an offer
/// and put a new figure on the table.

final _now = DateTime(2026, 10, 4, 12, 30);

PropertyOffer _offer({
  int id = 1,
  int propertyId = 7,
  int clientId = 21,
  double amount = 26500000,
  OfferStatus status = OfferStatus.isNew,
  OfferParty lastParty = OfferParty.buyer,
  bool canEdit = true,
  bool clientVisible = true,
  DateTime? expiresOn,
  List<OfferStep>? history,
}) =>
    PropertyOffer(
      id: id,
      propertyId: propertyId,
      propertyTitle: 'Severny Residence, apartment 84 on the twelfth floor',
      propertyAddress: 'Dostyk avenue 5, Medeu district, Almaty',
      propertyPrice: 28000000,
      clientId: clientId,
      clientVisible: clientVisible,
      clientName: clientVisible
          ? 'Saule Nurlanovna Abdrakhmanova-Seitkali $clientId'
          : null,
      clientAgentName: 'Timur Aliev-Konstantinopolsky',
      agentId: 5,
      agentName: 'Aigul Bekova',
      amount: amount,
      lastParty: lastParty,
      note: 'Cash buyer, can sign this week, asks to leave the kitchen and '
          'the wardrobes in the bedrooms.',
      expiresOn: expiresOn ?? DateTime(2026, 10, 10),
      status: status,
      canEdit: canEdit,
      history: history ??
          [
            OfferStep(
              id: 101,
              action: OfferAction.offered,
              amount: 25000000,
              party: OfferParty.buyer,
              actorName: 'Aigul Bekova',
              createdAt: DateTime(2026, 10, 1, 10),
            ),
            OfferStep(
              id: 102,
              action: OfferAction.countered,
              amount: amount,
              party: OfferParty.seller,
              note: 'The seller will not go below this.',
              actorName: 'Marat Manager',
              createdAt: DateTime(2026, 10, 2, 15),
            ),
          ],
    );

late FakeOffersRepository _repo;

Widget _page(Widget child) => Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [child]),
    );

Widget _sheet(Widget form) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: AppSheetShell(title: 'Offer', child: form),
        ),
      ),
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  await expectNoOverflow(tester, child,
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeOffersRepository(offers: [
      _offer(),
      _offer(
          id: 2,
          clientId: 22,
          amount: 27000000,
          status: OfferStatus.accepted,
          history: const []),
      _offer(
          id: 3,
          clientId: 23,
          amount: 24000000,
          status: OfferStatus.rejected,
          history: const []),
      _offer(
          id: 4,
          clientId: 21,
          propertyId: 8,
          amount: 31000000,
          status: OfferStatus.expired,
          history: const []),
    ]);
    Injector.offersRepository = _repo;
  });
  tearDown(AppClock.reset);

  group('layout', () {
    forEachAcceptanceCase('offer screen',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const OfferScreen(id: 1),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('listing card',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _page(const PropertyOffersCard(propertyId: 7)),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('buyer card',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _page(const ClientOffersCard(clientId: 21)),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('record sheet',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _sheet(const RecordOfferForm(propertyId: 7)),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('counter sheet',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _sheet(CounterOfferForm(offer: _offer())),
          size: size, brightness: brightness, textScale: scale);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('everything renders in ${locale.languageCode}',
          (tester) async {
        for (final child in [
          const OfferScreen(id: 1),
          const OfferScreen(id: 2),
          _page(const PropertyOffersCard(propertyId: 7)),
          _page(const ClientOffersCard(clientId: 21)),
          _sheet(const RecordOfferForm(propertyId: 7)),
          _sheet(CounterOfferForm(offer: _offer())),
        ]) {
          await expectNoOverflow(tester, child,
              size: const Size(320, 568),
              brightness: Brightness.dark,
              textScale: 1.5,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('on the listing', () {
    testWidgets('the ones in play highest first, then the closed ones',
        (tester) async {
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));

      final accepted = find.byKey(const ValueKey('offer-row-2'));
      final open = find.byKey(const ValueKey('offer-row-1'));
      final rejected = find.byKey(const ValueKey('offer-row-3'));
      expect(
          tester.getTopLeft(accepted).dy, lessThan(tester.getTopLeft(open).dy));
      expect(
          tester.getTopLeft(open).dy, lessThan(tester.getTopLeft(rejected).dy));
      expect(find.text('Closed'), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-row-4')), findsNothing,
          reason: "another listing's offer");
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text(formatPrice(27000000)), findsOneWidget);
    });

    testWidgets('an open offer waiting behind an accepted one says so',
        (tester) async {
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));

      expect(find.byKey(const ValueKey('offer-backup-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-backup-2')), findsNothing);
      expect(find.text('Another offer is accepted; this one waits as a backup'),
          findsOneWidget);
    });

    testWidgets('each offer against the asking price, and its deadline',
        (tester) async {
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));

      expect(
          find.text(
              'Saule Nurlanovna Abdrakhmanova-Seitkali 21 · 95% of asking'),
          findsOneWidget);
      expect(find.text('Valid until Oct 10'), findsOneWidget,
          reason: 'only an open offer shows how long it stands');
    });

    testWidgets("a colleague's buyer is named by the colleague",
        (tester) async {
      _repo.offers
        ..clear()
        ..add(_offer(clientVisible: false));
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));

      expect(find.textContaining('Buyer of Timur Aliev-Konstantinopolsky'),
          findsOneWidget);
      expect(find.textContaining('Saule'), findsNothing);
    });

    testWidgets('a listing with none invites the first', (tester) async {
      _repo.offers.clear();
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));

      expect(find.textContaining('No offers yet'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('property-offers-record')), findsOneWidget);
    });

    testWidgets('a failure to load says so and can be retried', (tester) async {
      _repo.failWith = Exception('offline');
      await _pump(tester, _page(const PropertyOffersCard(propertyId: 7)));
      expect(find.text('Could not load the offers'), findsOneWidget);

      _repo.failWith = null;
      await tester.tap(find.byKey(const ValueKey('property-offers-retry')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('offer-row-1')), findsOneWidget);
    });
  });

  group('on the buyer', () {
    testWidgets('each offer names its listing', (tester) async {
      await _pump(tester, _page(const ClientOffersCard(clientId: 21)));

      expect(find.byKey(const ValueKey('offer-row-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-row-4')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-row-2')), findsNothing,
          reason: "another buyer's offer");
      expect(find.textContaining('Severny Residence, apartment 84'),
          findsNWidgets(2));
      expect(find.text('Expired'), findsOneWidget);
      expect(find.byKey(const ValueKey('property-offers-record')), findsNothing,
          reason: 'offers are recorded from the listing');
    });

    testWidgets('a buyer with none says where offers come from',
        (tester) async {
      await _pump(tester, _page(const ClientOffersCard(clientId: 99)));
      expect(find.textContaining('Record one from a listing'), findsOneWidget);
    });
  });

  group('the offer', () {
    testWidgets('shows the figure, whose it is, and the negotiation',
        (tester) async {
      _repo.offers.removeWhere((o) => o.id == 2);
      await _pump(tester, const OfferScreen(id: 1));

      expect(find.byKey(const ValueKey('offer-amount-hero')), findsOneWidget);
      expect(find.text(formatPrice(26500000)), findsWidgets);
      expect(find.textContaining("The buyer's figure · 95% of asking"),
          findsOneWidget);
      expect(find.text('Offer from the buyer'), findsOneWidget);
      expect(find.text("Seller's counter"), findsOneWidget);
      expect(find.text('The seller will not go below this.'), findsOneWidget);
      expect(find.text('Marat Manager · Oct 2'), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-accept')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-counter')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-reject')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-withdraw')), findsOneWidget);
    });

    testWidgets(
        'accepting asks first, says what happens to the others, and saves',
        (tester) async {
      _repo.offers.removeWhere((o) => o.id == 2);
      await _pump(tester, const OfferScreen(id: 1));

      await tester.tap(find.byKey(const ValueKey('offer-accept')));
      await tester.pumpAndSettle();
      expect(find.textContaining('stay open as backups'), findsOneWidget);
      await tester.tap(find.text('Accept').last);
      await tester.pumpAndSettle();

      expect(_repo.decided, [(1, OfferDecision.accept)]);
      expect(find.text('Accepted'), findsWidgets);
      expect(find.byKey(const ValueKey('offer-accept')), findsNothing);
      expect(find.byKey(const ValueKey('offer-withdraw')), findsOneWidget,
          reason: 'an accepted offer can still fall through');
    });

    testWidgets('cancelling the question decides nothing', (tester) async {
      _repo.offers.removeWhere((o) => o.id == 2);
      await _pump(tester, const OfferScreen(id: 1));

      await tester.tap(find.byKey(const ValueKey('offer-reject')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(_repo.decided, isEmpty);
    });

    testWidgets('a backup cannot be accepted while another one stands',
        (tester) async {
      await _pump(tester, const OfferScreen(id: 1));

      expect(find.byKey(const ValueKey('offer-backup')), findsOneWidget);
      final accept = tester
          .widget<AppFilledButton>(find.byKey(const ValueKey('offer-accept')));
      expect(accept.onPressed, isNull);
    });

    testWidgets('a refusal from the server is put in words', (tester) async {
      _repo.offers.removeWhere((o) => o.id == 2);
      await _pump(tester, const OfferScreen(id: 1));
      _repo.failWith = FakeOffersRepository.refusal('OFFER_CLOSED');

      await tester.tap(find.byKey(const ValueKey('offer-reject')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      expect(find.text('This offer is no longer open'), findsOneWidget);
    });

    testWidgets('someone who may not decide sees the offer and no buttons',
        (tester) async {
      _repo.offers[0] = _offer(canEdit: false);
      await _pump(tester, const OfferScreen(id: 1));

      expect(find.byKey(const ValueKey('offer-history')), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-accept')), findsNothing);
      expect(find.byKey(const ValueKey('offer-counter')), findsNothing);
      expect(find.byKey(const ValueKey('offer-withdraw')), findsNothing);
    });

    testWidgets('a closed offer offers nothing more', (tester) async {
      await _pump(tester, const OfferScreen(id: 3));

      expect(find.text('Rejected'), findsOneWidget);
      expect(find.byKey(const ValueKey('offer-accept')), findsNothing);
      expect(find.byKey(const ValueKey('offer-withdraw')), findsNothing);
    });

    testWidgets('a failure to load says so and can be retried', (tester) async {
      _repo.failWith = Exception('offline');
      await _pump(tester, const OfferScreen(id: 1));
      expect(find.text('Could not load the offer'), findsOneWidget);

      _repo.failWith = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('offer-history')), findsOneWidget);
    });
  });

  group('recording', () {
    setUp(() {
      Injector.clientsRepository = FakeClientsRepository(clients: const [
        ClientResponse(
            id: 31, fullName: 'Dana Seitova', phone: '+7 705 000 11 22'),
        ClientResponse(id: 21, fullName: 'Saule Nurlanova'),
      ]);
    });
    tearDown(() => Injector.clientsRepository = FakeClientsRepository());

    testWidgets('a buyer, an amount, a deadline and a note', (tester) async {
      await _pump(tester, _sheet(const RecordOfferForm(propertyId: 7)));

      final save = find.byKey(const ValueKey('offer-save'));
      expect(tester.widget<AppFilledButton>(save).onPressed, isNull,
          reason: 'it waits for a buyer and an amount');

      await tester.tap(find.byKey(const ValueKey('offer-buyer')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dana Seitova'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('offer-amount')), '26 500 000');
      await tester.enterText(
          find.byKey(const ValueKey('offer-note')), '  Cash  ');
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      final (propertyId, draft) = _repo.created.single;
      expect(propertyId, 7);
      expect(draft.clientId, 31);
      expect(draft.amount, 26500000);
      expect(draft.expiresOn, isNull);
      expect(draft.toJson(),
          {'clientId': 31, 'amount': 26500000.0, 'note': 'Cash'});
    });

    testWidgets('a second open offer from the same buyer is refused in words',
        (tester) async {
      await _pump(tester, _sheet(const RecordOfferForm(propertyId: 7)));

      await tester.tap(find.byKey(const ValueKey('offer-buyer')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saule Nurlanova'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('offer-amount')), '1000');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('offer-save')));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'This buyer already has an open offer here; counter it instead'),
          findsOneWidget);
      expect(_repo.created, isEmpty);
    });
  });

  group('countering', () {
    testWidgets('the other side answers by default, with a new figure',
        (tester) async {
      await _pump(tester, _sheet(CounterOfferForm(offer: _offer())));

      final seller = tester
          .widget<FilterPill>(find.byKey(const ValueKey('offer-party-seller')));
      expect(seller.selected, isTrue,
          reason: "the buyer's figure is on the table, so the seller answers");
      expect(find.byKey(const ValueKey('offer-expires-clear')), findsNothing,
          reason: 'a counter moves the deadline but cannot take it away');

      await tester.enterText(
          find.byKey(const ValueKey('offer-amount')), '27200000');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('offer-counter-save')));
      await tester.pumpAndSettle();

      final (id, draft) = _repo.countered.single;
      expect(id, 1);
      expect(draft.amount, 27200000);
      expect(draft.party, OfferParty.seller);
      expect(draft.toJson(), {'amount': 27200000.0, 'party': 'SELLER'},
          reason: 'an unchanged deadline is left for the server to keep');
    });
  });

  group('the wire', () {
    test('amounts are read the way agents type them', () {
      expect(parseOfferAmount('26 500 000'), 26500000);
      expect(parseOfferAmount('26,500,000'), 26500000);
      expect(parseOfferAmount('1500,50'), 1500.5);
      expect(parseOfferAmount('abc'), 0);
    });

    test('an offer reads from the server, its status included', () {
      final o = PropertyOffer.fromJson(const {
        'id': 1,
        'propertyId': 7,
        'clientId': 21,
        'amount': 26500000,
        'lastParty': 'SELLER',
        'status': 'EXPIRED',
        'expiresOn': '2026-10-01',
        'otherAccepted': false,
        'history': [
          {'id': 1, 'action': 'OFFERED', 'amount': 25000000, 'party': 'BUYER'},
          {'id': 2, 'action': 'HAGGLED', 'amount': 1},
        ],
      });
      expect(o.status, OfferStatus.expired);
      expect(o.status.isOpen, isFalse);
      expect(o.lastParty, OfferParty.seller);
      expect(o.history.first.action, OfferAction.offered);
      expect(o.history.last.action, isNull,
          reason: 'a step this app does not know is shown as a change');

      final unknown = PropertyOffer.fromJson(
          const {'id': 1, 'propertyId': 7, 'clientId': 21, 'status': 'MAYBE'});
      expect(unknown.status, OfferStatus.isNew);
    });

    test('a decision goes to its own endpoint', () {
      expect(OfferDecision.values.map((d) => d.name),
          ['accept', 'reject', 'withdraw']);
      expect(const OfferDraft(clientId: 1, amount: 5, expiresOn: null).toJson(),
          {'clientId': 1, 'amount': 5.0});
      expect(
          OfferDraft(clientId: 1, amount: 5, expiresOn: DateTime(2026, 1, 9))
              .toJson()['expiresOn'],
          '2026-01-09');
    });

    test('the offers and an offer can be read offline', () {
      for (final path in [
        '/properties/7/offers',
        '/clients/21/offers',
        '/offers/1',
      ]) {
        expect(OfflineCache.isCacheable('GET', path), isTrue, reason: path);
      }
      expect(OfflineCache.isCacheable('POST', '/offers/1/accept'), isFalse);
    });
  });
}
