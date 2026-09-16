import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_state.dart';

/// The agency a manager runs — its people and its unanswered invitations.
///
/// Distinct from [TeamsBloc], which is the administrator's list of every team:
/// a manager has exactly one and needs its members, not its neighbours.
class MyTeamBloc extends Bloc<MyTeamEvent, MyTeamState>
    with SingleFlight, CollectionBloc<MyTeamEvent, MyTeamState> {
  final TeamsRepository _repo;

  MyTeamBloc(this._repo) : super(MyTeamInitial()) {
    on<MyTeamLoadEvent>(_onLoad);
    on<MyTeamRenameEvent>(_onRename);
    on<MyTeamAddMemberEvent>(_onAddMember);
    on<MyTeamRemoveMemberEvent>(_onRemoveMember);
    on<MyTeamCancelRequestEvent>(_onCancelRequest);
  }

  MyTeamLoaded? get _loaded => state is MyTeamLoaded ? state as MyTeamLoaded : null;

  Future<void> _onLoad(MyTeamLoadEvent e, Emitter<MyTeamState> emit) => load(
        emit,
        keepVisible: _loaded != null,
        skeleton: MyTeamLoading(),
        // Three reads that do not depend on each other, so they go together:
        // the screen shows all of it at once anyway.
        fetch: () => Future.wait([
          _repo.getMyTeam(),
          _repo.getMembers(),
          _repo.getOutgoingRequests(),
        ]),
        onData: (parts) => MyTeamLoaded(
          parts[0] as TeamResponse,
          parts[1] as List<TeamMemberResponse>,
          parts[2] as List<TeamJoinRequestResponse>,
        ),
        onFailure: MyTeamError.new,
      );

  /// A write reports on top of the rows already on screen, so a failure leaves
  /// the team visible rather than replacing it with a full-page error.
  Future<void> _act(
    Emitter<MyTeamState> emit,
    String key,
    Future<void> Function() action,
    MyTeamState Function(MyTeamLoaded previous) onSuccess,
  ) {
    final previous = _loaded;
    if (previous == null) return Future.value();
    return write(
      emit,
      key: key,
      perform: action,
      onSuccess: (_) => onSuccess(previous),
      onFailure: (failure) => MyTeamActionFailure(failure, previous),
      reload: () => add(MyTeamLoadEvent()),
    );
  }

  Future<void> _onRename(MyTeamRenameEvent e, Emitter<MyTeamState> emit) =>
      _act(emit, 'rename', () => _repo.renameMyTeam(e.name),
          (prev) => MyTeamActionSuccess(ActionMessage.teamUpdated, prev));

  Future<void> _onAddMember(
      MyTeamAddMemberEvent e, Emitter<MyTeamState> emit) {
    final previous = _loaded;
    if (previous == null) return Future.value();
    return write(
      emit,
      key: 'add-${e.email}',
      perform: () => _repo.addMember(
        email: e.email,
        fullName: e.fullName,
        phone: e.phone,
      ),
      onSuccess: (AddMemberResult result) => MyTeamMemberAdded(result, previous),
      onFailure: (failure) => MyTeamActionFailure(failure, previous),
      reload: () => add(MyTeamLoadEvent()),
    );
  }

  Future<void> _onRemoveMember(
          MyTeamRemoveMemberEvent e, Emitter<MyTeamState> emit) =>
      _act(
          emit,
          'remove-${e.userId}',
          () => _repo.removeMember(e.userId, replacementId: e.replacementId),
          (prev) => MyTeamActionSuccess(ActionMessage.memberRemoved, prev));

  Future<void> _onCancelRequest(
          MyTeamCancelRequestEvent e, Emitter<MyTeamState> emit) =>
      _act(
          emit,
          'cancel-${e.requestId}',
          () => _repo.cancelRequest(e.requestId),
          (prev) => MyTeamActionSuccess(ActionMessage.requestCancelled, prev));
}
