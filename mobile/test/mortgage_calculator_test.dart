import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';

/// The arithmetic behind "what would I pay a month?", checked against
/// published reference values rather than against itself.

MortgageResult _calc(double loan, double rate, int months,
        {MortgagePaymentType type = MortgagePaymentType.annuity,
        double down = 0,
        double fees = 0}) =>
    calculateMortgage(MortgageInput(
      price: loan + down,
      downPayment: down,
      annualRatePercent: rate,
      termMonths: months,
      type: type,
      fees: fees,
    ));

void _expectClosesExactly(MortgageResult r) {
  expect(r.months.fold<int>(0, (s, m) => s + m.principalCents), r.loanCents);
  expect(r.months.last.balanceCents, 0);
  for (final m in r.months) {
    expect(m.paymentCents, m.principalCents + m.interestCents);
  }
  expect(r.totalRepaidCents, r.loanCents + r.totalInterestCents);
}

void main() {
  group('annuity', () {
    test('100 000 at 12% for a year pays 8 884.88 a month', () {
      final r = _calc(100000, 12, 12);
      expect(r.firstPaymentCents, 888488);
      expect(r.months.length, 12);
      // 8 884.8789 × 12 − 100 000 = 6 618.55; rounding moves it a cent at most.
      expect(r.totalInterestCents, closeTo(661855, 2));
      expect((r.lastPaymentCents - 888488).abs(), lessThanOrEqualTo(5));
      _expectClosesExactly(r);
    });

    test('200 000 at 6% over 30 years pays 1 199.10 a month', () {
      final r = _calc(200000, 6, 360);
      expect(r.firstPaymentCents, 119910);
      expect(r.months.length, 360);
      expect(r.totalInterestCents, closeTo(23167638, 100));
      _expectClosesExactly(r);
    });

    test('the 7-20-25 shape: 25 000 000 with 20% down at 7% for 25 years', () {
      final r = calculateMortgage(const MortgageInput(
        price: 25000000,
        downPayment: 5000000,
        annualRatePercent: 7,
        termMonths: 300,
      ));
      expect(r.loanCents, 2000000000);
      expect(r.firstPaymentCents, 14135584);
      _expectClosesExactly(r);
    });

    test('0% splits the loan evenly and the last month takes the cents', () {
      final even = _calc(120000, 0, 12);
      expect(even.months.every((m) => m.paymentCents == 1000000), isTrue);
      expect(even.totalInterestCents, 0);

      final odd = _calc(100000, 0, 3);
      expect(
          odd.months.map((m) => m.paymentCents), [3333333, 3333333, 3333334]);
      _expectClosesExactly(odd);
    });

    test('a one-month term repays loan plus one month of interest', () {
      final r = _calc(100000, 12, 1);
      expect(r.months.single.paymentCents, 10100000);
      expect(r.totalInterestCents, 100000);
    });
  });

  group('differentiated', () {
    test('120 000 at 12% for a year: 11 200 first, 10 100 last, 7 800 interest',
        () {
      final r = _calc(120000, 12, 12, type: MortgagePaymentType.differentiated);
      expect(r.firstPaymentCents, 1120000);
      expect(r.lastPaymentCents, 1010000);
      expect(r.months.every((m) => m.principalCents == 1000000), isTrue);
      expect(r.totalInterestCents, 780000);
      expect(r.maxPaymentCents, r.firstPaymentCents);
      _expectClosesExactly(r);
    });

    test('an uneven split still sums to the loan to the cent', () {
      final r = _calc(100000, 9.5, 7, type: MortgagePaymentType.differentiated);
      _expectClosesExactly(r);
      final principals = r.months.map((m) => m.principalCents).toSet();
      expect(principals.every((p) => (p - 1428571).abs() <= 1), isTrue);
    });

    test('costs less interest than annuity over the same term', () {
      final a = _calc(200000, 6, 360);
      final d = _calc(200000, 6, 360, type: MortgagePaymentType.differentiated);
      expect(d.totalInterestCents, lessThan(a.totalInterestCents));
      // Interest on a linear balance: L·r·(n + 1)/2 = 200 000·0.005·361/2 = 180 500.
      expect(d.totalInterestCents, closeTo(18050000, 100));
    });
  });

  group('edges', () {
    test('a down payment of the whole price leaves nothing to borrow', () {
      for (final down in [25000000.0, 30000000.0]) {
        final r = calculateMortgage(MortgageInput(
          price: 25000000,
          downPayment: down,
          annualRatePercent: 18,
          termMonths: 240,
        ));
        expect(r.hasLoan, isFalse);
        expect(r.loanCents, 0);
        expect(r.downPaymentCents, 2500000000);
        expect(r.firstPaymentCents, 0);
        expect(r.overpaymentCents, 0);
      }
    });

    test('a negative down payment or rate counts as none', () {
      final r = calculateMortgage(const MortgageInput(
        price: 1200,
        downPayment: -50,
        annualRatePercent: -3,
        termMonths: 12,
      ));
      expect(r.loanCents, 120000);
      expect(r.firstPaymentCents, 10000);
    });

    test('rounding is to the cent, half away from zero', () {
      expect(toCents(0.005), 1);
      expect(toCents(1234.565), anyOf(123456, 123457));
      expect(fromCents(888488), 8884.88);
    });

    test('fees count toward overpayment, not toward the loan', () {
      final r = _calc(100000, 12, 12, fees: 1500);
      expect(r.loanCents, 10000000);
      expect(r.overpaymentCents, r.totalInterestCents + 150000);
    });

    test('a one-year term makes one schedule year', () {
      final r = _calc(100000, 12, 12);
      expect(r.years.single.months.length, 12);
      expect(r.years.single.principalCents, r.loanCents);
    });

    test('years group twelve months each and keep the totals', () {
      final r = _calc(200000, 6, 360);
      expect(r.years.length, 30);
      expect(r.years.fold<int>(0, (s, y) => s + y.interestCents),
          r.totalInterestCents);
      expect(r.years.last.balanceCents, 0);
    });

    test('income hint is the headline payment over the ratio', () {
      final r = _calc(120000, 12, 12, type: MortgagePaymentType.differentiated);
      expect(r.requiredIncomeCents,
          (r.firstPaymentCents / kMaxPaymentToIncome).round());
      expect(kMaxPaymentToIncome, 0.5);

      final annuity = _calc(20000000, 18, 240);
      expect(annuity.requiredIncomeCents, 61732460,
          reason: 'twice 308 662.30, not twice the cent-settling last month');
    });
  });

  group('settings', () {
    test('survive a round trip and reject nonsense', () {
      const s = MortgageSettings(
          ratePercent: 7,
          termYears: 25,
          type: MortgagePaymentType.differentiated,
          downPercent: 20);
      final back = MortgageSettings.fromJson(s.toJson());
      expect(back.ratePercent, 7);
      expect(back.termYears, 25);
      expect(back.type, MortgagePaymentType.differentiated);
      expect(back.downPercent, 20);

      final junk = MortgageSettings.fromJson(
          {'rate': 'x', 'term': 99, 'type': 'balloon', 'down': 101});
      expect(junk.ratePercent, 18);
      expect(junk.termYears, 20);
      expect(junk.type, MortgagePaymentType.annuity);
      expect(junk.downPercent, 20);
      expect(MortgageSettings.fromJson({'down': -1}).downPercent, 20);
    });

    test('a typed down payment past the slider is remembered, up to 100%', () {
      for (final down in [95.0, 100.0, 0.0]) {
        final s = MortgageSettings(downPercent: down);
        expect(MortgageSettings.fromJson(s.toJson()).downPercent, down);
      }
    });

    test('presets are editable starting points with sane values', () {
      for (final p in kMortgagePresets) {
        expect(p.ratePercent, inInclusiveRange(0, 100));
        if (p.termYears != null) {
          expect(p.termYears, inInclusiveRange(kMinTermYears, kMaxTermYears));
        }
      }
    });
  });
}
