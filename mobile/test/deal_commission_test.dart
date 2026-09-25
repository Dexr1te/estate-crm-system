import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/goal_ring_card.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Remembers what the form sent and never answers, so the screen stays put
/// instead of navigating away through a router the test does not have.
class _RecordingDealsRepository extends FakeDealsRepository {
  _RecordingDealsRepository(super.deals);

  Map<String, dynamic>? sent;

  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) {
    sent = data;
    return Completer<DealResponse>().future;
  }
}

const _priced = DealResponse(
  id: 1,
  title: 'Dostyk 210, apartment 14',
  status: DealStatus.CLOSED_WON,
  clientId: 1,
  clientName: 'Aigerim Nurlanovna',
  agentId: 5,
  agentName: 'Maria Kim',
  dealPrice: 48500000,
  commissionPercent: 2.5,
  commission: 1212500,
);

const _unpriced = DealResponse(
  id: 2,
  title: 'Search for a three-room flat',
  status: DealStatus.LEAD,
  clientId: 1,
  agentId: 5,
  commissionPercent: 3,
);

const _noRate = DealResponse(
  id: 3,
  title: 'Office floor, Nurly Tau',
  status: DealStatus.NEGOTIATION,
  clientId: 1,
  agentId: 5,
  dealPrice: 30000000,
);

late _RecordingDealsRepository _repo;

void _installFakes() {
  _repo = _RecordingDealsRepository(const [_priced, _unpriced, _noRate]);
  Injector.dealsRepository = _repo;
  Injector.documentsRepository = FakeDocumentsRepository();
  Injector.fileGateway = FakeFileGateway();
  Injector.clientsRepository = FakeClientsRepository();
  Injector.agentsRepository = const FakeAgentsRepository([]);
  Injector.propertiesRepository = FakePropertiesRepository(const []);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(_repo)),
      ],
      child: child,
    );

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(430, 2000)}) async {
  await expectNoOverflow(
    tester,
    child,
    size: size,
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(_installFakes);

  test('a rate is shown without trailing zeros', () {
    expect(formatRate(2.5), '2.5');
    expect(formatRate(3), '3');
    expect(formatRate(1.75), '1.75');
    expect(formatRate(100), '100');
    expect(formatRate(10.5), '10.5');
  });

  group('deal detail', () {
    testWidgets('shows the rate and what it comes to', (tester) async {
      await _pump(tester, _wrap(const DealDetailScreen(id: 1)));

      expect(find.text('COMMISSION'), findsOneWidget);
      expect(find.text('2.5%'), findsOneWidget);
      expect(find.text(formatPrice(1212500)), findsOneWidget);
    });

    testWidgets('asks for a price when only the rate is known', (tester) async {
      await _pump(tester, _wrap(const DealDetailScreen(id: 2)));

      expect(find.text('3%'), findsOneWidget);
      expect(find.text('Set a deal price to work it out'), findsOneWidget);
    });

    testWidgets('says nothing about commission when no rate is set',
        (tester) async {
      await _pump(tester, _wrap(const DealDetailScreen(id: 3)));

      expect(find.text('COMMISSION'), findsNothing);
    });
  });

  group('deal form', () {
    Finder commissionField() => find.descendant(
          of: find.widgetWithText(LabelledField, 'Commission, %'),
          matching: find.byType(TextFormField),
        );

    testWidgets('loads the rate into the field and sends a corrected one',
        (tester) async {
      await _pump(tester, _wrap(const DealFormScreen(dealId: 1)));

      expect(find.text('Commission, %'), findsOneWidget);
      final editable = tester.widget<EditableText>(find.descendant(
          of: commissionField(), matching: find.byType(EditableText)));
      expect(editable.controller.text, '2.5');

      await tester.enterText(commissionField(), '3,25');
      await tester.tap(find.text('Update Deal'));
      await tester.pump();

      expect(_repo.sent, isNotNull);
      expect(_repo.sent!['commissionPercent'], 3.25);
    });

    testWidgets('a cleared rate is not sent, so the deal loses it',
        (tester) async {
      await _pump(tester, _wrap(const DealFormScreen(dealId: 1)));

      await tester.enterText(commissionField(), '');
      await tester.tap(find.text('Update Deal'));
      await tester.pump();

      expect(_repo.sent, isNotNull);
      expect(_repo.sent!.containsKey('commissionPercent'), isFalse);
    });

    for (final bad in ['0', '150', '-2', '2.555', 'abc']) {
      testWidgets('refuses "$bad" and sends nothing', (tester) async {
        await _pump(tester, _wrap(const DealFormScreen(dealId: 1)));

        await tester.enterText(commissionField(), bad);
        await tester.tap(find.text('Update Deal'));
        await tester.pump();

        expect(find.text('Enter a rate above 0 and no more than 100'),
            findsOneWidget);
        expect(_repo.sent, isNull);
      });
    }
  });

  group('goal card', () {
    testWidgets('names the month\'s commission once there is some',
        (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: GoalRingCard(
              achieved: 48500000,
              target: 60000000,
              commission: 1212500,
              onEdit: () {}),
        ),
      );
      expect(
        find.text('Commission this month: ${formatPrice(1212500)}'),
        findsOneWidget,
      );
    });

    testWidgets('stays quiet while nothing has been earned', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: GoalRingCard(achieved: 0, target: null, onEdit: () {}),
        ),
      );
      expect(find.textContaining('Commission'), findsNothing);
    });

    forEachAcceptanceCase('goal card with commission',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: GoalRingCard(
                achieved: 1234567890,
                target: 2000000000,
                commission: 98765432,
                onEdit: () {}),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
      );
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('goal card with commission in ${locale.languageCode}',
          (tester) async {
        await expectNoOverflow(
          tester,
          Scaffold(
            body: GoalRingCard(
                achieved: 1234567890,
                target: 2000000000,
                commission: 98765432,
                onEdit: () {}),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale,
        );
      });
    }
  });
}
