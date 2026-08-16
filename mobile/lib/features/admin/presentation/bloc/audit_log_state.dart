import 'package:real_estate_crm/core/models/admin_models.dart';

abstract class AuditLogState {}

class AuditLogInitial extends AuditLogState {}

class AuditLogLoading extends AuditLogState {}

class AuditLogLoaded extends AuditLogState {
  final List<AuditLogResponse> entries;
  AuditLogLoaded(this.entries);
}

class AuditLogError extends AuditLogState {
  final String message;
  AuditLogError(this.message);
}
