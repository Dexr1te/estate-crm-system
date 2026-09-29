import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';

class ChecklistRemoteDataSource {
  final ApiClient _client;
  ChecklistRemoteDataSource(this._client);

  Future<List<ChecklistItem>> getDealChecklist(int dealId) async {
    final res = await _client.dio.get('/deals/$dealId/checklist');
    return jsonArray(res).map(ChecklistItem.fromJson).toList();
  }

  Future<ChecklistItem> addItem(int dealId,
      {required ChecklistStage stage,
      required String title,
      bool required = false}) async {
    final res = await _client.dio.post('/deals/$dealId/checklist',
        data: {'stage': stage.name, 'title': title, 'required': required});
    return ChecklistItem.fromJson(jsonObject(res));
  }

  Future<ChecklistItem> updateItem(int dealId, int itemId,
      {bool? done, int? documentId, bool detachDocument = false}) async {
    final res =
        await _client.dio.patch('/deals/$dealId/checklist/$itemId', data: {
      if (done != null) 'done': done,
      if (documentId != null) 'documentId': documentId,
      if (detachDocument) 'detachDocument': true,
    });
    return ChecklistItem.fromJson(jsonObject(res));
  }

  Future<void> deleteItem(int dealId, int itemId) async {
    await _client.dio.delete('/deals/$dealId/checklist/$itemId');
  }

  Future<List<ChecklistItem>> getTemplate() async {
    final res = await _client.dio.get('/team/checklist-template');
    return jsonArray(res).map(ChecklistItem.fromJson).toList();
  }

  Future<List<ChecklistItem>> saveTemplate(List<TemplateLine> lines) async {
    final res = await _client.dio.put('/team/checklist-template',
        data: {'items': lines.map((l) => l.toJson()).toList()});
    return jsonArray(res).map(ChecklistItem.fromJson).toList();
  }
}
