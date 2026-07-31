
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class MeetingsState {}

class MeetingsInitial extends MeetingsState {}

class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<MeetingResponse> meetings;
  MeetingsLoaded(this.meetings);
}

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [MeetingsActionFailure] instead.
class MeetingsError extends MeetingsState {
  final String message;
  MeetingsError(this.message);
}

/// A write succeeded. Extends [MeetingsLoaded] and carries the list forward so
/// the screen keeps its content while the reload runs.
class MeetingsActionSuccess extends MeetingsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  MeetingsActionSuccess(this.message, super.meetings);
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list rather than replacing the screen with an error page.
class MeetingsActionFailure extends MeetingsLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  MeetingsActionFailure(this.message, super.meetings);
}