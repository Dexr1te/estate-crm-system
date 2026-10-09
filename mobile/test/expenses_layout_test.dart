import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/expenses/presentation/bloc/expense_summary_bloc.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/marketing_spend_card.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/property_expenses_card.dart';

import 'expenses_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// Listing expenses wherever they show — the card on a listing with every
/// payment open, its add sheet, and the marketing spend card on analytics —
/// at every acceptance size, both themes, larger text and all three
/// languages, with tenge, the longest names and notes, and every category.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

Widget _page(Key key, Widget child) => Scaffold(
      key: key,
      body: Builder(
        builder: (context) => SingleChildScrollView(
          padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
          child: child,
        ),
      ),
    );

void _moneyIn(Locale locale) {
  AppCurrency.set(Currency.kzt);
  AppCurrency.locale = locale.languageCode;
}

void main() {
  late FakeExpensesRepository repo;

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(expensesNow);
    repo = FakeExpensesRepository(
      byProperty: {7: longExpenseFixtures()},
      summary: longSummaryFixture,
    );
    Injector.expensesRepository = repo;
  });
  tearDown(() {
    AppClock.reset();
    Injector.expensesRepository = FakeExpensesRepository();
  });

  forEachAcceptanceCase('listing expenses card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      _moneyIn(locale);
      await expectNoOverflow(
        tester,
        _page(ValueKey(locale), const PropertyExpensesCard(propertyId: 7)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'card, ${locale.languageCode}');
      final all = find.byKey(const ValueKey('property-expenses-show-all'));
      await tester.ensureVisible(all);
      await tester.pumpAndSettle();
      await tester.tap(all);
      await _settle(tester, 'every payment, ${locale.languageCode}');
      expect(find.byType(ExpenseRow), findsNWidgets(6));
    }
  });

  forEachAcceptanceCase('listing expenses card — nothing spent',
      (tester, size, brightness, scale) async {
    repo.byProperty = {};
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        _page(ValueKey(locale), const PropertyExpensesCard(propertyId: 7)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'empty card, ${locale.languageCode}');
      expect(
          find.byKey(const ValueKey('property-expenses-none')), findsOneWidget);
    }
  });

  forEachAcceptanceCase('add expense sheet',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      _moneyIn(locale);
      await expectNoOverflow(
        tester,
        _page(ValueKey(locale), const PropertyExpensesCard(propertyId: 7)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'card, ${locale.languageCode}');
      final add = find.byKey(const ValueKey('property-expenses-add'));
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await _settle(tester, 'sheet, ${locale.languageCode}');

      final pill = find.byKey(const Key('expense-category-legal'));
      await tester.ensureVisible(pill);
      await tester.pumpAndSettle();
      await tester.tap(pill);
      for (final (key, text) in [
        ('expense-amount', '1234567.89'),
        ('expense-note', 'x' * 501),
      ]) {
        final field = find.byKey(Key(key));
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, text);
      }
      await _settle(tester, 'sheet with a long note, ${locale.languageCode}');
      expect(find.byKey(const Key('expense-note-too-long')), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await _settle(tester, 'sheet closed, ${locale.languageCode}');
    }
  });

  forEachAcceptanceCase('marketing spend card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      _moneyIn(locale);
      final bloc = ExpenseSummaryBloc(repo)
        ..add(ExpenseSummaryLoadEvent(
            from: DateTime(2026), to: DateTime(2026, 12, 31)));
      addTearDown(bloc.close);
      await expectNoOverflow(
        tester,
        _page(
          ValueKey(locale),
          BlocProvider.value(
            value: bloc,
            child: MarketingSpendCard(onOpenListing: (_) {}),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'spend, ${locale.languageCode}');
      expect(
          find.byKey(const ValueKey('marketing-spend-total')), findsOneWidget);
      expect(find.byKey(const ValueKey('marketing-spend-listing-204')),
          findsOneWidget);
    }
  });

  forEachAcceptanceCase('marketing spend card — failed',
      (tester, size, brightness, scale) async {
    repo.summaryError = Exception('offline');
    for (final locale in kAcceptanceLocales) {
      final bloc = ExpenseSummaryBloc(repo)
        ..add(ExpenseSummaryLoadEvent(
            from: DateTime(2026, 9), to: DateTime(2026, 9, 30)));
      addTearDown(bloc.close);
      await expectNoOverflow(
        tester,
        _page(
          ValueKey(locale),
          BlocProvider.value(value: bloc, child: const MarketingSpendCard()),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'spend failed, ${locale.languageCode}');
      expect(
          find.byKey(const ValueKey('marketing-spend-retry')), findsOneWidget);
    }
  });
}
