import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/bloc/dashboard_state.dart';

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