import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/teams_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/teams_state.dart';

class TeamsBloc extends Bloc<TeamsEvent, TeamsState>
    with SingleFlight, CollectionBloc<TeamsEvent, TeamsState> {
  final TeamsRepository _repo;

  TeamsBloc(this._repo) : super(TeamsInitial()) {
    on<TeamsLoadEvent>(_onLoad);
    on<TeamsCreateEvent>(_onCreate);
    on<TeamsUpdateEvent>(_onUpdate);
    on<TeamsInviteAgentEvent>(_onInviteAgent);
  }

  List<TeamResponse> get _current {
    final s = state;
    return s is TeamsLoaded ? s.teams : const [];
  }

  TeamsState _failure(String message) => _current.isEmpty
      ? TeamsError(message)
      : TeamsActionFailure(message, _current);

  Future<void> _onLoad(TeamsLoadEvent e, Emitter<TeamsState> emit) => load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: TeamsLoading(),
        fetch: _repo.getTeams,
        onData: TeamsLoaded.new,
        onFailure: TeamsError.new,
      );

  Future<void> _act(Emitter<TeamsState> emit, String key, String success,
          Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) => TeamsActionSuccess(success, _current),
        onFailure: _failure,
        reload: () => add(TeamsLoadEvent()),
      );

  Future<void> _onCreate(TeamsCreateEvent e, Emitter<TeamsState> emit) => _act(
      emit,
      'create-${e.body['name']}',
      'Team created',
      () => _repo.createTeam(e.body));

  Future<void> _onUpdate(TeamsUpdateEvent e, Emitter<TeamsState> emit) => _act(
      emit,
      'update-${e.id}',
      'Team updated',
      () => _repo.updateTeam(e.id, e.body));

  Future<void> _onInviteAgent(
          TeamsInviteAgentEvent e, Emitter<TeamsState> emit) =>
      _act(emit, 'invite-${e.body['email']}', 'Agent invited',
          () => _repo.inviteAgentToMyTeam(e.body));
}
