import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';

class DepositsRemoteDataSource {
  final ApiClient _client;
  DepositsRemoteDataSource(this._client);

  Future<List<DealDeposit>> getDealDeposits(int dealId) async {
    final res = await _client.dio.get('/deals/$dealId/deposits');
    return jsonArray(res).map(DealDeposit.fromJson).toList();
  }

  Future<DealDeposit> record(int dealId, DepositDraft draft) async {
    final res =
        await _client.dio.post('/deals/$dealId/deposits', data: draft.toJson());
    return DealDeposit.fromJson(jsonObject(res));
  }

  Future<DealDeposit> update(
      int dealId, int depositId, DepositDraft draft) async {
    final res = await _client.dio
        .put('/deals/$dealId/deposits/$depositId', data: draft.toJson());
    return DealDeposit.fromJson(jsonObject(res));
  }

  Future<DealDeposit> close(
      int dealId, int depositId, DepositClosing closing) async {
    final res = await _client.dio
        .post('/deals/$dealId/deposits/$depositId/close', data: {
      'outcome': closing.outcome.name,
      'closedOn': depositDateParam(closing.closedOn),
    });
    return DealDeposit.fromJson(jsonObject(res));
  }

  Future<List<DealDeposit>> getDepositsEnding() async {
    final res = await _client.dio.get('/deals/deposits-ending');
    return jsonArray(res).map(DealDeposit.fromJson).toList();
  }
}
