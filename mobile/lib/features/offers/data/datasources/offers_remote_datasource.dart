import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';

class OffersRemoteDataSource {
  final ApiClient _client;
  OffersRemoteDataSource(this._client);

  Future<List<PropertyOffer>> getForProperty(int propertyId) async {
    final res = await _client.dio.get('/properties/$propertyId/offers');
    return jsonArray(res).map(PropertyOffer.fromJson).toList();
  }

  Future<List<PropertyOffer>> getForClient(int clientId) async {
    final res = await _client.dio.get('/clients/$clientId/offers');
    return jsonArray(res).map(PropertyOffer.fromJson).toList();
  }

  Future<PropertyOffer> getOffer(int id) async {
    final res = await _client.dio.get('/offers/$id');
    return PropertyOffer.fromJson(jsonObject(res));
  }

  Future<PropertyOffer> create(int propertyId, OfferDraft draft) async {
    final res = await _client.dio
        .post('/properties/$propertyId/offers', data: draft.toJson());
    return PropertyOffer.fromJson(jsonObject(res));
  }

  Future<PropertyOffer> counter(int id, CounterDraft draft) async {
    final res =
        await _client.dio.post('/offers/$id/counter', data: draft.toJson());
    return PropertyOffer.fromJson(jsonObject(res));
  }

  Future<PropertyOffer> decide(int id, OfferDecision decision,
      {String? note}) async {
    final trimmed = note?.trim() ?? '';
    final res = await _client.dio.post('/offers/$id/${decision.name}',
        data: {if (trimmed.isNotEmpty) 'note': trimmed});
    return PropertyOffer.fromJson(jsonObject(res));
  }
}
