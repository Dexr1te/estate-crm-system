import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

abstract class AuditLogState {}

class AuditLogInitial extends AuditLogState {}

class AuditLogLoading extends AuditLogState {}

class AuditLogLoaded extends AuditLogState {
  final List<AuditLogResponse> entries;
  AuditLogLoaded(this.entries);
}

class AuditLogError extends AuditLogState {
  final ApiFailure failure;
  AuditLogError(this.failure);
}
