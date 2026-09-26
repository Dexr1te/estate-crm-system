import 'dart:math' as math;

/// A monthly payment of at most this share of the household's income is what
/// banks usually accept; the income hint is the payment divided by it.
const kMaxPaymentToIncome = 0.5;

const kMaxDownPercent = 90.0;
const kMinTermYears = 1;
const kMaxTermYears = 30;

enum MortgagePaymentType { annuity, differentiated }

class MortgageInput {
  final double price;
  final double downPayment;
  final double annualRatePercent;
  final int termMonths;
  final MortgagePaymentType type;
  final double fees;

  const MortgageInput({
    required this.price,
    required this.downPayment,
    required this.annualRatePercent,
    required this.termMonths,
    this.type = MortgagePaymentType.annuity,
    this.fees = 0,
  });
}

/// One month of the schedule. Amounts are whole cents so that every row adds
/// up exactly and the last payment closes the loan to the cent.
class MortgageMonth {
  final int number;
  final int paymentCents;
  final int principalCents;
  final int interestCents;
  final int balanceCents;

  const MortgageMonth({
    required this.number,
    required this.paymentCents,
    required this.principalCents,
    required this.interestCents,
    required this.balanceCents,
  });
}

class MortgageYear {
  final int number;
  final List<MortgageMonth> months;

  const MortgageYear({required this.number, required this.months});

  int get principalCents => months.fold(0, (s, m) => s + m.principalCents);
  int get interestCents => months.fold(0, (s, m) => s + m.interestCents);
  int get paymentCents => months.fold(0, (s, m) => s + m.paymentCents);
  int get balanceCents => months.isEmpty ? 0 : months.last.balanceCents;
}

class MortgageResult {
  final MortgagePaymentType type;
  final int loanCents;
  final int downPaymentCents;
  final int feesCents;
  final List<MortgageMonth> months;

  const MortgageResult({
    this.type = MortgagePaymentType.annuity,
    required this.loanCents,
    required this.downPaymentCents,
    required this.feesCents,
    required this.months,
  });

  bool get hasLoan => loanCents > 0 && months.isNotEmpty;

  /// Differentiated payments fall month by month, so they read as a range;
  /// an annuity is one figure even when the last month settles a few cents.
  bool get isRange =>
      type == MortgagePaymentType.differentiated && months.length > 1;

  int get firstPaymentCents => months.isEmpty ? 0 : months.first.paymentCents;
  int get lastPaymentCents => months.isEmpty ? 0 : months.last.paymentCents;
  int get maxPaymentCents =>
      months.fold(0, (m, e) => e.paymentCents > m ? e.paymentCents : m);

  int get totalInterestCents => months.fold(0, (s, m) => s + m.interestCents);
  int get totalRepaidCents => months.fold(0, (s, m) => s + m.paymentCents);

  /// What the loan costs above the money borrowed: interest plus fees.
  int get overpaymentCents => totalInterestCents + feesCents;

  /// The headline payment over [kMaxPaymentToIncome]. For an annuity that
  /// is the regular payment (the last month only settles rounding); for a
  /// differentiated loan it is the first month, the largest.
  int get requiredIncomeCents =>
      (firstPaymentCents / kMaxPaymentToIncome).round();

  List<MortgageYear> get years => [
        for (var i = 0; i < months.length; i += 12)
          MortgageYear(
            number: i ~/ 12 + 1,
            months: months.sublist(i, math.min(i + 12, months.length)),
          ),
      ];
}

int toCents(double amount) => (amount * 100).round();
double fromCents(int cents) => cents / 100;

/// Standard formulas: annuity A = L·r / (1 − (1 + r)^−n), differentiated
/// principal L / n plus interest on the balance, r = annual / 12 / 100.
/// The formula runs in doubles; each payment and each month's interest is
/// rounded to the cent and the balance is kept in integer cents, so rounding
/// never drifts and the final month settles whatever is left.
MortgageResult calculateMortgage(MortgageInput input) {
  final priceCents = math.max(0, toCents(input.price));
  final downCents = toCents(input.downPayment).clamp(0, priceCents);
  final feesCents = math.max(0, toCents(input.fees));
  final loan = priceCents - downCents;
  final n = input.termMonths;
  final r = math.max(0.0, input.annualRatePercent) / 12 / 100;

  if (loan <= 0 || n <= 0) {
    return MortgageResult(
        type: input.type,
        loanCents: math.max(0, loan),
        downPaymentCents: downCents,
        feesCents: feesCents,
        months: const []);
  }

  final months = <MortgageMonth>[];
  var balance = loan;
  final annuity = r == 0
      ? (loan / n).round()
      : (loan * r / (1 - math.pow(1 + r, -n))).round();

  for (var k = 1; k <= n; k++) {
    final interest = (balance * r).round();
    int principal;
    if (k == n) {
      principal = balance;
    } else if (input.type == MortgagePaymentType.annuity) {
      principal = math.min(balance, annuity - interest);
    } else {
      principal = (loan * k / n).round() - (loan * (k - 1) / n).round();
    }
    balance -= principal;
    months.add(MortgageMonth(
      number: k,
      paymentCents: principal + interest,
      principalCents: principal,
      interestCents: interest,
      balanceCents: balance,
    ));
  }

  return MortgageResult(
      type: input.type,
      loanCents: loan,
      downPaymentCents: downCents,
      feesCents: feesCents,
      months: months);
}
