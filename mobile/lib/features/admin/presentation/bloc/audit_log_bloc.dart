import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/audit_log_event.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/audit_log_state.dart';

class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState>
    with SingleFlight, CollectionBloc<AuditLogEvent, AuditLogState> {
  final AdminRepository _repo;

  String? _entityType;

  AuditLogBloc(this._repo) : super(AuditLogInitial()) {
    on<AuditLogLoadEvent>(_onLoad);
  }

  List<AuditLogResponse> get _current {
    final s = state;
    return s is AuditLogLoaded ? s.entries : const [];
  }

  Future<void> _onLoad(AuditLogLoadEvent e, Emitter<AuditLogState> emit) {
    // Narrowing to an entity type is a different question, so it earns the
    // skeleton; pulling the same question down again does not.
    final filterChanged = e.entityType != _entityType;
    _entityType = e.entityType;

    return load(
      emit,
      keepVisible: _current.isNotEmpty && !filterChanged,
      skeleton: AuditLogLoading(),
      fetch: () => _repo.getAuditLog(entityType: e.entityType),
      onData: AuditLogLoaded.new,
      onFailure: AuditLogError.new,
    );
  }
}
