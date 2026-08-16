import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class MeetingsState {}

class MeetingsInitial extends MeetingsState {}

class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<MeetingResponse> meetings;
  MeetingsLoaded(this.meetings);
}

class MeetingsError extends MeetingsState {
  final ApiFailure failure;
  MeetingsError(this.failure);
}

class MeetingsActionSuccess extends MeetingsLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  MeetingsActionSuccess(this.message, super.meetings);
}

class MeetingsActionFailure extends MeetingsLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  MeetingsActionFailure(this.failure, super.meetings);
}
