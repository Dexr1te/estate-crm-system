import 'package:real_estate_crm/core/models/models.dart';

/// How many days ahead a hold's last day counts as ending. The server's
/// /deals/deposits-ending uses the same window.
const kDepositWindowDays = 7;

/// Whole days from [now]'s date to [day]: 0 on the day itself, negative once
/// it has gone. Counted on calendar dates, so the hour changes nothing.
int depositDaysLeft(DateTime day, DateTime now) {
  final today = DateTime.utc(now.year, now.month, now.day);
  final last = DateTime.utc(day.year, day.month, day.day);
  return last.difference(today).inDays;
}

/// Whether an active deposit's hold ends within the window or has ended.
bool depositEnding(DealDeposit d, DateTime now) =>
    d.active && depositDaysLeft(d.holdUntil, now) <= kDepositWindowDays;

/// Whether a listing's deposit hold ends within the window or has ended.
bool depositHoldEnding(PropertyResponse p, DateTime now) {
  final until = p.depositHoldUntil;
  return until != null && depositDaysLeft(until, now) <= kDepositWindowDays;
}

/// The deal's active deposit, if it has one.
DealDeposit? activeDeposit(List<DealDeposit> deposits) {
  for (final d in deposits) {
    if (d.active) return d;
  }
  return null;
}

/// A date as the server takes it: "2026-10-12".
String depositDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// A deposit as recorded or corrected: everything but how it ended.
class DepositDraft {
  final double amount;
  final DateTime receivedOn;
  final DateTime holdUntil;
  final DepositHolder holder;
  final String? note;

  const DepositDraft({
    required this.amount,
    required this.receivedOn,
    required this.holdUntil,
    required this.holder,
    this.note,
  });

  /// Whether the server would take it: more than zero, and the hold not
  /// ending before the money came in.
  bool get isValid => amount > 0 && !holdUntil.isBefore(receivedOn);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'receivedOn': depositDateParam(receivedOn),
        'holdUntil': depositDateParam(holdUntil),
        'holder': holder.name,
        'note': note == null || note!.trim().isEmpty ? null : note!.trim(),
      };
}

/// How a deposit ended, and on which day.
class DepositClosing {
  final DepositOutcome outcome;
  final DateTime closedOn;
  const DepositClosing(this.outcome, this.closedOn);
}
