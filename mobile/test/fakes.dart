import 'dart:async';

import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/agents/domain/repositories/agents_repository.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/documents/domain/repositories/documents_repository.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final AuthResponse? user;

  /// What a refreshed session says — how a test moves an agent into a team.
  AuthResponse? refreshed;

  FakeAuthRepository({this.user, this.refreshed});

  @override
  Future<AuthResponse?> getSavedUser() async => user;
  @override
  bool get isLoggedIn => user != null;
  @override
  Future<AuthResponse> login(String email, String password) async => user!;
  @override
  Future<AuthResponse> acceptInvite(String token, String newPassword) async =>
      user!;
  @override
  Future<AuthResponse> updateProfile(String fullName, String email) async {
    updatedProfile = (fullName, email);
    return user!;
  }

  /// The name and address the last profile save sent, if any.
  (String, String)? updatedProfile;

  @override
  Future<void> requestPasswordReset(String email) async =>
      resetRequestedFor = email;

  @override
  Future<AuthResponse> resetPassword(String token, String newPassword) async =>
      user!;

  /// The address the last reset request named, or null if none was made.
  String? resetRequestedFor;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required Role role,
    String? phone,
  }) async =>
      registered = (fullName, email, password, role);

  /// What the last sign-up sent, or null if none was made.
  (String, String, String, Role)? registered;

  @override
  Future<AuthResponse> verifyEmail(String email, String code) async {
    verifiedWith = (email, code);
    return user!;
  }

  /// The address and code the last confirmation sent.
  (String, String)? verifiedWith;

  @override
  Future<void> resendVerification(String email) async => resentFor = email;

  /// The address the last resend named.
  String? resentFor;

  @override
  Future<AuthResponse> refreshMe() async => refreshed ?? user!;

  @override
  Future<void> logout() async {}
  @override
  Future<void> deleteAccount({int? replacementId}) async =>
      deletedWithReplacement = replacementId;

  /// What the last [deleteAccount] handed the records to, or null if it was
  /// never called.
  int? deletedWithReplacement;
}

class FakeDashboardRepository implements DashboardRepository {
  final DashboardSummary summary;
  FakeDashboardRepository(this.summary);
  @override
  Future<DashboardSummary> getDashboardSummary() async => summary;
}

class FakeMeetingsRepository implements MeetingsRepository {
  final List<MeetingResponse> meetings;
  FakeMeetingsRepository(this.meetings);

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) async => meetings;
  @override
  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() async => meetings
      .map((m) => UpcomingMeetingResponse(
          id: m.id,
          title: m.title,
          scheduledAt: m.scheduledAt,
          clientName: m.clientName))
      .toList();
  @override
  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId) async =>
      meetings;
  @override
  Future<MeetingResponse> getMeeting(int id) async =>
      meetings.firstWhere((m) => m.id == id);
  @override
  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<MeetingResponse> updateMeeting(int id, Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<MeetingResponse> completeMeeting(int id) => throw UnimplementedError();
  @override
  Future<MeetingResponse> recordOutcome(
          int id, ViewingOutcome outcome, String? note) async =>
      meetings
          .firstWhere((m) => m.id == id)
          .copyWith(outcome: outcome, outcomeNote: note, completed: true);
  @override
  Future<void> deleteMeeting(int id) => throw UnimplementedError();
}

class FakeDealsRepository implements DealsRepository {
  final List<DealResponse> deals;
  FakeDealsRepository(this.deals);

  @override
  Future<List<DealResponse>> getDeals(
          {int? agentId, DealStatus? status}) async =>
      status == null ? deals : deals.where((d) => d.status == status).toList();
  @override
  Future<DealResponse> getDeal(int id) async =>
      deals.firstWhere((d) => d.id == id);
  @override
  Future<DealResponse> createDeal(Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status) =>
      throw UnimplementedError();
  @override
  Future<void> deleteDeal(int id) => throw UnimplementedError();
}

class FakeClientsRepository implements ClientsRepository {
  final List<ClientResponse> clients;
  final List<ClientListItem> listItems;

  /// What `/clients/{id}/matches` answers. The matching rules themselves live on
  /// the backend and are tested there; a screen test only needs the shapes.
  final List<PropertyMatch> matches;

  FakeClientsRepository({
    this.clients = const [],
    this.listItems = const [],
    this.matches = const [],
  });

  @override
  Future<List<PropertyMatch>> getMatches(int id) async => matches;

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) async =>
      clients.where((c) => _matches(c, search)).toList();

  // The server filters on name, email and phone; global search leans on that,
  // so the fake has to do it too or every query would look like a match.
  static bool _matches(ClientResponse c, String? search) {
    if (search == null || search.trim().isEmpty) return true;
    final q = search.trim().toLowerCase();
    return c.fullName.toLowerCase().contains(q) ||
        (c.email?.toLowerCase().contains(q) ?? false) ||
        (c.phone?.toLowerCase().contains(q) ?? false);
  }

  @override
  Future<List<ClientListItem>> getClientsWithDetails() async => listItems;
  @override
  Future<ClientResponse> getClient(int id) async =>
      clients.firstWhere((c) => c.id == id);
  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<void> deleteClient(int id) => throw UnimplementedError();
}

class FakePropertiesRepository implements PropertiesRepository {
  final List<PropertyResponse> properties;

  /// What `/properties/{id}/interested` answers — see [FakeClientsRepository.matches].
  final List<ClientMatch> interested;

  /// What `/properties/{id}/viewings` answers.
  final List<MeetingResponse> viewings;

  /// The gallery, which uploads and deletions here actually change.
  List<PropertyPhoto> photos;

  /// The bytes every photo reads back as — a real image is not needed to prove
  /// a tile was drawn, and a decode error would say nothing about the code.
  final List<int> photoBytes;

  /// What `/properties/{id}/price-history` answers, newest first.
  final List<PropertyPriceChange> priceHistory;

  FakePropertiesRepository(this.properties,
      {this.interested = const [],
      this.viewings = const [],
      this.photos = const [],
      this.photoBytes = const [],
      this.priceHistory = const []});

  @override
  Future<List<ClientMatch>> getInterested(int id) async => interested;

  @override
  Future<List<MeetingResponse>> getViewings(int id) async => viewings;

  @override
  Future<List<PropertyPriceChange>> getPriceHistory(int id) async =>
      priceHistory;

  @override
  Future<List<PropertyPhoto>> getPhotos(int id) async => photos;

  @override
  Future<PropertyPhoto> addPhoto(int id, String path, String name) async {
    final added = PropertyPhoto(
        id: photos.length + 1,
        propertyId: id,
        fileName: name,
        sortOrder: photos.length);
    photos = [...photos, added];
    return added;
  }

  @override
  Future<List<int>> getPhotoBytes(int id, int photoId) async => photoBytes;

  @override
  Future<List<PropertyPhoto>> reorderPhotos(int id, List<int> photoIds) async {
    final byId = {for (final photo in photos) photo.id: photo};
    photos = [
      for (var i = 0; i < photoIds.length; i++)
        byId[photoIds[i]]!.copyWith(sortOrder: i),
    ];
    return photos;
  }

  @override
  Future<List<int>> getCoverBytes(int id) async {
    if (photos.isEmpty) throw StateError('no cover');
    return photoBytes;
  }

  @override
  Future<void> deletePhoto(int id, int photoId) async {
    photos = photos.where((p) => p.id != photoId).toList();
  }

  @override
  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final filtered = properties
        .where((p) => status == null || p.status == status)
        .where((p) => type == null || p.type == type)
        .where((p) => _matches(p, search))
        .toList();
    return PagedResponse(
      content: filtered,
      page: 0,
      totalPages: 1,
      totalElements: filtered.length,
      isLast: true,
    );
  }

  static bool _matches(PropertyResponse p, String? search) {
    if (search == null || search.trim().isEmpty) return true;
    final q = search.trim().toLowerCase();
    return p.title.toLowerCase().contains(q) ||
        p.address.toLowerCase().contains(q) ||
        (p.city?.toLowerCase().contains(q) ?? false);
  }

  @override
  Future<List<PropertyResponse>> getAllProperties() async => properties;
  @override
  Future<PropertyResponse> getProperty(int id) async =>
      properties.firstWhere((p) => p.id == id);
  @override
  Future<PropertyResponse> createProperty(Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<PropertyResponse> updateProperty(int id, Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override
  Future<PropertyResponse> updatePropertyStatus(
          int id, PropertyStatus status) =>
      throw UnimplementedError();
  @override
  Future<void> deleteProperty(int id) => throw UnimplementedError();
}

/// Records what would have been handed to the OS, so a test can assert on the
/// reminders without a device to deliver them.
class FakeNotificationGateway implements NotificationGateway {
  FakeNotificationGateway({this.permissionGranted = true});

  final bool permissionGranted;
  List<ScheduledNotification> scheduled = const [];
  int cancelAllCount = 0;
  int permissionRequests = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> replaceAll(List<ScheduledNotification> reminders) async {
    scheduled = reminders;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduled = const [];
  }
}

class FakeAgentsRepository implements AgentsRepository {
  final List<AgentOption> agents;
  const FakeAgentsRepository(this.agents);

  @override
  Future<List<AgentOption>> getAgentOptions() async => agents;
}

class FakeAdminRepository implements AdminRepository {
  final List<AgentResponse> users;
  final List<AuditLogResponse> auditLog;
  final AgentStatsResponse stats;

  /// Loads never resolve while true, which is how a skeleton is held still
  /// long enough to be looked at.
  final bool pending;

  FakeAdminRepository({
    this.users = const [],
    this.auditLog = const [],
    this.stats = const AgentStatsResponse(
      agentId: 1,
      fullName: 'Aisha Karimova',
      email: 'aisha@estatecrm.kz',
      isActive: true,
      totalClients: 12,
      totalDeals: 8,
      activeDeals: 3,
      closedDeals: 5,
      upcomingMeetings: 2,
    ),
    this.pending = false,
  });

  Future<T> _answer<T>(T value) =>
      pending ? Completer<T>().future : Future.value(value);

  @override
  Future<List<AgentResponse>> getUsers() => _answer(users);
  @override
  Future<List<AuditLogResponse>> getAuditLog({
    int? actorId,
    String? entityType,
    String? dateFrom,
    String? dateTo,
  }) =>
      _answer(auditLog);
  @override
  Future<AgentStatsResponse> getUserStats(int id) => _answer(stats);
  @override
  Never noSuchMethod(Invocation i) => throw UnimplementedError();
}

class FakeTeamsRepository implements TeamsRepository {
  final List<TeamResponse> teams;
  final TeamStatsResponse stats;
  final bool pending;

  /// The manager's own team, its people, and who has been asked to join.
  final TeamResponse? myTeam;
  final List<TeamMemberResponse> members;
  final List<TeamJoinRequestResponse> requests;

  /// What the next add-by-email answers with.
  AddMemberResult addResult;

  FakeTeamsRepository({
    this.myTeam,
    this.members = const [],
    this.requests = const [],
    this.addResult = const AddMemberResult(requestSent: true),
    this.teams = const [],
    this.stats = const TeamStatsResponse(
      teamId: 1,
      teamName: 'Downtown desk',
      managerName: 'Nurlan Bekov',
      totalAgents: 6,
      totalClients: 40,
      totalDeals: 22,
      activeDeals: 9,
      upcomingMeetings: 4,
    ),
    this.pending = false,
  });

  @override
  Future<List<TeamResponse>> getTeams() =>
      pending ? Completer<List<TeamResponse>>().future : Future.value(teams);
  @override
  Future<TeamStatsResponse> getTeamStats(int id) => Future.value(stats);

  @override
  Future<TeamResponse> getMyTeam() => pending
      ? Completer<TeamResponse>().future
      : Future.value(myTeam ??
          const TeamResponse(id: 1, name: 'Downtown desk', memberCount: 1));

  @override
  Future<List<TeamMemberResponse>> getMembers() => pending
      ? Completer<List<TeamMemberResponse>>().future
      : Future.value(members);

  @override
  Future<List<TeamJoinRequestResponse>> getOutgoingRequests() => pending
      ? Completer<List<TeamJoinRequestResponse>>().future
      : Future.value(requests);

  @override
  Future<List<TeamJoinRequestResponse>> getMyRequests() => pending
      ? Completer<List<TeamJoinRequestResponse>>().future
      : Future.value(requests);

  @override
  Future<AddMemberResult> addMember({
    required String email,
    required String fullName,
    String? phone,
  }) async {
    added = (email, fullName);
    return addResult;
  }

  /// The address and name the last add sent.
  (String, String)? added;

  @override
  Future<void> removeMember(int userId, {int? replacementId}) async =>
      removed = (userId, replacementId);

  /// Who the last removal took off the team, and who inherited their records.
  (int, int?)? removed;

  @override
  Future<void> cancelRequest(int requestId) async => cancelled = requestId;

  /// The request the last withdrawal named.
  int? cancelled;

  @override
  Future<AuthResponse> acceptRequest(int requestId) async {
    accepted = requestId;
    return const AuthResponse(teamId: 1, teamName: 'Downtown desk');
  }

  /// The request the last acceptance named.
  int? accepted;

  @override
  Future<void> declineRequest(int requestId) async => declined = requestId;

  /// The request the last refusal named.
  int? declined;

  @override
  Future<TeamResponse> createMyTeam(String name) async {
    createdTeamName = name;
    return TeamResponse(id: 1, name: name, memberCount: 1);
  }

  /// The name the last agency was created with.
  String? createdTeamName;

  @override
  Future<AuthResponse> leaveTeam() async {
    leftTeam = true;
    return const AuthResponse();
  }

  bool leftTeam = false;

  @override
  Never noSuchMethod(Invocation i) => throw UnimplementedError();
}

class FakeDocumentsRepository implements DocumentsRepository {
  FakeDocumentsRepository([List<DocumentResponse> documents = const []])
      : documents = [...documents];

  final List<DocumentResponse> documents;

  /// What a download hands back.
  List<int> bytes = const [7, 8, 9];

  /// Who the uploaded row comes back attributed to.
  int uploaderId = 5;
  String uploaderName = 'Sultan Assan-Doroshenko';

  PickedFile? uploaded;
  int? downloadedId;
  int? deletedId;

  @override
  Future<List<DocumentResponse>> getDocuments(int dealId) async =>
      List.of(documents);

  @override
  Future<DocumentResponse> uploadDocument(int dealId, PickedFile file) async {
    uploaded = file;
    final created = DocumentResponse(
      id: documents.length + 100,
      fileName: file.name,
      fileType: file.name.split('.').last.toLowerCase(),
      fileSize: file.size,
      dealId: dealId,
      uploadedById: uploaderId,
      uploadedByName: uploaderName,
      uploadedAt: DateTime(2026, 8, 27, 10, 30),
    );
    documents.add(created);
    return created;
  }

  @override
  Future<List<int>> downloadDocument(int dealId, int documentId) async {
    downloadedId = documentId;
    return bytes;
  }

  @override
  Future<void> deleteDocument(int dealId, int documentId) async {
    deletedId = documentId;
    documents.removeWhere((d) => d.id == documentId);
  }
}

/// A phone that always hands back [file] and never actually opens anything.
class FakeFileGateway implements FileGateway {
  FakeFileGateway({
    this.file,
    this.images = const [],
    this.outcome = FileOpenOutcome.opened,
  });

  /// What the picker returns — null stands for backing out of it.
  PickedFile? file;

  /// What the photo picker returns — empty stands for backing out of it.
  List<PickedFile> images;
  FileOpenOutcome outcome;

  String? openedName;
  List<int>? openedBytes;

  @override
  Future<PickedFile?> pickFile() async => file;

  @override
  Future<List<PickedFile>> pickImages() async => images;

  @override
  Future<FileOpenOutcome> openBytes(String fileName, List<int> bytes) async {
    openedName = fileName;
    openedBytes = bytes;
    return outcome;
  }
}
