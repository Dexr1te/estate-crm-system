import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState>
    with SingleFlight, CollectionBloc<AdminUsersEvent, AdminUsersState> {
  final AdminRepository _repo;

  AdminUsersBloc(this._repo) : super(AdminUsersInitial()) {
    on<AdminUsersLoadEvent>(_onLoad);
    on<AdminInviteUserEvent>(_onInvite);
    on<AdminActivateUserEvent>(_onActivate);
    on<AdminDeactivateUserEvent>(_onDeactivate);
    on<AdminChangeRoleEvent>(_onChangeRole);
    on<AdminAssignTeamEvent>(_onAssignTeam);
    on<AdminResendInviteEvent>(_onResendInvite);
    on<AdminDeleteUserEvent>(_onDelete);
  }

  List<AgentResponse> get _current {
    final s = state;
    return s is AdminUsersLoaded ? s.users : const [];
  }

  AdminUsersState _failure(String message) => _current.isEmpty
      ? AdminUsersError(message)
      : AdminUsersActionFailure(message, _current);

  Future<void> _onLoad(AdminUsersLoadEvent e, Emitter<AdminUsersState> emit) =>
      load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: AdminUsersLoading(),
        fetch: _repo.getUsers,
        onData: AdminUsersLoaded.new,
        onFailure: AdminUsersError.new,
      );

  /// Every user action reads the same: do it, say so, and let the reload put
  /// the row's new shape on screen.
  Future<void> _act(Emitter<AdminUsersState> emit, String key, String success,
          Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) => AdminUsersActionSuccess(success, _current),
        onFailure: _failure,
        reload: () => add(AdminUsersLoadEvent()),
      );

  Future<void> _onInvite(
          AdminInviteUserEvent e, Emitter<AdminUsersState> emit) =>
      write(
        emit,
        // An invite has no id yet, so the address it is going to identifies it.
        key: 'invite-${e.body['email']}',
        perform: () => _repo.inviteUser(e.body),
        onSuccess: (created) => AdminInviteSuccess(created, _current),
        onFailure: _failure,
        reload: () => add(AdminUsersLoadEvent()),
      );

  Future<void> _onDelete(
          AdminDeleteUserEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'delete-${e.id}', 'User deleted',
          () => _repo.deleteUser(e.id, replacementId: e.replacementId));

  Future<void> _onActivate(
          AdminActivateUserEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'activate-${e.id}', 'User activated',
          () => _repo.activateUser(e.id));

  Future<void> _onDeactivate(
          AdminDeactivateUserEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'deactivate-${e.id}', 'User deactivated',
          () => _repo.deactivateUser(e.id));

  Future<void> _onChangeRole(
          AdminChangeRoleEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'role-${e.id}', 'Role updated',
          () => _repo.changeRole(e.id, e.role));

  Future<void> _onAssignTeam(
          AdminAssignTeamEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'team-${e.id}', 'Team assigned',
          () => _repo.assignTeam(e.id, e.teamId));

  Future<void> _onResendInvite(
          AdminResendInviteEvent e, Emitter<AdminUsersState> emit) =>
      _act(emit, 'resend-${e.id}', 'Invite resent',
          () => _repo.resendInvite(e.id));
}
