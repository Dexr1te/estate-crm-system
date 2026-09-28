import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/domain/repositories/day_route_repository.dart';

sealed class RouteEvent {}

/// Read the day again: on open, on pull, and back from dropping a pin.
class RouteLoadEvent extends RouteEvent {}

class RouteState {
  final DayRoute? route;
  final ApiFailure? failure;

  const RouteState({this.route, this.failure});

  bool get isLoading => route == null && failure == null;
}

/// The day's route: read-only, so nothing here writes or words an outcome.
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final DayRouteRepository _repository;
  final DateTime day;

  RouteBloc(this._repository, this.day) : super(const RouteState()) {
    on<RouteLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(RouteLoadEvent e, Emitter<RouteState> emit) async {
    // A reload keeps the route on screen; only a first read shows skeletons.
    if (state.failure != null) emit(RouteState(route: state.route));
    try {
      final route = await _repository.getDayRoute(day);
      emit(RouteState(route: route));
    } catch (err) {
      emit(RouteState(route: state.route, failure: ApiFailure.from(err)));
    }
  }
}
