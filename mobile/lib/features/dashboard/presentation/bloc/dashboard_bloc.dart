import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState>
    with SingleFlight, CollectionBloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboard;
  final MeetingsRepository _meetings;
  final DealsRepository _deals;

  DashboardBloc(this._dashboard, this._meetings, this._deals)
      : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoad);
    on<DashboardResetEvent>(_onReset);
  }

  void _onReset(DashboardResetEvent e, Emitter<DashboardState> emit) {
    invalidate();
    emit(DashboardInitial());
  }

  Future<void> _onLoad(DashboardLoadEvent e, Emitter<DashboardState> emit) =>
      load(
        emit,
        keepVisible: state is DashboardLoaded,
        skeleton: DashboardLoading(),
        fetch: () => Future.wait([
          _dashboard.getDashboardSummary(),
          _meetings.getMeetings(),
          // The pipeline charts degrade to empty rather than taking the
          // dashboard down with them; the calendar does not, because "no
          // meetings today" is a claim, not a blank.
          _deals.getDeals().catchError((_) => <DealResponse>[]),
        ]),
        onData: (results) {
          final now = DateTime.now();
          final upcoming = (results[1] as List<MeetingResponse>)
              .where((m) => !m.completed && m.scheduledAt.isAfter(now))
              .toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

          return DashboardLoaded(
            results[0] as DashboardSummary,
            upcoming,
            results[2] as List<DealResponse>,
          );
        },
        onFailure: DashboardError.new,
      );
}
