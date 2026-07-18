import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/meetings` endpoints.
class MeetingsRemoteDataSource {
  final ApiClient _client;
  MeetingsRemoteDataSource(this._client);

  Future<List<MeetingResponse>> getMeetings({int? agentId}) async {
    final res = await _client.dio.get('/meetings', queryParameters: {
      if (agentId != null) 'agentId': agentId,
    });
    return (res.data as List).map((e) => MeetingResponse.fromJson(e)).toList();
  }

  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() async {
    final res = await _client.dio.get('/meetings/upcoming');
    return (res.data as List)
        .map((e) => UpcomingMeetingResponse.fromJson(e))
        .toList();
  }

  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId) async {
    final res = await _client.dio.get('/meetings/upcoming/agent/$agentId');
    return (res.data as List).map((e) => MeetingResponse.fromJson(e)).toList();
  }

  Future<MeetingResponse> getMeeting(int id) async {
    final res = await _client.dio.get('/meetings/$id');
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/meetings', data: data);
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> updateMeeting(
      int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/meetings/$id', data: data);
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> completeMeeting(int id) async {
    final res = await _client.dio.patch('/meetings/$id/complete');
    return MeetingResponse.fromJson(res.data);
  }

  Future<void> deleteMeeting(int id) async {
    await _client.dio.delete('/meetings/$id');
  }
}
