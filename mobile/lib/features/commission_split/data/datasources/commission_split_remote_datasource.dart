import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';

class CommissionSplitRemoteDataSource {
  final ApiClient _client;
  CommissionSplitRemoteDataSource(this._client);

  Future<CommissionSplit> getSplit(int dealId) async {
    final res = await _client.dio.get('/deals/$dealId/commission-split');
    return CommissionSplit.fromJson(jsonObject(res));
  }

  Future<CommissionSplit> saveSplit(
      int dealId, CommissionSplitDraft draft) async {
    final res = await _client.dio
        .put('/deals/$dealId/commission-split', data: draft.toJson());
    return CommissionSplit.fromJson(jsonObject(res));
  }

  Future<CommissionSplit> clearSplit(int dealId) async {
    final res = await _client.dio.delete('/deals/$dealId/commission-split');
    return CommissionSplit.fromJson(jsonObject(res));
  }
}
