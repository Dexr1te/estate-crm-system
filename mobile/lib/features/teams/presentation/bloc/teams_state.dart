import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

abstract class TeamsState {}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<TeamResponse> teams;
  TeamsLoaded(this.teams);
}

class TeamsError extends TeamsState {
  final ApiFailure failure;
  TeamsError(this.failure);
}

class TeamsActionSuccess extends TeamsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  TeamsActionSuccess(this.message, super.teams);
}

class TeamsActionFailure extends TeamsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  TeamsActionFailure(this.failure, super.teams);
}
