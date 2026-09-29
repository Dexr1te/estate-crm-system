import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/checklist/data/datasources/checklist_remote_datasource.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/domain/repositories/checklist_repository.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDataSource _remote;
  ChecklistRepositoryImpl(this._remote);

  @override
  Future<List<ChecklistItem>> getDealChecklist(int dealId) =>
      _remote.getDealChecklist(dealId);

  @override
  Future<ChecklistItem> addItem(int dealId,
          {required ChecklistStage stage,
          required String title,
          bool required = false}) =>
      _remote.addItem(dealId, stage: stage, title: title, required: required);

  @override
  Future<ChecklistItem> updateItem(int dealId, int itemId,
          {bool? done, int? documentId, bool detachDocument = false}) =>
      _remote.updateItem(dealId, itemId,
          done: done, documentId: documentId, detachDocument: detachDocument);

  @override
  Future<void> deleteItem(int dealId, int itemId) =>
      _remote.deleteItem(dealId, itemId);

  @override
  Future<List<ChecklistItem>> getTemplate() => _remote.getTemplate();

  @override
  Future<List<ChecklistItem>> saveTemplate(List<TemplateLine> lines) =>
      _remote.saveTemplate(lines);
}
