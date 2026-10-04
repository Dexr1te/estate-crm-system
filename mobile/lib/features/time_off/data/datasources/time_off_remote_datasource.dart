import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

class TimeOffRemoteDataSource {
  final ApiClient _client;
  TimeOffRemoteDataSource(this._client);

  Future<List<TimeOff>> getTimeOff(
      {required DateTime from, required DateTime to, int? userId}) async {
    final res = await _client.dio.get('/time-off', queryParameters: {
      'from': timeOffDateParam(from),
      'to': timeOffDateParam(to),
      if (userId != null) 'userId': userId,
    });
    return jsonArray(res).map(TimeOff.fromJson).toList();
  }

  Future<TimeOff> getOne(int id) async {
    final res = await _client.dio.get('/time-off/$id');
    return TimeOff.fromJson(jsonObject(res));
  }

  Future<TimeOff> create(TimeOffDraft draft) async {
    final res = await _client.dio.post('/time-off', data: draft.toJson());
    return TimeOff.fromJson(jsonObject(res));
  }

  Future<TimeOff> update(int id, TimeOffDraft draft) async {
    final res = await _client.dio.put('/time-off/$id', data: draft.toJson());
    return TimeOff.fromJson(jsonObject(res));
  }

  Future<void> cancel(int id) async {
    await _client.dio.delete('/time-off/$id');
  }
}
