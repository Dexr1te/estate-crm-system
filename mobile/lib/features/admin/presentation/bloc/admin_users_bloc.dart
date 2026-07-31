import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState>
    with LoadGeneration {
  final AdminRepository _repo;
  AdminUsersBloc(this._repo) : super(AdminUsersInitial()) {
    on<AdminUsersLoadEvent>(_onLoad);
    on<AdminInviteUserEvent>(_onInvite);
    on<AdminActivateUserEvent>(_onActivate);
    on<AdminDeactivateUserEvent>(_onDeactivate);
    on<AdminChangeRoleEvent>(_onChangeRole);
    on<AdminAssignTeamEvent>(_onAssignTeam);
    on<AdminResendInviteEvent>(_onResendInvite);
  }

  List<AgentResponse> get _current {
    final s = state;
    return s is AdminUsersLoaded ? s.users : const [];
  }

  AdminUsersState _failure(Object err) => _current.isEmpty
      ? AdminUsersError(apiErrorMessage(err))
      : AdminUsersActionFailure(apiErrorMessage(err), _current);

  Future<void> _onLoad(
      AdminUsersLoadEvent e, Emitter<AdminUsersState> emit) async {
    final ticket = startLoad();
    if (_current.isEmpty) emit(AdminUsersLoading());
    try {
      final users = await _repo.getUsers();
      if (isStale(ticket)) return;
      emit(AdminUsersLoaded(users));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(AdminUsersError(apiErrorMessage(err)));
    }
  }

  Future<void> _act(Emitter<AdminUsersState> emit, String success,
      Future<void> Function() action) async {
    try {
      await action();
      emit(AdminUsersActionSuccess(success, _current));
      add(AdminUsersLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onInvite(
      AdminInviteUserEvent e, Emitter<AdminUsersState> emit) async {
    try {
      final created = await _repo.inviteUser(e.body);
      emit(AdminInviteSuccess(created, _current));
      add(AdminUsersLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onActivate(
          AdminActivateUserEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'User activated', () => _repo.activateUser(e.id));

  Future<void> _onDeactivate(
          AdminDeactivateUserEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'User deactivated', () => _repo.deactivateUser(e.id));

  Future<void> _onChangeRole(
          AdminChangeRoleEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'Role updated', () => _repo.changeRole(e.id, e.role));

  Future<void> _onAssignTeam(
          AdminAssignTeamEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'Team assigned', () => _repo.assignTeam(e.id, e.teamId));

  Future<void> _onResendInvite(
          AdminResendInviteEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'Invite resent', () => _repo.resendInvite(e.id));
}
