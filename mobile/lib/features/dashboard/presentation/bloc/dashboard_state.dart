import 'package:real_estate_crm/core/models/models.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<UpcomingMeetingResponse> upcoming;
  DashboardLoaded(this.summary, this.upcoming);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}