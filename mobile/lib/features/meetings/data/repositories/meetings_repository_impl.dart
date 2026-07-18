import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/meetings/data/datasources/meetings_remote_datasource.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';

class MeetingsRepositoryImpl implements MeetingsRepository {
  final MeetingsRemoteDataSource _remote;
  MeetingsRepositoryImpl(this._remote);

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) =>
      _remote.getMeetings(agentId: agentId);

  @override
  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() =>
      _remote.getUpcomingMeetings();

  @override
  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId) =>
      _remote.getUpcomingMeetingsByAgent(agentId);

  @override
  Future<MeetingResponse> getMeeting(int id) => _remote.getMeeting(id);

  @override
  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) =>
      _remote.createMeeting(data);

  @override
  Future<MeetingResponse> updateMeeting(int id, Map<String, dynamic> data) =>
      _remote.updateMeeting(id, data);

  @override
  Future<MeetingResponse> completeMeeting(int id) => _remote.completeMeeting(id);

  @override
  Future<void> deleteMeeting(int id) => _remote.deleteMeeting(id);
}
