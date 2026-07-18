import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';

// ── Events ──
abstract class AuditLogEvent {}

class AuditLogLoadEvent extends AuditLogEvent {
  final String? entityType;
  AuditLogLoadEvent({this.entityType});
}

// ── States ──
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

// ── Bloc ──
class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  final AdminRepository _repo;
  AuditLogBloc(this._repo) : super(AuditLogInitial()) {
    on<AuditLogLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(AuditLogLoadEvent e, Emitter<AuditLogState> emit) async {
    emit(AuditLogLoading());
    try {
      emit(AuditLogLoaded(await _repo.getAuditLog(entityType: e.entityType)));
    } catch (err) {
      emit(AuditLogError(err.toString()));
    }
  }
}
