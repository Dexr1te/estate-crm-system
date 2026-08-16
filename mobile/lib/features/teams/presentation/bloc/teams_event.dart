abstract class TeamsEvent {}

class TeamsLoadEvent extends TeamsEvent {}

class TeamsCreateEvent extends TeamsEvent {
  final Map<String, dynamic> body;
  TeamsCreateEvent(this.body);
}

class TeamsUpdateEvent extends TeamsEvent {
  final int id;
  final Map<String, dynamic> body;
  TeamsUpdateEvent(this.id, this.body);
}

class TeamsInviteAgentEvent extends TeamsEvent {
  final Map<String, dynamic> body;
  TeamsInviteAgentEvent(this.body);
}
