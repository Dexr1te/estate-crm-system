import 'package:real_estate_crm/core/models/models.dart';

abstract class MeetingsEvent {}

class MeetingsLoadEvent extends MeetingsEvent {}

class MeetingsResetEvent extends MeetingsEvent {}

class MeetingsDeleteEvent extends MeetingsEvent {
  final int id;
  MeetingsDeleteEvent(this.id);
}

class MeetingsCreateEvent extends MeetingsEvent {
  final Map<String, dynamic> data;
  MeetingsCreateEvent(this.data);
}

class MeetingsUpdateEvent extends MeetingsEvent {
  final int id;
  final Map<String, dynamic> data;
  MeetingsUpdateEvent(this.id, this.data);
}

class MeetingsOutcomeEvent extends MeetingsEvent {
  final int id;
  final ViewingOutcome outcome;
  final String? note;
  MeetingsOutcomeEvent(this.id, this.outcome, this.note);
}

class MeetingsCompleteEvent extends MeetingsEvent {
  final int id;
  MeetingsCompleteEvent(this.id);
}
