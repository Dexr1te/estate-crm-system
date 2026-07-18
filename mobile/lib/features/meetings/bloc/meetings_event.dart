abstract class MeetingsEvent {}

class MeetingsLoadEvent extends MeetingsEvent {}

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

class MeetingsCompleteEvent extends MeetingsEvent {
  final int id;
  MeetingsCompleteEvent(this.id);
}