import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/mortgage/data/mortgage_memory.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/features/mortgage/presentation/screens/mortgage_screen.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// A buyer at a viewing asks what the flat costs a month. The listing answers
/// in one line, opens to the essentials, and the calculator behind it takes
/// the price from the listing, links the down payment's amount and share,
/// fills a typical rate from a chip, switches annuity for differentiated,
/// lays out the schedule year by year, remembers how the agent left it, and
/// sends the client a plain-text estimate in the app's language.

const _price = 25000000.0;
const _title = 'Severny Residence, apartment 84';
const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

late FakeShareGateway _share;

Future<AuthBloc> _signedIn() async {
  final auth = AuthBloc(FakeAuthRepository(user: _agent))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  return auth;
}

Future<void> _show(WidgetTester tester, Widget child,
    {AuthBloc? auth,
    Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(
    tester,
    auth == null ? child : BlocProvider.value(value: auth, child: child),
    size: size,
    brightness: brightness,
    textScale: textScale,
    locale: locale,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

String _field(WidgetTester tester, String key) => tester
    .widget<EditableText>(find.descendant(
        of: find.byKey(ValueKey(key)), matching: find.byType(EditableText)))
    .controller
    .text;

String _monthly(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('mortgage-monthly'))).data!;

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

MortgageResult _expected(
        {double down = 20,
        double rate = 18,
        int years = 20,
        MortgagePaymentType type = MortgagePaymentType.annuity}) =>
    calculateMortgage(MortgageSettings(
            ratePercent: rate, termYears: years, type: type, downPercent: down)
        .inputFor(_price));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _share = FakeShareGateway();
    Injector.shareGateway = _share;
  });

  group('calculator screen', () {
    testWidgets('takes the price from the listing and answers at once',
        (tester) async {
      await _show(tester, const MortgageScreen(price: _price, title: _title));

      expect(_field(tester, 'mortgage-price'), '25000000');
      expect(_field(tester, 'mortgage-down-amount'), '5000000');
      expect(_field(tester, 'mortgage-down-percent'), '20');
      expect(_field(tester, 'mortgage-rate'), '18');
      expect(find.text('20 years'), findsOneWidget);
      expect(_monthly(tester), formatCents(_expected().firstPaymentCents));
      // 20 000 000 at 18% over 240 months: 308 662.30 a month, and twice
      // that is the income a bank wants to see.
      expect(_expected().firstPaymentCents, 30866230);
      expect(_monthly(tester), r'$308,662');
      expect(find.textContaining('Income needed: \$617,325'), findsOneWidget);
    });

    testWidgets('down payment amount and percent move together',
        (tester) async {
      await _show(tester, const MortgageScreen(price: _price));

      await tester.enterText(
          find.byKey(const ValueKey('mortgage-down-percent')), '30');
      await tester.pump();
      expect(_field(tester, 'mortgage-down-amount'), '7500000');

      await tester.enterText(
          find.byKey(const ValueKey('mortgage-down-amount')), '10 000 000');
      await tester.pump();
      expect(_field(tester, 'mortgage-down-percent'), '40');
      expect(
          _monthly(tester), formatCents(_expected(down: 40).firstPaymentCents));

      final slider = tester.widget<Slider>(find.descendant(
          of: find.byKey(const ValueKey('mortgage-down-slider')),
          matching: find.byType(Slider)));
      expect(slider.value, 40);
      expect(slider.max, 90);
      slider.onChanged!(50);
      await tester.pump();
      expect(_field(tester, 'mortgage-down-amount'), '12500000');
      expect(_field(tester, 'mortgage-down-percent'), '50');

      await tester.enterText(
          find.byKey(const ValueKey('mortgage-price')), '30000000');
      await tester.pump();
      expect(_field(tester, 'mortgage-down-amount'), '15000000',
          reason: 'a new price keeps the share, not the amount');
    });

    testWidgets('a preset chip fills rate, term and down payment',
        (tester) async {
      await _show(tester, const MortgageScreen(price: _price));

      await _tap(tester, 'mortgage-preset-stateProgram');
      expect(_field(tester, 'mortgage-rate'), '7');
      expect(find.text('25 years'), findsOneWidget);
      expect(_field(tester, 'mortgage-down-percent'), '20');
      // 20 000 000 at 7% over 300 months: 141 355.84 a month.
      expect(_monthly(tester), r'$141,356');
      expect(find.textContaining('Rates change'), findsOneWidget);

      await _tap(tester, 'mortgage-preset-housingSavings');
      expect(_field(tester, 'mortgage-rate'), '5');
      expect(find.text('25 years'), findsOneWidget,
          reason: 'a preset without a term leaves the term alone');
    });

    testWidgets('differentiated shows first and last month', (tester) async {
      await _show(tester, const MortgageScreen(price: _price));
      final annuity = _monthly(tester);

      await tester.ensureVisible(find.text('Differentiated'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Differentiated'));
      await tester.pumpAndSettle();
      final d = _expected(type: MortgagePaymentType.differentiated);
      // 20 000 000 / 240 = 83 333.33 principal + 1.5% of the balance:
      // 383 333.33 in the first month, 84 583.33 in the last.
      expect(d.firstPaymentCents, 38333333);
      expect(d.lastPaymentCents, 8458333);
      expect(_monthly(tester), r'$383,333 → $84,583');
      expect(_monthly(tester), isNot(annuity));
      expect(find.text('First month → last month'), findsOneWidget);
    });

    testWidgets('the schedule opens a year into its months', (tester) async {
      await _show(tester, const MortgageScreen(price: _price));

      expect(find.byKey(const ValueKey('mortgage-year-20')), findsOneWidget);
      expect(find.byKey(const ValueKey('mortgage-month-1')), findsNothing);
      await _tap(tester, 'mortgage-year-1');
      expect(find.byKey(const ValueKey('mortgage-month-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('mortgage-month-12')), findsOneWidget);
      expect(find.byKey(const ValueKey('mortgage-month-13')), findsNothing);
      await _tap(tester, 'mortgage-year-1');
      expect(find.byKey(const ValueKey('mortgage-month-1')), findsNothing);
    });

    testWidgets('nothing to borrow says so and sends nothing', (tester) async {
      await _show(tester, const MortgageScreen(price: _price));
      await tester.enterText(
          find.byKey(const ValueKey('mortgage-down-amount')), '25000000');
      await tester.pump();

      expect(find.textContaining('nothing to borrow'), findsOneWidget);
      expect(find.byKey(const ValueKey('mortgage-year-1')), findsNothing);
      await _tap(tester, 'mortgage-send');
      expect(_share.calls, 0);
    });
  });

  group('send to client', () {
    const cases = {
      'en': [
        'Mortgage estimate',
        'Price: \$25.0M',
        'Down payment: \$5.0M (20%)',
        'Rate: 18% a year',
        'Term: 20 years',
        'Monthly payment: \$308,662',
        'Indicative estimate, not an offer.',
      ],
      'ru': [
        'Расчёт ипотеки',
        'Цена: \$25.0M',
        'Первоначальный взнос: \$5.0M (20%)',
        'Ставка: 18% годовых',
        'Срок: 20 лет',
        'Ежемесячный платёж: \$308,662',
        'Переплата: ',
        'Ориентировочный расчёт, не является офертой.',
      ],
      'kk': [
        'Ипотека есебі',
        'Бағасы: \$25.0M',
        'Бастапқы жарна: \$5.0M (20%)',
        'Мөлшерлеме: жылдық 18%',
        'Мерзімі: 20 жыл',
        'Ай сайынғы төлем: \$308,662',
        'Артық төлем: ',
        'Болжамды есеп, оферта емес.',
      ],
    };

    for (final entry in cases.entries) {
      testWidgets('composes the estimate in ${entry.key}', (tester) async {
        await _show(tester, const MortgageScreen(price: _price, title: _title),
            locale: Locale(entry.key));
        await _tap(tester, 'mortgage-send');

        expect(_share.calls, 1);
        final text = _share.sharedText!;
        expect(text, contains(_title));
        for (final line in entry.value) {
          expect(text, contains(line));
        }
        expect(text, isNot(contains('→')));
      });
    }

    test('differentiated reads as first and last month', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ru'));
      const s = MortgageSettings(type: MortgagePaymentType.differentiated);
      final input = s.inputFor(_price);
      final text = mortgageShareText(
          l10n: l10n, input: input, result: calculateMortgage(input));
      expect(text,
          contains('Ежемесячный платёж: \$383,333 в первый месяц, \$84,583'));
      expect(text.split('\n').first, 'Расчёт ипотеки');
    });

    testWidgets('a failed share says so', (tester) async {
      _share.outcome = ShareOutcome.failed;
      await _show(tester, const MortgageScreen(price: _price));
      await _tap(tester, 'mortgage-send');
      expect(find.text("Couldn't share the estimate"), findsOneWidget);
    });
  });

  group('remembers', () {
    testWidgets('rate, term, type and down payment per person', (tester) async {
      final auth = await _signedIn();
      await _show(tester, const MortgageScreen(price: _price), auth: auth);

      await _tap(tester, 'mortgage-preset-stateProgram');
      await tester.ensureVisible(find.text('Differentiated'));
      await tester.tap(find.text('Differentiated'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString(MortgageMemory.key(5))!);
      expect(saved,
          {'rate': 7.0, 'term': 25, 'type': 'differentiated', 'down': 20.0});

      await tester.pumpWidget(const SizedBox());
      await _show(tester, const MortgageScreen(price: 30000000), auth: auth);
      expect(_field(tester, 'mortgage-rate'), '7');
      expect(find.text('25 years'), findsOneWidget);
      expect(_field(tester, 'mortgage-down-amount'), '6000000');
      expect(_monthly(tester), contains('→'));
    });

    testWidgets('nobody signed in means nothing is kept', (tester) async {
      await _show(tester, const MortgageScreen(price: _price));
      await _tap(tester, 'mortgage-preset-market');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.startsWith('mortgage_')), isEmpty);
    });

    testWidgets('a broken store falls back to defaults', (tester) async {
      SharedPreferences.setMockInitialValues(
          {MortgageMemory.key(5): 'not json'});
      final auth = await _signedIn();
      await _show(tester, const MortgageScreen(price: _price), auth: auth);
      expect(_field(tester, 'mortgage-rate'), '18');
    });
  });

  group('listing card', () {
    Widget card() => const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: PropertyMortgageCard(
                propertyId: 7, price: _price, title: _title),
          ),
        );

    testWidgets('one line until opened, then the essentials', (tester) async {
      await _show(tester, card());

      expect(find.text('MORTGAGE'), findsOneWidget);
      expect(find.text(r'from $308,662 / month'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('mortgage-open-calculator')), findsNothing);

      await _tap(tester, 'mortgage-card-toggle');
      expect(find.textContaining('20% down · 18% · 20 years'), findsOneWidget);
      expect(find.text('Loan'), findsOneWidget);
      expect(find.text(r'$20.0M'), findsOneWidget);
      expect(find.text('Income needed'), findsOneWidget);
      expect(find.textContaining('check with the bank'), findsOneWidget);
      expect(find.byKey(const ValueKey('mortgage-open-calculator')),
          findsOneWidget);
    });

    testWidgets('uses what the agent last chose', (tester) async {
      SharedPreferences.setMockInitialValues({
        MortgageMemory.key(5): jsonEncode(const MortgageSettings(
                ratePercent: 7, termYears: 25, downPercent: 20)
            .toJson()),
      });
      final auth = await _signedIn();
      await _show(tester, card(), auth: auth);
      expect(find.text(r'from $141,356 / month'), findsOneWidget);
    });

    testWidgets('opens the full calculator with the listing price',
        (tester) async {
      expect(mortgageRoute(7, _price, 'Flat 84'),
          '/properties/7/mortgage?price=25000000.00&title=Flat+84');
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => card()),
        GoRoute(
          path: '/properties/:id/mortgage',
          builder: (_, s) => MortgageScreen(
              price: double.parse(s.uri.queryParameters['price']!),
              title: s.uri.queryParameters['title']),
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));
      await tester.pumpAndSettle();

      await _tap(tester, 'mortgage-card-toggle');
      await _tap(tester, 'mortgage-open-calculator');
      expect(find.byType(MortgageScreen), findsOneWidget);
      expect(_field(tester, 'mortgage-price'), '25000000');
    });

    testWidgets('the listing screen carries it under the price',
        (tester) async {
      final repo = FakePropertiesRepository(const [
        PropertyResponse(
            id: 7,
            title: _title,
            address: 'Severny Residence 12',
            city: 'Almaty',
            price: _price),
      ]);
      Injector.propertiesRepository = repo;
      Injector.clientsRepository = FakeClientsRepository();
      Injector.dealsRepository = FakeDealsRepository(const []);
      Injector.meetingsRepository = FakeMeetingsRepository(const []);
      await _show(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(create: (_) => PropertiesBloc(repo)),
            BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
          ],
          child: const PropertyDetailScreen(id: 7),
        ),
      );

      final card = find.byKey(const ValueKey('mortgage-card-summary'));
      await tester.scrollUntilVisible(card, 200,
          scrollable: find.byType(Scrollable).first);
      expect(tester.widget<Text>(card).data, r'from $308,662 / month');
      expect(
          tester.getTopLeft(card).dy,
          lessThan(tester
              .getTopLeft(find.byKey(const ValueKey('share-link-card')))
              .dy));
    });
  });

  forEachAcceptanceCase('mortgage card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await _show(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: PropertyMortgageCard(
                propertyId: 7, price: 1234567890, title: _title),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _tap(tester, 'mortgage-card-toggle');
      expect(tester.takeException(), isNull);
    }
  });

  forEachAcceptanceCase('mortgage screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      for (final type in ['Differentiated', 'Annuity']) {
        await _show(tester, const MortgageScreen(price: 1234567890),
            size: size,
            brightness: brightness,
            textScale: scale,
            locale: locale);
        final l10n = await AppLocalizations.delegate.load(locale);
        final label = type == 'Annuity'
            ? l10n.mortgageAnnuity
            : l10n.mortgageDifferentiated;
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        await _tap(tester, 'mortgage-year-1');
        expect(tester.takeException(), isNull,
            reason: '$type ${locale.languageCode}');
      }
    }
  });
}
