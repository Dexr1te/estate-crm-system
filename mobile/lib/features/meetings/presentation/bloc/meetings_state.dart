import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class MeetingsState {}

class MeetingsInitial extends MeetingsState {}

class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<MeetingResponse> meetings;
  MeetingsLoaded(this.meetings);
}

class MeetingsError extends MeetingsState {
  final String message;
  MeetingsError(this.message);
}

class MeetingsActionSuccess extends MeetingsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  MeetingsActionSuccess(this.message, super.meetings);
}

class MeetingsActionFailure extends MeetingsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  MeetingsActionFailure(this.message, super.meetings);
}
