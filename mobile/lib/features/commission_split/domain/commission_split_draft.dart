import 'package:real_estate_crm/core/models/models.dart';

/// At most this many parties share one commission; the server says the same.
const kMaxSplitShares = 10;

/// A percentage as typed: "30", "12.5" or "12,5". Null when it is not a
/// number.
double? parseSplitPercent(String text) {
  final cleaned = text.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

/// Hundredths of a percent, so 33.33 + 33.33 + 33.34 is exactly 100.
int splitCents(double percent) => (percent * 100).round();

/// One line of the editor: the deal's agent, a colleague, or a co-broker.
class SplitLineDraft {
  final CommissionPartyKind kind;
  final int? userId;

  /// The person's name, or the co-broker's as typed.
  final String name;
  final String? agency;
  final double? percent;

  const SplitLineDraft({
    required this.kind,
    this.userId,
    required this.name,
    this.agency,
    this.percent,
  });

  bool get isCoBroker => kind == CommissionPartyKind.CO_BROKER;

  /// Above 0 and at most 100, with no more than two decimals. The deal's
  /// agent may hold nothing at all.
  bool get percentValid {
    final p = percent;
    if (p == null) return kind == CommissionPartyKind.AGENT;
    final cents = splitCents(p);
    if ((p * 100 - cents).abs() > 1e-6) return false;
    if (kind == CommissionPartyKind.AGENT) return cents >= 0 && cents <= 10000;
    return cents > 0 && cents <= 10000;
  }

  bool get nameValid => !isCoBroker || name.trim().isNotEmpty;

  Map<String, dynamic>? toJson() {
    final p = percent ?? 0;
    if (kind == CommissionPartyKind.AGENT && splitCents(p) == 0) return null;
    return isCoBroker
        ? {
            'coBrokerName': name.trim(),
            'coBrokerAgency': agency == null || agency!.trim().isEmpty
                ? null
                : agency!.trim(),
            'percent': p,
          }
        : {'userId': userId, 'percent': p};
  }
}

/// The whole split as the editor holds it: the agent's line first.
class CommissionSplitDraft {
  final List<SplitLineDraft> lines;
  const CommissionSplitDraft(this.lines);

  int get totalCents =>
      lines.fold(0, (sum, l) => sum + splitCents(l.percent ?? 0));

  double get total => totalCents / 100;

  bool get totalsHundred => totalCents == 10000;

  bool get tooMany => lines.length > kMaxSplitShares;

  /// Whether the server would take it.
  bool get isValid =>
      totalsHundred &&
      !tooMany &&
      lines.every((l) => l.percentValid && l.nameValid);

  /// Whether it gives the agent everything: no split at all.
  bool get allToAgent => lines.every((l) =>
      l.kind == CommissionPartyKind.AGENT || splitCents(l.percent ?? 0) == 0);

  Map<String, dynamic> toJson() => {
        'shares': [
          for (final l in lines)
            if (l.toJson() case final json?) json,
        ],
      };
}
