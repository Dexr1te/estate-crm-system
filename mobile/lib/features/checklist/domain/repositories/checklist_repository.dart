import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';

abstract class ChecklistRepository {
  /// A deal's checklist, by stage and position. The server copies the
  /// agency's template onto an older deal the first time it is read.
  Future<List<ChecklistItem>> getDealChecklist(int dealId);

  /// A line of this deal's own; for its agent or a manager.
  Future<ChecklistItem> addItem(int dealId,
      {required ChecklistStage stage,
      required String title,
      bool required = false});

  /// Ticks or un-ticks a line when [done] is given; links one of the deal's
  /// documents when [documentId] is, unlinks it when [detachDocument].
  Future<ChecklistItem> updateItem(int dealId, int itemId,
      {bool? done, int? documentId, bool detachDocument = false});

  Future<void> deleteItem(int dealId, int itemId);

  /// The agency's template; everybody in the agency may read it.
  Future<List<ChecklistItem>> getTemplate();

  /// Replaces the template; the manager's. Order within a stage is kept.
  Future<List<ChecklistItem>> saveTemplate(List<TemplateLine> lines);
}
