import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboard;
  final MeetingsRepository _meetings;
  DashboardBloc(this._dashboard, this._meetings) : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoad);
  }
  Future<void> _onLoad(
      DashboardLoadEvent e, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _dashboard.getDashboardSummary(),
        _meetings.getUpcomingMeetings(),
      ]);
      emit(DashboardLoaded(results[0] as DashboardSummary,
          results[1] as List<UpcomingMeetingResponse>));
    } catch (err) {
      emit(DashboardError(apiErrorMessage(err)));
    }
  }
}
