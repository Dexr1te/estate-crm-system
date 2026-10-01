import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The share of the month's target done, 0 to 1, for a ring or a bar: the
/// commission when there is a commission target, the deals otherwise.
double goalFraction(GoalProgress goal) {
  final percent = goal.commissionTarget != null
      ? goal.commissionPercent
      : goal.dealsPercent;
  if (percent == null) return 0;
  return (percent / 100).clamp(0.0, 1.0);
}

/// The percentage the ring shows, the same figure [goalFraction] draws.
int? goalPercent(GoalProgress goal) =>
    goal.commissionTarget != null ? goal.commissionPercent : goal.dealsPercent;

/// Every target that is set has been met.
bool goalReached(GoalProgress goal) {
  if (!goal.hasTarget) return false;
  final commission = goal.commissionTarget;
  final deals = goal.dealsTarget;
  return (commission == null || goal.commissionAchieved >= commission) &&
      (deals == null || goal.dealsWon >= deals);
}

/// Deals still to win; 0 without a deals target or once it is met.
int dealsToGo(GoalProgress goal) {
  final target = goal.dealsTarget;
  if (target == null || goal.dealsWon >= target) return 0;
  return target - goal.dealsWon;
}

/// "12 days left · 250K a day · a deal every 4 days": how much each day that
/// is left has to bring. The deals are said the way people count them, so
/// two deals in twelve days is one every six days, not 0.17 a day.
String goalPace(AppLocalizations l10n, GoalProgress goal) {
  final parts = <String>[l10n.goalsDaysLeft(goal.daysLeft)];
  final perDay = goal.commissionPerDay;
  if (perDay != null && perDay > 0) {
    parts.add(l10n.goalsPerDay(formatPrice(perDay)));
  }
  final togo = dealsToGo(goal);
  final days = goal.daysLeft;
  if (togo > 0 && days > 0) {
    parts.add(togo * 2 > days
        ? l10n.goalsDealsPerDay((togo / days).ceil())
        : l10n.goalsDealEvery(days ~/ togo));
  }
  return parts.join(' · ');
}
