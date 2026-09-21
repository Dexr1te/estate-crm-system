import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';

abstract class JoinRequestsEvent {}

class JoinRequestsLoadEvent extends JoinRequestsEvent {}

class JoinRequestsAcceptEvent extends JoinRequestsEvent {
  final int requestId;
  JoinRequestsAcceptEvent(this.requestId);
}

class JoinRequestsDeclineEvent extends JoinRequestsEvent {
  final int requestId;
  JoinRequestsDeclineEvent(this.requestId);
}

abstract class JoinRequestsState {}

class JoinRequestsInitial extends JoinRequestsState {}

class JoinRequestsLoading extends JoinRequestsState {}

class JoinRequestsLoaded extends JoinRequestsState {
  final List<TeamJoinRequestResponse> requests;
  JoinRequestsLoaded(this.requests);
}

class JoinRequestsError extends JoinRequestsState {
  final ApiFailure failure;
  JoinRequestsError(this.failure);
}

class JoinRequestsAccepted extends JoinRequestsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  JoinRequestsAccepted(super.requests, this.message);
}

class JoinRequestsActionSuccess extends JoinRequestsLoaded
    with ActionSucceeded {
  @override
  final ActionMessage message;

  JoinRequestsActionSuccess(super.requests, this.message);
}

class JoinRequestsActionFailure extends JoinRequestsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  JoinRequestsActionFailure(super.requests, this.failure);
}

class JoinRequestsBloc extends Bloc<JoinRequestsEvent, JoinRequestsState>
    with SingleFlight, CollectionBloc<JoinRequestsEvent, JoinRequestsState> {
  final TeamsRepository _repo;

  JoinRequestsBloc(this._repo) : super(JoinRequestsInitial()) {
    on<JoinRequestsLoadEvent>(_onLoad);
    on<JoinRequestsAcceptEvent>(_onAccept);
    on<JoinRequestsDeclineEvent>(_onDecline);
  }

  List<TeamJoinRequestResponse> get _current {
    final s = state;
    return s is JoinRequestsLoaded ? s.requests : const [];
  }

  Future<void> _onLoad(
          JoinRequestsLoadEvent e, Emitter<JoinRequestsState> emit) =>
      load(
        emit,
        keepVisible: state is JoinRequestsLoaded,
        skeleton: JoinRequestsLoading(),
        fetch: _repo.getMyRequests,
        onData: JoinRequestsLoaded.new,
        onFailure: JoinRequestsError.new,
      );

  Future<void> _onAccept(
          JoinRequestsAcceptEvent e, Emitter<JoinRequestsState> emit) =>
      write(
        emit,
        key: 'accept-${e.requestId}',
        perform: () => _repo.acceptRequest(e.requestId),
        onSuccess: (_) =>
            JoinRequestsAccepted(const [], ActionMessage.teamJoined),
        onFailure: (failure) => JoinRequestsActionFailure(_current, failure),
      );

  Future<void> _onDecline(
          JoinRequestsDeclineEvent e, Emitter<JoinRequestsState> emit) =>
      write(
        emit,
        key: 'decline-${e.requestId}',
        perform: () => _repo.declineRequest(e.requestId),
        onSuccess: (_) => JoinRequestsActionSuccess(
            _current.where((r) => r.id != e.requestId).toList(),
            ActionMessage.requestDeclined),
        onFailure: (failure) => JoinRequestsActionFailure(_current, failure),
        reload: () => add(JoinRequestsLoadEvent()),
      );
}
