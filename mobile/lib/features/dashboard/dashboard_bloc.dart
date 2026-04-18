// dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';

abstract class DashboardEvent {}

class DashboardLoadEvent extends DashboardEvent {}

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

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiService _api;
  DashboardBloc(this._api) : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoad);
  }
  Future<void> _onLoad(
      DashboardLoadEvent e, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait(
          [_api.getDashboardSummary(), _api.getUpcomingMeetings()]);
      emit(DashboardLoaded(results[0] as DashboardSummary,
          results[1] as List<UpcomingMeetingResponse>));
    } catch (err) {
      emit(DashboardError(err.toString()));
    }
  }
}
