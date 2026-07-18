import 'package:real_estate_crm/core/models/models.dart';

/// Contract for meeting data access.
abstract class MeetingsRepository {
  Future<List<MeetingResponse>> getMeetings({int? agentId});

  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings();

  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId);

  Future<MeetingResponse> getMeeting(int id);

  Future<MeetingResponse> createMeeting(Map<String, dynamic> data);

  Future<MeetingResponse> updateMeeting(int id, Map<String, dynamic> data);

  Future<MeetingResponse> completeMeeting(int id);

  Future<void> deleteMeeting(int id);
}
