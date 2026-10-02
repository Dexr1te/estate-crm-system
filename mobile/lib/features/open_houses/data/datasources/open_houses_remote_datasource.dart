import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/open_houses/domain/repositories/open_houses_repository.dart';

class OpenHousesRemoteDataSource {
  final ApiClient _client;
  OpenHousesRemoteDataSource(this._client);

  Future<List<OpenHouse>> getForProperty(int propertyId) async {
    final res = await _client.dio.get('/properties/$propertyId/open-houses');
    return jsonArray(res).map(OpenHouse.fromJson).toList();
  }

  Future<List<OpenHouse>> getBetween(DateTime from, DateTime to) async {
    final res = await _client.dio.get('/open-houses', queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return jsonArray(res).map(OpenHouse.fromJson).toList();
  }

  Future<OpenHouse> getOpenHouse(int id) async {
    final res = await _client.dio.get('/open-houses/$id');
    return OpenHouse.fromJson(jsonObject(res));
  }

  Future<OpenHouse> create(int propertyId, OpenHouseDraft draft) async {
    final res = await _client.dio
        .post('/properties/$propertyId/open-houses', data: _draft(draft));
    return OpenHouse.fromJson(jsonObject(res));
  }

  Future<OpenHouse> update(int id, OpenHouseDraft draft) async {
    final res = await _client.dio.put('/open-houses/$id', data: _draft(draft));
    return OpenHouse.fromJson(jsonObject(res));
  }

  Future<void> delete(int id) async {
    await _client.dio.delete('/open-houses/$id');
  }

  Future<OpenHouseVisitor> signIn(int id, VisitorDraft visitor) async {
    final res = await _client.dio.post('/open-houses/$id/visitors', data: {
      'fullName': visitor.fullName,
      'phone': visitor.phone,
      if (visitor.interest != null)
        'interest': switch (visitor.interest!) {
          OpenHouseInterest.interested => 'INTERESTED',
          OpenHouseInterest.justLooking => 'JUST_LOOKING',
        },
      if (visitor.note != null) 'note': visitor.note,
    });
    return OpenHouseVisitor.fromJson(jsonObject(res));
  }

  Future<void> removeVisitor(int id, int visitorId) async {
    await _client.dio.delete('/open-houses/$id/visitors/$visitorId');
  }

  static Map<String, dynamic> _draft(OpenHouseDraft draft) => {
        'startsAt': draft.startsAt.toIso8601String(),
        'endsAt': draft.endsAt.toIso8601String(),
        if (draft.note != null) 'note': draft.note,
      };
}
