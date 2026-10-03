import 'package:real_estate_crm/core/models/models.dart';

/// One save as the reader thinks of it: the lines the server wrote for one
/// record, by one person, at one moment. A save that moved the price and the
/// rooms is one entry with two lines.
class ChangeEntry {
  final ChangeEntityType? entityType;
  final int entityId;
  final String? entityLabel;
  final int? actorId;
  final String? actorName;
  final DateTime? changedAt;
  final List<RecordChange> lines;

  const ChangeEntry({
    required this.entityType,
    required this.entityId,
    required this.entityLabel,
    required this.actorId,
    required this.actorName,
    required this.changedAt,
    required this.lines,
  });

  /// Whether the record is gone, so there is nothing to open.
  bool get isDeletion => lines.any((l) => l.action == ChangeAction.deleted);

  bool _sameSave(RecordChange c) =>
      c.entityType == entityType &&
      c.entityId == entityId &&
      c.actorId == actorId &&
      c.actorName == actorName &&
      c.changedAt != null &&
      c.changedAt == changedAt;
}

/// Folds a newest-first list of lines into entries, keeping the order. Lines
/// of one save arrive next to each other; within an entry they read in the
/// order the server wrote them, which is the order of the form.
List<ChangeEntry> groupChanges(List<RecordChange> changes) {
  final entries = <ChangeEntry>[];
  for (final c in changes) {
    final last = entries.isEmpty ? null : entries.last;
    if (last != null && last._sameSave(c)) {
      last.lines.add(c);
      continue;
    }
    entries.add(ChangeEntry(
      entityType: c.entityType,
      entityId: c.entityId,
      entityLabel: c.entityLabel,
      actorId: c.actorId,
      actorName: c.actorName,
      changedAt: c.changedAt,
      lines: [c],
    ));
  }
  for (final e in entries) {
    e.lines.sort((a, b) => a.id.compareTo(b.id));
  }
  return entries;
}
