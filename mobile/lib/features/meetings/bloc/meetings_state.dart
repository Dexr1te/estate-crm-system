
import 'package:real_estate_crm/core/models/models.dart';

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

class MeetingsActionSuccess extends MeetingsState {
  final String message;
  MeetingsActionSuccess(this.message);
}