import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_labels.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/lead_source.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partner_detail_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partner_form_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partners_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/client_partners_card.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/handoff_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

import 'partner_fakes.dart';
import 'responsive_harness.dart';

/// Partners: the agency's directory of brokers, notaries and the rest, what
/// their referrals came to, the client a partner sent and the partners a
/// client was sent to.

const _broker = Partner(
  id: 1,
  name: 'Ainur Sadykova-Abdrakhmanova',
  company: 'Halyk Bank mortgage centre on Dostyk avenue',
  kind: PartnerKind.mortgageBroker,
  phone: '+7 701 555 12 34',
  email: 'ainur.sadykova@halykbank.kz',
  note: 'Answers within the hour. Prefers WhatsApp to calls after six.',
  feeType: ReferralFeeType.percent,
  feeValue: 20,
  createdById: 5,
  createdByName: 'Aigul Bekova',
  canEdit: true,
  referredClients: 3,
  wonDeals: 3,
  feesOwed: 280000,
  wonDealsWithoutCommission: 1,
  handoffs: 1,
  openHandoffs: 1,
);

const _notary = Partner(
  id: 2,
  name: 'Notary Bekov',
  kind: PartnerKind.lawyer,
  feeType: ReferralFeeType.fixed,
  feeValue: 50000,
);

const _unused = Partner(
    id: 3,
    name: 'Kok-Tobe Developments',
    canEdit: true,
    kind: PartnerKind.developer);

final _handoff = PartnerHandoff(
  id: 41,
  clientId: 7,
  clientName: 'Saule Nurlanovna Abdrakhmanova-Seitkali',
  partnerId: 1,
  partnerName: _broker.name,
  partnerCompany: _broker.company,
  partnerKind: PartnerKind.mortgageBroker,
  sentOn: DateTime(2026, 9, 28),
  status: PartnerHandoffStatus.inProgress,
  note: 'Pre-approval for a two-room flat, needs it before the viewing.',
  sentByName: 'Timur Aliev-Konstantinopolsky',
);

const _referrals = [
  PartnerReferral(
    clientId: 7,
    fullName: 'Saule Nurlanovna Abdrakhmanova-Seitkali',
    agentName: 'Timur Aliev-Konstantinopolsky',
    wonDeals: 2,
    feeOwed: 280000,
    wonDealsWithoutCommission: 1,
  ),
  PartnerReferral(
      clientId: 8, fullName: 'Arman Bekov', type: ClientType.SELLER),
];

const _client = ClientResponse(
  id: 7,
  fullName: 'Saule Nurlanovna',
  leadSource: LeadSource.PARTNER,
  referredByPartnerId: 1,
  referredByPartnerName: 'Ainur Sadykova-Abdrakhmanova',
);

late FakePartnersRepository _repo;

Widget _page(Widget child) => Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [child]),
    );

Widget _sheet({PartnerHandoff? existing}) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Send',
          child: HandoffForm(clientId: 7, existing: existing),
        ),
      ),
    );

/// [child] on top of a home page, so it can pop back to it and a push from
/// it lands somewhere the test can name.
Widget _routed(Widget child, {List<String>? visited}) => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/page',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('home')),
            routes: [GoRoute(path: 'page', builder: (_, __) => child)],
          ),
          GoRoute(
            path: '/partners/:id',
            builder: (_, s) {
              visited?.add(s.uri.path);
              return Scaffold(body: Text('partner ${s.pathParameters['id']}'));
            },
          ),
          GoRoute(
            path: '/clients/:id',
            builder: (_, s) {
              visited?.add(s.uri.path);
              return Scaffold(body: Text('client ${s.pathParameters['id']}'));
            },
          ),
        ],
      ),
    );

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

/// A phone-sized view for the tests that build their own app.
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await expectNoOverflow(tester, child,
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

  setUp(() {
    AppClock.freeze(DateTime(2026, 10, 4, 12));
    _repo = FakePartnersRepository(
      partners: [_broker, _notary, _unused],
      referrals: {
        1: [..._referrals]
      },
      handoffs: [_handoff],
    );
    Injector.partnersRepository = _repo;
  });

  tearDown(() {
    AppClock.reset();
    Injector.partnersRepository = FakePartnersRepository();
  });

  group('fits every screen', () {
    forEachAcceptanceCase('partners list',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const PartnersScreen(),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('partner detail',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const PartnerDetailScreen(id: 1),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('partner form',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const PartnerFormScreen(partnerId: 1),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('hand-off sheet',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _sheet(existing: _handoff),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('client partners card',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
          tester, _page(const ClientPartnersCard(client: _client)),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('everything renders in ${locale.languageCode}',
          (tester) async {
        for (final child in <Widget>[
          const PartnersScreen(),
          const PartnerDetailScreen(id: 1),
          const PartnerFormScreen(partnerId: 1),
          const PartnerFormScreen(),
          _sheet(),
          _page(const ClientPartnersCard(client: _client)),
        ]) {
          await expectNoOverflow(tester, child,
              size: const Size(320, 568),
              brightness: Brightness.light,
              textScale: 1.3,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('the list', () {
    testWidgets('narrows by kind and by a word in the name or company',
        (tester) async {
      await _pump(tester, const PartnersScreen());

      expect(find.byKey(const ValueKey('partner-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('partner-2')), findsOneWidget);
      expect(find.text('Referred: 3 · Fees owed: \$280,000'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('partners-kind-lawyer')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('partner-1')), findsNothing);
      expect(find.byKey(const ValueKey('partner-2')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('partners-kind-all')));
      await tester.enterText(
          find.byKey(const ValueKey('partners-search')), 'halyk');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('partner-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('partner-2')), findsNothing);

      await tester.enterText(
          find.byKey(const ValueKey('partners-search')), 'nobody');
      await tester.pumpAndSettle();
      expect(find.text(l10n.partnersNoMatches), findsOneWidget);
    });

    testWidgets('an empty agency is told how to start', (tester) async {
      Injector.partnersRepository = FakePartnersRepository();
      await _pump(tester, const PartnersScreen());
      expect(find.text(l10n.partnersEmpty), findsOneWidget);
      expect(find.byKey(const ValueKey('partner-new')), findsOneWidget);
    });

    testWidgets('a failure to load offers a retry', (tester) async {
      _repo.failWith = FakePartnersRepository.refusal('/partners', 500, 'X');
      await _pump(tester, const PartnersScreen());
      expect(find.text(l10n.partnersLoadFailed), findsOneWidget);
      _repo.failWith = null;
      await tester.tap(find.text(l10n.coreRetry));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('partner-1')), findsOneWidget);
    });
  });

  group('a partner', () {
    testWidgets('shows the fee, the numbers and what is left out of them',
        (tester) async {
      await _pump(tester, const PartnerDetailScreen(id: 1));

      expect(find.text('Referral fee: 20% of commission'), findsOneWidget);
      expect(find.text(l10n.partnersAddedBy('Aigul Bekova')), findsOneWidget);
      expect(find.text('\$280,000'), findsOneWidget);
      expect(
          find.text('${l10n.partnersStatsScope} '
              '${l10n.partnersFeesUnknown(1)}'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('referral-7')), findsOneWidget);
      expect(find.text('Won deals: 2 · Fee \$280,000'), findsOneWidget);
      expect(find.text(l10n.partnersReferralNoDeals), findsOneWidget);
      expect(find.byKey(const ValueKey('handoff-41')), findsOneWidget);
      expect(find.text(l10n.partnersHandoffInProgress), findsOneWidget);
    });

    testWidgets('a fixed fee reads per deal, and a colleague cannot edit',
        (tester) async {
      await _pump(tester, const PartnerDetailScreen(id: 2));
      expect(find.text('Referral fee: \$50,000 per deal'), findsOneWidget);
      expect(find.byTooltip(l10n.partnersEdit), findsNothing);
      expect(find.text(l10n.partnersNoReferrals), findsOneWidget);
      expect(find.text(l10n.partnersNoSentClients), findsOneWidget);
    });

    testWidgets('one clients are linked to is not deleted', (tester) async {
      await _pump(tester, const PartnerDetailScreen(id: 1));
      await tester.tap(find.byTooltip(l10n.partnersDelete));
      await tester.pumpAndSettle();
      expect(find.text(l10n.partnersInUse), findsOneWidget);
      expect(_repo.deleted, isEmpty);
    });

    testWidgets('one nothing points at is deleted after asking',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_routed(const PartnerDetailScreen(id: 3)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.partnersDelete));
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(AppFilledButton, l10n.partnersDelete).last);
      await tester.pumpAndSettle();
      expect(_repo.deleted, [3]);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a referred client opens their card', (tester) async {
      final visited = <String>[];
      _phone(tester);
      await tester.pumpWidget(
          _routed(const PartnerDetailScreen(id: 1), visited: visited));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('referral-8')));
      await tester.tap(find.byKey(const ValueKey('referral-8')));
      await tester.pumpAndSettle();
      expect(visited, ['/clients/8']);
    });
  });

  group('the form', () {
    testWidgets('asks for a name and a percent within 0-100', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_routed(const PartnerFormScreen()));
      await tester.pumpAndSettle();

      await _tapKey(tester, 'partner-fee-percent');
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('partner-fee-value')), '120');
      await _tapKey(tester, 'partner-save');
      await tester.pumpAndSettle();
      expect(find.text(l10n.partnersNameRequired), findsOneWidget);
      expect(find.text(l10n.partnersFeeInvalidPercent), findsOneWidget);
      expect(_repo.saved, isEmpty);
    });

    testWidgets('saves a new partner with its kind and fee', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_routed(const PartnerFormScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('partner-name')), '  Notary Seitova ');
      await _tapKey(tester, 'partner-kind-lawyer');
      await tester.enterText(
          find.byKey(const ValueKey('partner-company')), 'Seitova & Co');
      await _tapKey(tester, 'partner-fee-fixed');
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('partner-fee-value')), '150 000');
      await _tapKey(tester, 'partner-save');
      await tester.pumpAndSettle();

      final draft = _repo.saved.single;
      expect(draft.name, 'Notary Seitova');
      expect(draft.kind, PartnerKind.lawyer);
      expect(draft.company, 'Seitova & Co');
      expect(draft.feeType, ReferralFeeType.fixed);
      expect(draft.feeValue, 150000);
      expect(draft.phone, isNull);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('edits a partner as it was, and the fee can be taken off',
        (tester) async {
      _phone(tester);
      await tester.pumpWidget(_routed(const PartnerFormScreen(partnerId: 1)));
      await tester.pumpAndSettle();
      expect(find.text('Ainur Sadykova-Abdrakhmanova'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      await _tapKey(tester, 'partner-fee-none');
      await tester.pumpAndSettle();
      await _tapKey(tester, 'partner-save');
      await tester.pumpAndSettle();

      final draft = _repo.saved.single;
      expect(draft.feeType, isNull);
      expect(draft.feeValue, isNull);
      expect(draft.kind, PartnerKind.mortgageBroker);
    });
  });

  group("a client's partners", () {
    testWidgets('names the partner who sent them and the ones they went to',
        (tester) async {
      final visited = <String>[];
      _phone(tester);
      await tester.pumpWidget(_routed(
          _page(const ClientPartnersCard(client: _client)),
          visited: visited));
      await tester.pumpAndSettle();

      expect(find.text(l10n.partnersReferredBy), findsOneWidget);
      expect(find.byKey(const ValueKey('handoff-41')), findsOneWidget);
      expect(find.text(l10n.partnersHandoffInProgress), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('client-referred-by')));
      await tester.pumpAndSettle();
      expect(visited, ['/partners/1']);
    });

    testWidgets('a client nobody sent and who went nowhere says so',
        (tester) async {
      await _pump(
          tester,
          _page(const ClientPartnersCard(
              client: ClientResponse(id: 9, fullName: 'Arman'))));
      expect(find.text(l10n.partnersReferredBy), findsNothing);
      expect(find.text(l10n.partnersClientNotSent), findsOneWidget);
    });

    testWidgets('is sent to a partner picked from the agency', (tester) async {
      await _pump(
          tester,
          _page(const ClientPartnersCard(
              client: ClientResponse(id: 9, fullName: 'Arman'))));

      await tester.tap(find.byKey(const ValueKey('client-send-to-partner')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('handoff-save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('handoff-error')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('handoff-partner')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notary Bekov').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('handoff-status-done')));
      await tester.enterText(
          find.byKey(const ValueKey('handoff-note')), 'Papers for the sale');
      await tester.tap(find.byKey(const ValueKey('handoff-save')));
      await tester.pumpAndSettle();

      final draft = _repo.sent.single;
      expect(draft.partnerId, 2);
      expect(draft.status, PartnerHandoffStatus.done);
      expect(draft.sentOn, DateTime(2026, 10, 4));
      expect(draft.note, 'Papers for the sale');
      expect(find.text('Notary Bekov'), findsOneWidget);
      expect(find.text(l10n.partnersHandoffDone), findsOneWidget);
    });

    testWidgets('a hand-off is moved along or taken off', (tester) async {
      await _pump(tester, _page(const ClientPartnersCard(client: _client)));

      await tester.tap(find.byKey(const ValueKey('handoff-41')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('handoff-status-done')));
      await tester.tap(find.byKey(const ValueKey('handoff-save')));
      await tester.pumpAndSettle();
      expect(_repo.sent.single.status, PartnerHandoffStatus.done);
      expect(find.text(l10n.partnersHandoffDone), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('handoff-41')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('handoff-remove')));
      await tester.tap(find.byKey(const ValueKey('handoff-remove')));
      await tester.pumpAndSettle();
      await tester.tap(find
          .widgetWithText(AppFilledButton, l10n.partnersHandoffRemove)
          .last);
      await tester.pumpAndSettle();
      expect(_repo.deletedHandoffs, [41]);
      expect(find.text(l10n.partnersClientNotSent), findsOneWidget);
    });
  });

  group('where a client came from', () {
    testWidgets('PARTNER asks which partner, and says so when none is picked',
        (tester) async {
      final detail = TextEditingController();
      addTearDown(detail.dispose);
      var picked = 0;
      await _pump(
          tester,
          _page(LeadSourceField(
            source: LeadSource.PARTNER,
            onChanged: (_) {},
            detailCtrl: detail,
            onPickPartner: () => picked++,
            partnerError: l10n.partnersRequired,
          )));

      expect(find.text(l10n.clientsLeadSourcePartner), findsOneWidget);
      expect(find.text(l10n.partnersRequired), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lead-source-partner')));
      expect(picked, 1);
    });

    testWidgets('another source asks for no partner', (tester) async {
      final detail = TextEditingController();
      addTearDown(detail.dispose);
      await _pump(
          tester,
          _page(LeadSourceField(
            source: LeadSource.REFERRAL,
            onChanged: (_) {},
            detailCtrl: detail,
            onPickPartner: () {},
          )));
      expect(find.byKey(const ValueKey('lead-source-partner')), findsNothing);
    });

    test('the card and the change log name the partner in words', () {
      expect(
          leadSourceText(l10n, LeadSource.PARTNER, 'mortgage',
              partner: 'Ainur Sadykova'),
          'Partner · Ainur Sadykova · mortgage');
      expect(leadSourceText(l10n, LeadSource.REFERRAL, null, partner: 'x'),
          'Referral');
      expect(changeFieldLabel(l10n, 'referredBy'), 'Referred by');
      expect(
          changeValueLabel(
              l10n, ChangeEntityType.client, 'leadSource', 'PARTNER', 'en'),
          'Partner');
      expect(
          changeValueLabel(l10n, ChangeEntityType.client, 'referredBy',
              'Ainur Sadykova', 'en'),
          'Ainur Sadykova');
    });
  });
}
