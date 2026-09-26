import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_state.dart';

abstract class AnalyticsEvent {}

class AnalyticsLoadEvent extends AnalyticsEvent {}

class AnalyticsPeriodChanged extends AnalyticsEvent {
  final AnalyticsPeriod period;
  AnalyticsPeriodChanged(this.period);
}

class AnalyticsAgentChanged extends AnalyticsEvent {
  final int? agentId;
  AnalyticsAgentChanged(this.agentId);
}
