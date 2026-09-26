import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';

enum MortgagePresetKind { market, stateProgram, housingSavings }

/// A starting point, not a bank's offer. Rates and programme terms change;
/// every value lands in an editable field and the screen says to check with
/// the bank. This list is the one place to update them.
class MortgagePreset {
  final MortgagePresetKind kind;
  final double ratePercent;
  final int? termYears;
  final double? downPercent;

  const MortgagePreset({
    required this.kind,
    required this.ratePercent,
    this.termYears,
    this.downPercent,
  });
}

const kMortgagePresets = <MortgagePreset>[
  MortgagePreset(kind: MortgagePresetKind.market, ratePercent: 18),
  MortgagePreset(
    kind: MortgagePresetKind.stateProgram,
    ratePercent: 7,
    termYears: 25,
    downPercent: 20,
  ),
  MortgagePreset(kind: MortgagePresetKind.housingSavings, ratePercent: 5),
];

class MortgageSettings {
  final double ratePercent;
  final int termYears;
  final MortgagePaymentType type;
  final double downPercent;

  const MortgageSettings({
    this.ratePercent = 18,
    this.termYears = 20,
    this.type = MortgagePaymentType.annuity,
    this.downPercent = 20,
  });

  MortgageSettings copyWith({
    double? ratePercent,
    int? termYears,
    MortgagePaymentType? type,
    double? downPercent,
  }) =>
      MortgageSettings(
        ratePercent: ratePercent ?? this.ratePercent,
        termYears: termYears ?? this.termYears,
        type: type ?? this.type,
        downPercent: downPercent ?? this.downPercent,
      );

  MortgageInput inputFor(double price, {double fees = 0}) => MortgageInput(
        price: price,
        downPayment: price * downPercent / 100,
        annualRatePercent: ratePercent,
        termMonths: termYears * 12,
        type: type,
        fees: fees,
      );

  Map<String, Object> toJson() => {
        'rate': ratePercent,
        'term': termYears,
        'type': type.name,
        'down': downPercent,
      };

  static MortgageSettings fromJson(Map<String, dynamic> json) {
    const d = MortgageSettings();
    final rate = json['rate'];
    final term = json['term'];
    final down = json['down'];
    return MortgageSettings(
      ratePercent: rate is num && rate >= 0 && rate <= 100
          ? rate.toDouble()
          : d.ratePercent,
      termYears: term is int && term >= kMinTermYears && term <= kMaxTermYears
          ? term
          : d.termYears,
      type: MortgagePaymentType.values
          .firstWhere((t) => t.name == json['type'], orElse: () => d.type),
      downPercent: down is num && down >= 0 && down <= kMaxDownPercent
          ? down.toDouble()
          : d.downPercent,
    );
  }
}
