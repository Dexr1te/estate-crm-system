import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repo;
  int _request = 0;

  AnalyticsBloc(this._repo)
      : super(const AnalyticsLoading(AnalyticsPeriod.month, null)) {
    on<AnalyticsLoadEvent>(
        (e, emit) => _load(emit, state.period, state.agentId));
    on<AnalyticsPeriodChanged>(
        (e, emit) => _load(emit, e.period, state.agentId));
    on<AnalyticsAgentChanged>(
        (e, emit) => _load(emit, state.period, e.agentId));
  }

  Future<void> _load(Emitter<AnalyticsState> emit, AnalyticsPeriod period,
      int? agentId) async {
    final request = ++_request;
    final range = AnalyticsRange.of(period, AppClock.now());
    emit(AnalyticsLoading(period, agentId));
    try {
      final funnel = await _repo.getFunnel(
          from: range.from, to: range.to, agentId: agentId);
      if (request != _request) return;
      emit(AnalyticsLoaded(funnel, period, agentId));
    } catch (e) {
      if (request != _request) return;
      emit(AnalyticsError(ApiFailure.from(e), period, agentId));
    }
  }
}
