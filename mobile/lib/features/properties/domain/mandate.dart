import 'package:real_estate_crm/core/models/models.dart';

/// How many days ahead an agreement's last day counts as running out. The
/// server's /properties/mandates-ending uses the same window.
const kMandateWindowDays = 14;

/// Where a listing's seller agreement stands today.
enum MandateUrgency {
  /// No agreement recorded.
  none,

  /// An agreement with no end date, or one ending past the window.
  active,

  /// Its last day is today or within [kMandateWindowDays].
  ending,

  /// Its last day has gone.
  ended,
}

/// Whole days from [now]'s date to the agreement's last day: 0 on the day
/// itself, negative once it has gone. Null without an agreement or an end
/// date. Counted on calendar dates, so the hour of the day changes nothing.
int? mandateDaysLeft(PropertyResponse p, DateTime now) {
  final end = p.mandateEndDate;
  if (p.mandateType == null || end == null) return null;
  final today = DateTime.utc(now.year, now.month, now.day);
  final last = DateTime.utc(end.year, end.month, end.day);
  return last.difference(today).inDays;
}

MandateUrgency mandateUrgency(PropertyResponse p, DateTime now) {
  if (p.mandateType == null) return MandateUrgency.none;
  final days = mandateDaysLeft(p, now);
  if (days == null || days > kMandateWindowDays) return MandateUrgency.active;
  return days < 0 ? MandateUrgency.ended : MandateUrgency.ending;
}

/// Whether the agreement needs the agent now: ending or gone on a listing
/// that is still for sale. A sold listing's agreement no longer matters.
bool mandateNeedsAttention(PropertyResponse p, DateTime now) {
  if (p.status == PropertyStatus.SOLD) return false;
  final urgency = mandateUrgency(p, now);
  return urgency == MandateUrgency.ending || urgency == MandateUrgency.ended;
}
