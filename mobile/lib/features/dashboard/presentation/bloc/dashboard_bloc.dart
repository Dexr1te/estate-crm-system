import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState>
    with LoadGeneration {
  final DashboardRepository _dashboard;
  final MeetingsRepository _meetings;
  final DealsRepository _deals;

  DashboardBloc(this._dashboard, this._meetings, this._deals)
      : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoad);
    on<DashboardResetEvent>(_onReset);
  }

  void _onReset(DashboardResetEvent e, Emitter<DashboardState> emit) {
    startLoad();
    emit(DashboardInitial());
  }

  Future<void> _onLoad(
      DashboardLoadEvent e, Emitter<DashboardState> emit) async {
    final ticket = startLoad();
    if (state is! DashboardLoaded) emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _dashboard.getDashboardSummary(),
        _meetings.getMeetings(),
        _deals.getDeals().catchError((_) => <DealResponse>[]),
      ]);

      if (isStale(ticket)) return;

      final now = DateTime.now();
      final upcoming = (results[1] as List<MeetingResponse>)
          .where((m) => !m.completed && m.scheduledAt.isAfter(now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      emit(DashboardLoaded(
        results[0] as DashboardSummary,
        upcoming,
        results[2] as List<DealResponse>,
      ));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(DashboardError(apiErrorMessage(err)));
    }
  }
}
