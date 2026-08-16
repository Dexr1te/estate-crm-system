import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

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

class TeamsActionSuccess extends TeamsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  TeamsActionSuccess(this.message, super.teams);
}

class TeamsActionFailure extends TeamsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  TeamsActionFailure(this.message, super.teams);
}
