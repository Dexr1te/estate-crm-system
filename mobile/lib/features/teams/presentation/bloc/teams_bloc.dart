import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';

// ── Events ──
abstract class TeamsEvent {}

class TeamsLoadEvent extends TeamsEvent {}

class TeamsCreateEvent extends TeamsEvent {
  final Map<String, dynamic> body;
  TeamsCreateEvent(this.body);
}

class TeamsUpdateEvent extends TeamsEvent {
  final int id;
  final Map<String, dynamic> body;
  TeamsUpdateEvent(this.id, this.body);
}

class TeamsInviteAgentEvent extends TeamsEvent {
  final Map<String, dynamic> body;
  TeamsInviteAgentEvent(this.body);
}

// ── States ──
abstract class TeamsState {}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<TeamResponse> teams;
  TeamsLoaded(this.teams);
}

class TeamsError extends TeamsState {
  final String message;
  TeamsError(this.message);
}

class TeamsActionSuccess extends TeamsState {
  final String message;
  TeamsActionSuccess(this.message);
}

// ── Bloc ──
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  final TeamsRepository _repo;
  TeamsBloc(this._repo) : super(TeamsInitial()) {
    on<TeamsLoadEvent>(_onLoad);
    on<TeamsCreateEvent>(_onCreate);
    on<TeamsUpdateEvent>(_onUpdate);
    on<TeamsInviteAgentEvent>(_onInviteAgent);
  }

  Future<void> _onLoad(TeamsLoadEvent e, Emitter<TeamsState> emit) async {
    emit(TeamsLoading());
    try {
      emit(TeamsLoaded(await _repo.getTeams()));
    } catch (err) {
      emit(TeamsError(err.toString()));
    }
  }

  Future<void> _onCreate(TeamsCreateEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.createTeam(e.body);
      emit(TeamsActionSuccess('Team created'));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(TeamsError(err.toString()));
    }
  }

  Future<void> _onUpdate(TeamsUpdateEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.updateTeam(e.id, e.body);
      emit(TeamsActionSuccess('Team updated'));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(TeamsError(err.toString()));
    }
  }

  Future<void> _onInviteAgent(
      TeamsInviteAgentEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.inviteAgentToMyTeam(e.body);
      emit(TeamsActionSuccess('Agent invited'));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(TeamsError(err.toString()));
    }
  }
}
