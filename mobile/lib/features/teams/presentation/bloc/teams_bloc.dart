import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

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

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [TeamsActionFailure] instead.
class TeamsError extends TeamsState {
  final String message;
  TeamsError(this.message);
}

/// A write succeeded. Extends [TeamsLoaded] and carries the list forward so
/// the console keeps its content while the reload runs.
class TeamsActionSuccess extends TeamsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  TeamsActionSuccess(this.message, super.teams);
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list rather than replacing the console with an error page.
class TeamsActionFailure extends TeamsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  TeamsActionFailure(this.message, super.teams);
}

// ── Bloc ──
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> with LoadGeneration {
  final TeamsRepository _repo;
  TeamsBloc(this._repo) : super(TeamsInitial()) {
    on<TeamsLoadEvent>(_onLoad);
    on<TeamsCreateEvent>(_onCreate);
    on<TeamsUpdateEvent>(_onUpdate);
    on<TeamsInviteAgentEvent>(_onInviteAgent);
  }

  /// Whatever is currently on screen, so a write's outcome can carry it
  /// forward instead of blanking the list.
  List<TeamResponse> get _current {
    final s = state;
    return s is TeamsLoaded ? s.teams : const [];
  }

  /// A write failed. Keep whatever is on screen; only a failed *load* leaves
  /// the user with nothing to look at.
  TeamsState _failure(Object err) => _current.isEmpty
      ? TeamsError(apiErrorMessage(err))
      : TeamsActionFailure(apiErrorMessage(err), _current);

  Future<void> _onLoad(TeamsLoadEvent e, Emitter<TeamsState> emit) async {
    final ticket = startLoad();
    // Only blank the screen when there is nothing to blank. Every screen
    // fires a load in initState and switching tabs remounts it, so emitting
    // Loading unconditionally meant a full-page skeleton on every visit,
    // however fresh the data already was.
    if (_current.isEmpty) emit(TeamsLoading());
    try {
      final teams = await _repo.getTeams();
      // A newer load started while this one was in flight — its result wins.
      if (isStale(ticket)) return;
      emit(TeamsLoaded(teams));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(TeamsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onCreate(TeamsCreateEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.createTeam(e.body);
      emit(TeamsActionSuccess('Team created', _current));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(TeamsUpdateEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.updateTeam(e.id, e.body);
      emit(TeamsActionSuccess('Team updated', _current));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onInviteAgent(
      TeamsInviteAgentEvent e, Emitter<TeamsState> emit) async {
    try {
      await _repo.inviteAgentToMyTeam(e.body);
      emit(TeamsActionSuccess('Agent invited', _current));
      add(TeamsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }
}
