import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_card.dart';
import 'package:real_estate_crm/features/properties/brochure/listing_brochure.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/manager_console_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

String nb(String s) => s.replaceAll(' ', nbsp);

const _team = TeamResponse(id: 1, name: 'Almaty Realty', memberCount: 2);

const _flat = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Dostyk 5',
  city: 'Almaty',
  price: 1250000000,
  areaSqm: 84,
);

Future<void> _show(WidgetTester tester, Widget child,
    {Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    double textScale = 1.0,
    AuthResponse? refreshed}) async {
  AppCurrency.locale = locale.languageCode;
  // Signed in as the manager: the console's export card follows the session.
  await expectNoOverflow(
      tester,
      BlocProvider(
          create: (_) => AuthBloc(FakeAuthRepository(
              user: const AuthResponse(
                  userId: 1,
                  fullName: 'Nurlan Bekov',
                  role: Role.MANAGER,
                  teamId: 1),
              refreshed: refreshed))
            ..add(AuthCheckEvent()),
          child: Scaffold(body: child)),
      size: size,
      brightness: Brightness.light,
      textScale: textScale,
      locale: locale);
  await tester.pumpAndSettle();
}

FakeTeamsRepository _teams() {
  final repo = FakeTeamsRepository(myTeam: _team);
  Injector.teamsRepository = repo;
  return repo;
}

void main() {
  group('the session carries the currency', () {
    Future<AuthBloc> signedIn(AuthResponse user, {AuthResponse? fresh}) async {
      final bloc = AuthBloc(FakeAuthRepository(user: user, refreshed: fresh))
        ..add(AuthCheckEvent());
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s is AuthAuthenticated);
      return bloc;
    }

    test('sign-in sets it, a refresh updates it, sign-out resets it', () async {
      final auth = await signedIn(
        const AuthResponse(userId: 1, teamId: 1, teamCurrency: 'KZT'),
        fresh: const AuthResponse(userId: 1, teamId: 1, teamCurrency: 'RUB'),
      );
      expect(AppCurrency.current, Currency.kzt);

      auth.add(AuthRefreshMeEvent());
      await auth.stream.firstWhere((s) => s is AuthAuthenticated);
      expect(AppCurrency.current, Currency.rub);

      auth.add(AuthLogoutEvent());
      await auth.stream.firstWhere((s) => s is AuthUnauthenticated);
      expect(AppCurrency.current, Currency.usd);
      expect(formatPrice(1000), r'$1,000');
    });

    test('an account with no team, or an old session, reads dollars', () async {
      await signedIn(const AuthResponse(userId: 1));
      expect(AppCurrency.current, Currency.usd);
    });
  });

  group('the manager chooses it', () {
    testWidgets('row, picker, the no-conversion warning, then the change',
        (tester) async {
      final repo = _teams();
      // What /auth/me answers once the server has the new currency.
      await _show(tester, const ManagerConsoleScreen(),
          refreshed: const AuthResponse(
              userId: 1,
              fullName: 'Nurlan Bekov',
              role: Role.MANAGER,
              teamId: 1,
              teamCurrency: 'KZT'));

      final row = find.byKey(const Key('currency-row'));
      expect(row, findsOneWidget);
      expect(find.text('Agency currency'), findsOneWidget);
      expect(find.text(r'US dollar ($)'), findsOneWidget);

      await tester.tap(row);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tenge (₸)'));
      await tester.pumpAndSettle();

      expect(find.text('Change the agency currency?'), findsOneWidget);
      expect(
          find.textContaining(r'Amounts are not converted: a listing priced '
              '\$12,500,000 will read 12,500,000$nbsp₸.'),
          findsOneWidget);
      expect(repo.changedCurrency, isNull, reason: 'nothing before the yes');

      await tester.tap(find.text('Change currency'));
      await tester.pumpAndSettle();

      expect(repo.changedCurrency, 'KZT');
      expect(AppCurrency.current, Currency.kzt);
      expect(find.text('Tenge (₸)'), findsOneWidget,
          reason: 'the row reads the new currency');
      expect(find.text('Currency changed'), findsOneWidget);
    });

    testWidgets('backing out of the warning changes nothing', (tester) async {
      final repo = _teams();
      await _show(tester, const ManagerConsoleScreen());

      await tester.tap(find.byKey(const Key('currency-row')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rouble (₽)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repo.changedCurrency, isNull);
      expect(AppCurrency.current, Currency.usd);
    });

    testWidgets('labels are the currencies\' own names in Russian',
        (tester) async {
      _teams();
      await _show(tester, const ManagerConsoleScreen(),
          locale: const Locale('ru'));
      await tester.tap(find.byKey(const Key('currency-row')));
      await tester.pumpAndSettle();
      for (final label in [
        'Тенге (₸)',
        'Рубль (₽)',
        r'Доллар США ($)',
        'Евро (€)',
        'Узбекский сум (UZS)',
        'Кыргызский сом (KGS)',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });
  });

  group('screens print the agency currency', () {
    testWidgets('a listing card', (tester) async {
      AppCurrency.set(Currency.kzt);
      await _show(tester, PropertyCard(property: _flat, onTap: () {}),
          locale: const Locale('ru'));
      expect(find.text(nb('1,3 млрд ₸')), findsOneWidget);

      AppCurrency.set(Currency.rub);
      await _show(tester, PropertyCard(property: _flat, onTap: () {}),
          locale: const Locale('en'));
      expect(find.text(nb('1.3B ₽')), findsOneWidget);
    });

    testWidgets('the mortgage card on a listing', (tester) async {
      AppCurrency.set(Currency.kzt);
      await _show(
          tester,
          const SingleChildScrollView(
            child: PropertyMortgageCard(
                propertyId: 7, price: 25000000, title: 'Flat 84'),
          ),
          locale: const Locale('ru'));
      final summary = tester
          .widget<Text>(find.byKey(const ValueKey('mortgage-card-summary')));
      expect(summary.data, contains(nb('308 662 ₸')));
      expect(summary.data, isNot(contains(r'$')));
    });

    test('the brochure prints the price in full', () {
      final ru = lookupAppLocalizations(const Locale('ru'));
      final kk = lookupAppLocalizations(const Locale('kk'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(ListingBrochure.priceText(_flat, ru, currency: Currency.kzt),
          nb('1 250 000 000 ₸'));
      expect(ListingBrochure.priceText(_flat, en, currency: Currency.usd),
          r'$1,250,000,000');
      expect(ListingBrochure.perSqmText(_flat, kk, currency: Currency.kgs),
          contains(nb('14 880 952 сом')));
      expect(ListingBrochure.perSqmText(const PropertyResponse(id: 1), en),
          isNull);

      AppCurrency.set(Currency.rub);
      expect(ListingBrochure.priceText(_flat, ru), nb('1 250 000 000 ₽'),
          reason: 'with no currency named it is the agency\'s');
    });
  });

  group('responsive', () {
    for (final locale in const [Locale('ru'), Locale('kk')]) {
      testWidgets(
          'the currency row and picker at 320×568 @1.5 '
          '(${locale.languageCode})', (tester) async {
        _teams();
        await _show(tester, const ManagerConsoleScreen(),
            locale: locale, size: const Size(320, 568), textScale: 1.5);
        await tester.scrollUntilVisible(
            find.byKey(const Key('currency-row')), 100,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(find.byKey(const Key('currency-row')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      for (final currency in const [Currency.kzt, Currency.rub, Currency.uzs]) {
        testWidgets(
            'a listing card with a long ${currency.code} price at 320×568 '
            '@1.5 (${locale.languageCode})', (tester) async {
          AppCurrency.set(currency);
          await _show(
              tester,
              PropertyCard(
                  property: _flat.copyWith(
                      price: 987654321987, title: 'Жилой комплекс «Алатау»'),
                  onTap: () {}),
              locale: locale,
              size: const Size(320, 568),
              textScale: 1.5);
          expect(tester.takeException(), isNull);
          expect(find.textContaining(currency.sign(locale.languageCode)),
              findsWidgets);
        });
      }
    }
  });
}
