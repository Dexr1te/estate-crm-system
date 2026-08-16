abstract class AuditLogEvent {}

class AuditLogLoadEvent extends AuditLogEvent {
  final String? entityType;
  AuditLogLoadEvent({this.entityType});
}
