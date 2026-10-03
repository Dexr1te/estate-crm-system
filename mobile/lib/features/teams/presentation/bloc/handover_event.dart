/// The parts of an agent's book a handover can take.
enum HandoverPart { clients, listings, deals, upcoming }

abstract class HandoverEvent {}

/// Reads the source agent, who can take over, and the source's clients.
class HandoverLoadEvent extends HandoverEvent {}

class HandoverTargetEvent extends HandoverEvent {
  final int agentId;
  HandoverTargetEvent(this.agentId);
}

class HandoverPartEvent extends HandoverEvent {
  final HandoverPart part;
  final bool on;
  HandoverPartEvent(this.part, this.on);
}

/// Only these clients; null for all of them.
class HandoverClientsEvent extends HandoverEvent {
  final Set<int>? clientIds;
  HandoverClientsEvent(this.clientIds);
}

class HandoverConfirmEvent extends HandoverEvent {}
