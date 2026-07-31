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
    // Invalidate any load still in flight, so a response fetched with the old
    // session's token can't repopulate the screen after the reset.
    startLoad();
    emit(DashboardInitial());
  }

  Future<void> _onLoad(
      DashboardLoadEvent e, Emitter<DashboardState> emit) async {
    final ticket = startLoad();
    // Keep the last dashboard on screen while it refreshes. Switching tabs
    // remounts this screen, so blanking unconditionally meant the full
    // skeleton every time the user came back to it.
    if (state is! DashboardLoaded) emit(DashboardLoading());
    try {
      // The pipeline card is a nice-to-have: if `/deals` fails (or the role
      // can't see it) the rest of the dashboard still renders.
      final results = await Future.wait([
        _dashboard.getDashboardSummary(),
        _meetings.getMeetings(),
        _deals.getDeals().catchError((_) => <DealResponse>[]),
      ]);

      // A newer load started while this one was in flight — its result wins.
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
