import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class MyTeamState {}

class MyTeamInitial extends MyTeamState {}

class MyTeamLoading extends MyTeamState {}

class MyTeamLoaded extends MyTeamState {
  final TeamResponse team;
  final List<TeamMemberResponse> members;
  final List<TeamJoinRequestResponse> pending;

  MyTeamLoaded(this.team, this.members, this.pending);
}

class MyTeamError extends MyTeamState {
  final ApiFailure failure;
  MyTeamError(this.failure);
}

class MyTeamActionSuccess extends MyTeamLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  MyTeamActionSuccess(this.message, MyTeamLoaded previous)
      : super(previous.team, previous.members, previous.pending);
}

class MyTeamMemberAdded extends MyTeamLoaded implements ActionOutcome {
  final AddMemberResult result;

  MyTeamMemberAdded(this.result, MyTeamLoaded previous)
      : super(previous.team, previous.members, previous.pending);

  @override
  bool get isFailure => false;

  @override
  String text(l10n) => result.requestSent
      ? l10n.teamsRequestSentBody(result.request?.userFullName ?? '')
      : l10n.teamsInviteSentBody(result.member?.email ?? '');
}

class MyTeamActionFailure extends MyTeamLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  MyTeamActionFailure(this.failure, MyTeamLoaded previous)
      : super(previous.team, previous.members, previous.pending);
}
