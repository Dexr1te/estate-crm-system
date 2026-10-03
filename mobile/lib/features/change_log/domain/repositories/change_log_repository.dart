import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';

/// What the agency's change log is narrowed to. Every part is optional; the
/// days are whole days, both included.
class ChangeLogFilter {
  final ChangeEntityType? entityType;
  final int? actorId;
  final DateTime? from;
  final DateTime? to;

  const ChangeLogFilter({this.entityType, this.actorId, this.from, this.to});

  ChangeLogFilter copyWith({
    ChangeEntityType? Function()? entityType,
    int? Function()? actorId,
    DateTime? Function()? from,
    DateTime? Function()? to,
  }) =>
      ChangeLogFilter(
        entityType: entityType == null ? this.entityType : entityType(),
        actorId: actorId == null ? this.actorId : actorId(),
        from: from == null ? this.from : from(),
        to: to == null ? this.to : to(),
      );

  @override
  bool operator ==(Object other) =>
      other is ChangeLogFilter &&
      other.entityType == entityType &&
      other.actorId == actorId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(entityType, actorId, from, to);

  @override
  String toString() =>
      'ChangeLogFilter(entityType: $entityType, actorId: $actorId, '
      'from: $from, to: $to)';
}

abstract class ChangeLogRepository {
  /// One record's changes, newest first, a page at a time. Read by whoever
  /// can see the record.
  Future<PagedResponse<RecordChange>> history(
    ChangeEntityType type,
    int id, {
    int page = 0,
    int size = 30,
  });

  /// The agency's changes, newest first: a manager's, refused to an agent
  /// with MANAGER_ONLY.
  Future<PagedResponse<RecordChange>> feed(
    ChangeLogFilter filter, {
    int page = 0,
    int size = 30,
  });
}
