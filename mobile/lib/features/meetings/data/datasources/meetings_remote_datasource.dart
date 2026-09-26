import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class MeetingsRemoteDataSource {
  final ApiClient _client;
  MeetingsRemoteDataSource(this._client);

  Future<List<MeetingResponse>> getMeetings({int? agentId}) async {
    final res = await _client.dio.get('/meetings', queryParameters: {
      if (agentId != null) 'agentId': agentId,
    });
    return jsonArray(res).map(MeetingResponse.fromJson).toList();
  }

  Future<List<MeetingResponse>> getMeetingsBetween(DateTime from, DateTime to,
      {int? agentId}) async {
    final res = await _client.dio.get('/meetings', queryParameters: {
      if (agentId != null) 'agentId': agentId,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return jsonArray(res).map(MeetingResponse.fromJson).toList();
  }

  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() async {
    final res = await _client.dio.get('/meetings/upcoming');
    return jsonArray(res).map(UpcomingMeetingResponse.fromJson).toList();
  }

  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId) async {
    final res = await _client.dio.get('/meetings/upcoming/agent/$agentId');
    return jsonArray(res).map(MeetingResponse.fromJson).toList();
  }

  Future<MeetingResponse> getMeeting(int id) async {
    final res = await _client.dio.get('/meetings/$id');
    return MeetingResponse.fromJson(jsonObject(res));
  }

  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/meetings', data: data);
    return MeetingResponse.fromJson(jsonObject(res));
  }

  Future<MeetingResponse> updateMeeting(
      int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/meetings/$id', data: data);
    return MeetingResponse.fromJson(jsonObject(res));
  }

  Future<MeetingResponse> recordOutcome(
      int id, ViewingOutcome outcome, String? note) async {
    final res = await _client.dio.patch('/meetings/$id/outcome', data: {
      'outcome': outcome.name,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return MeetingResponse.fromJson(jsonObject(res));
  }

  Future<MeetingResponse> completeMeeting(int id) async {
    final res = await _client.dio.patch('/meetings/$id/complete');
    return MeetingResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteMeeting(int id) async {
    await _client.dio.delete('/meetings/$id');
  }
}
