import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

enum AnalyticsPeriod { month, quarter, year }

class AnalyticsRange {
  final DateTime from;
  final DateTime to;
  const AnalyticsRange(this.from, this.to);

  factory AnalyticsRange.of(AnalyticsPeriod period, DateTime now) {
    switch (period) {
      case AnalyticsPeriod.month:
        final from = DateTime(now.year, now.month);
        return AnalyticsRange(from, DateTime(now.year, now.month + 1));
      case AnalyticsPeriod.quarter:
        final firstMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return AnalyticsRange(
            DateTime(now.year, firstMonth), DateTime(now.year, firstMonth + 3));
      case AnalyticsPeriod.year:
        return AnalyticsRange(DateTime(now.year), DateTime(now.year + 1));
    }
  }
}

abstract class AnalyticsState {
  final AnalyticsPeriod period;
  final int? agentId;
  const AnalyticsState(this.period, this.agentId);
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading(super.period, super.agentId);
}

class AnalyticsLoaded extends AnalyticsState {
  final DealFunnel funnel;

  /// Where the period's clients came from; null when it could not be read,
  /// which hides that section and nothing else.
  final LeadSourceBreakdown? leadSources;

  const AnalyticsLoaded(this.funnel, super.period, super.agentId,
      {this.leadSources});
}

class AnalyticsError extends AnalyticsState {
  final ApiFailure failure;
  const AnalyticsError(this.failure, super.period, super.agentId);
}
