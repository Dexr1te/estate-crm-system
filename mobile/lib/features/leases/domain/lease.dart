import 'package:real_estate_crm/core/models/models.dart';

/// How many days ahead a lease's last day counts as ending, for the dashboard
/// card and the list. The server's /deals/leases-ending takes the same window.
const kLeaseWindowDays = 30;

/// What the server reminds about when a deal leaves it to the default.
const kDefaultLeaseReminderDays = 30;

/// The reminder lead time the server takes: 1 to 365 days.
const kMaxLeaseReminderDays = 365;

/// Whole days from [now]'s date to [day]: 0 on the day itself, negative once
/// it has gone. Counted on calendar dates, so the hour changes nothing.
int leaseDaysLeft(DateTime day, DateTime now) {
  final today = DateTime.utc(now.year, now.month, now.day);
  final last = DateTime.utc(day.year, day.month, day.day);
  return last.difference(today).inDays;
}

/// Whether a won rent's lease ends within the window (and has not ended).
bool leaseEnding(DealResponse d, DateTime now) {
  final end = d.leaseEnd;
  if (d.kind != DealKind.rent || d.status != DealStatus.CLOSED_WON) {
    return false;
  }
  if (end == null) return false;
  final days = leaseDaysLeft(end, now);
  return days >= 0 && days <= kLeaseWindowDays;
}

/// Only a won rent has a lease to carry on.
bool leaseRenewable(DealResponse d) =>
    d.kind == DealKind.rent &&
    d.status == DealStatus.CLOSED_WON &&
    d.leaseEnd != null;

/// A date as the server takes it: "2026-10-12".
String leaseDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The kind as the server spells it.
String dealKindParam(DealKind kind) => kind == DealKind.rent ? 'RENT' : 'SALE';

/// What a deal adds to the pipeline totals: a sale's price, or the buyer's
/// budget until there is one. A rent adds nothing — a month's rent beside flat
/// prices is not a value of the same kind — the server's totals agree.
double dealSaleValue(DealResponse d) =>
    d.kind == DealKind.rent ? 0 : (d.dealPrice ?? d.budget ?? 0);

/// The amount a deal's card leads with: a sale's price or budget, a rent's
/// monthly rent.
double dealShownAmount(DealResponse d) => d.kind == DealKind.rent
    ? (d.monthlyRent ?? 0)
    : (d.dealPrice ?? d.budget ?? 0);

/// The lease goes on: a later last day, and the new rent when it changed.
class LeaseRenewal {
  final DateTime leaseEnd;
  final double? monthlyRent;

  const LeaseRenewal({required this.leaseEnd, this.monthlyRent});

  Map<String, dynamic> toJson() => {
        'leaseEnd': leaseDateParam(leaseEnd),
        if (monthlyRent != null) 'monthlyRent': monthlyRent,
      };
}
