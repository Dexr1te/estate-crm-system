import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:quick_actions/quick_actions.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/agents/domain/repositories/agents_repository.dart';
import 'package:real_estate_crm/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:real_estate_crm/features/app_lock/data/app_lock_repository_impl.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deal_comments_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/documents/domain/repositories/documents_repository.dart';
import 'package:real_estate_crm/features/exports/domain/repositories/exports_repository.dart';
import 'package:real_estate_crm/features/imports/domain/repositories/imports_repository.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/message_templates/domain/repositories/message_templates_repository.dart';
import 'package:real_estate_crm/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:real_estate_crm/features/properties/domain/map_area.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';
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

  /// Every `[from, to)` window asked for, in order.
  final List<(DateTime, DateTime)> ranges = [];

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) async => meetings;
  @override
  Future<List<MeetingResponse>> getMeetingsBetween(DateTime from, DateTime to,
      {int? agentId}) async {
    ranges.add((from, to));
    return meetings
        .where(
            (m) => !m.scheduledAt.isBefore(from) && m.scheduledAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

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
  Future<DealResponse> updateDealStatus(int id, DealStatus status,
          {DealLostReason? lostReason, String? lostNote}) =>
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

  /// The history of contact, which logging and deleting here actually change.
  List<ClientActivity> activities;

  /// When set, reading the history fails with it — the card's own error state.
  Object? activitiesError;

  /// When set, logging a contact fails with it and nothing is added.
  Object? logError;

  /// Every log attempt, successful or not, in order.
  final List<
      ({
        ActivityType type,
        DateTime? occurredAt,
        List<int> propertyIds,
        String? note
      })> logCalls = [];

  /// What `/clients/duplicates` answers, whatever was asked — the matching
  /// rules live on the backend and are tested there.
  final List<ClientDuplicate> duplicates;

  /// Every duplicate lookup made, as `(phone, email, excludeId)`.
  final List<(String?, String?, int?)> duplicateQueries = [];

  /// Every merge made, as `(targetId, sourceId)`.
  final List<(int, int)> merges = [];

  /// When set, a merge fails with it.
  Object? mergeError;

  FakeClientsRepository({
    this.clients = const [],
    this.listItems = const [],
    this.matches = const [],
    this.activities = const [],
    this.activitiesError,
    this.logError,
    this.duplicates = const [],
    this.mergeError,
  });

  @override
  Future<List<ClientDuplicate>> findDuplicates({
    String? phone,
    String? email,
    int? excludeId,
  }) async {
    duplicateQueries.add((phone, email, excludeId));
    return duplicates.where((d) => d.id != excludeId).toList();
  }

  @override
  Future<ClientResponse> mergeClients(int targetId, int sourceId) async {
    if (mergeError != null) throw mergeError!;
    merges.add((targetId, sourceId));
    return clients.firstWhere((c) => c.id == targetId);
  }

  @override
  Future<List<ClientActivity>> getActivities(int clientId) async {
    if (activitiesError != null) throw activitiesError!;
    return activities.where((a) => a.clientId == clientId).toList();
  }

  @override
  Future<ClientActivity> logActivity(
    int clientId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
    List<int> propertyIds = const [],
  }) async {
    logCalls.add((
      type: type,
      occurredAt: occurredAt,
      propertyIds: propertyIds,
      note: note
    ));
    if (logError != null) throw logError!;
    final logged = ClientActivity(
      id: activities.fold<int>(0, (m, a) => a.id > m ? a.id : m) + 1,
      clientId: clientId,
      type: type,
      note: note,
      occurredAt: occurredAt ?? AppClock.now(),
      authorId: 5,
      authorName: 'Maria Kim-Doroshenko',
      properties: [
        for (final id in propertyIds)
          ActivityProperty(
            id: id,
            title: matches
                    .where((m) => m.property.id == id)
                    .map((m) => m.property.title)
                    .firstOrNull ??
                'Listing $id',
          ),
      ],
    );
    activities = [logged, ...activities];
    return logged;
  }

  @override
  Future<ClientActivity> updateActivity(
    int clientId,
    int activityId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
  }) async {
    if (logError != null) throw logError!;
    final current = activities.firstWhere((a) => a.id == activityId);
    final updated = current.copyWith(
        type: type, note: note, occurredAt: occurredAt ?? current.occurredAt);
    activities = [
      for (final a in activities) a.id == activityId ? updated : a,
    ];
    return updated;
  }

  @override
  Future<void> deleteActivity(int clientId, int activityId) async {
    activities = activities.where((a) => a.id != activityId).toList();
  }

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

  /// Every client created through the fake, as sent.
  final List<Map<String, dynamic>> created = [];

  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) async {
    created.add(data);
    return ClientResponse(
        id: 1000 + created.length, fullName: data['fullName'] as String);
  }

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

  /// What `/properties/{id}/report` answers; an empty report by default.
  SellerReport? sellerReport;

  /// When set, reading the report fails with it — the screen's error state.
  Object? sellerReportError;

  /// Every report read, so a retry can be told from the first load.
  int sellerReportReads = 0;

  @override
  Future<SellerReport> getSellerReport(int id) async {
    sellerReportReads++;
    final error = sellerReportError;
    if (error != null) throw error;
    return sellerReport ?? SellerReport(propertyId: id);
  }

  /// What `/properties/{id}/price-insight` answers. Insufficient by default —
  /// no comparables — so a screen that is not about pricing draws no card.
  PriceInsight priceInsight = const PriceInsight();

  /// What `/properties/price-insight` answers while the form is being typed.
  PriceInsight formInsight = const PriceInsight();

  /// Every insight the form asked for, as the query it would have sent.
  final List<Map<String, Object?>> insightRequests = [];

  @override
  Future<PriceInsight> getPriceInsightFor(int id) async => priceInsight;

  @override
  Future<PriceInsight> getPriceInsight({
    required String city,
    required PropertyType type,
    int? rooms,
    double? areaSqm,
    int? excludeId,
  }) async {
    insightRequests.add({
      'city': city,
      'type': type,
      'rooms': rooms,
      'areaSqm': areaSqm,
      'excludeId': excludeId,
    });
    return formInsight;
  }

  @override
  Future<List<PropertyPhoto>> getPhotos(int id) async => photos;

  /// Each listing's working public link, which creating and revoking change.
  final Map<int, PropertyShareLink> shareLinks = {};

  /// Every listing a link was asked for, in order — repeats included.
  final List<int> shareLinkRequests = [];

  /// Listings whose link was switched off.
  final List<int> revokedShareLinks = [];

  /// When set, making a link fails the way a dropped connection would.
  bool failShareLinks = false;

  static String shareUrlFor(int id) => 'https://crm.test/api/l/token-$id';

  @override
  Future<PropertyShareLink> getShareLink(int id) async =>
      shareLinks[id] ?? const PropertyShareLink();

  @override
  Future<PropertyShareLink> createShareLink(int id) async {
    shareLinkRequests.add(id);
    if (failShareLinks) throw StateError('offline');
    return shareLinks[id] ??= PropertyShareLink(
        url: shareUrlFor(id), createdAt: DateTime(2026, 9, 20));
  }

  @override
  Future<void> revokeShareLink(int id) async {
    revokedShareLinks.add(id);
    shareLinks.remove(id);
  }

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

  /// Every rectangle the map asked for, in order, with the status filter it
  /// was asked under.
  final List<MapArea> areaRequests = [];
  final List<PropertyStatus?> areaStatuses = [];

  @override
  Future<PagedResponse<PropertyResponse>> getPropertiesInArea(
    MapArea area, {
    PropertyStatus? status,
    PropertyType? type,
    String? search,
    int size = 200,
  }) async {
    areaRequests.add(area);
    areaStatuses.add(status);
    final inside = properties
        .where((p) => p.latitude != null && p.longitude != null)
        .where((p) => p.latitude! >= area.south && p.latitude! <= area.north)
        .where((p) => area.west <= area.east
            ? p.longitude! >= area.west && p.longitude! <= area.east
            : p.longitude! >= area.west || p.longitude! <= area.east)
        .where((p) => status == null || p.status == status)
        .where((p) => type == null || p.type == type)
        .where((p) => _matches(p, search))
        .take(size)
        .toList();
    return PagedResponse(
      content: inside,
      page: 0,
      totalPages: 1,
      totalElements: inside.length,
      isLast: true,
    );
  }

  @override
  Future<PagedResponse<PropertyResponse>> getPropertiesWithoutLocation({
    PropertyStatus? status,
    PropertyType? type,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final unpinned = properties
        .where((p) => p.latitude == null || p.longitude == null)
        .where((p) => status == null || p.status == status)
        .where((p) => type == null || p.type == type)
        .where((p) => _matches(p, search))
        .toList();
    return PagedResponse(
      content: unpinned,
      page: 0,
      totalPages: 1,
      totalElements: unpinned.length,
      isLast: true,
    );
  }

  /// What the form last sent, create or update, keyed `create`/`update-<id>`.
  final Map<String, Map<String, dynamic>> sent = {};

  static bool _matches(PropertyResponse p, String? search) {
    if (search == null || search.trim().isEmpty) return true;
    final q = search.trim().toLowerCase();
    return p.title.toLowerCase().contains(q) ||
        p.address.toLowerCase().contains(q) ||
        (p.city?.toLowerCase().contains(q) ?? false);
  }

  @override
  Future<List<PropertyResponse>> getAllProperties() async => properties;

  /// What `/properties/mandates-ending` answers, soonest first.
  List<PropertyResponse> mandatesEnding = const [];

  /// When set, the running-out list fails the way a dropped connection would.
  bool failMandates = false;

  /// How many times the running-out list was asked for.
  int mandatesRequests = 0;

  @override
  Future<List<PropertyResponse>> getMandatesEnding() async {
    mandatesRequests++;
    if (failMandates) throw StateError('offline');
    return mandatesEnding;
  }

  @override
  Future<PropertyResponse> getProperty(int id) async =>
      properties.firstWhere((p) => p.id == id);
  @override
  Future<PropertyResponse> createProperty(Map<String, dynamic> data) async {
    sent['create'] = data;
    return PropertyResponse.fromJson({...data, 'id': 900 + sent.length});
  }

  @override
  Future<PropertyResponse> updateProperty(
      int id, Map<String, dynamic> data) async {
    sent['update-$id'] = data;
    return PropertyResponse.fromJson({...data, 'id': id});
  }

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

/// Answers every funnel request with [funnel] and records what was asked.
class FakeAnalyticsRepository implements AnalyticsRepository {
  DealFunnel funnel;
  final requests = <({DateTime from, DateTime to, int? agentId})>[];
  Object? error;

  FakeAnalyticsRepository(this.funnel);

  @override
  Future<DealFunnel> getFunnel(
      {required DateTime from, required DateTime to, int? agentId}) async {
    requests.add((from: from, to: to, agentId: agentId));
    if (error != null) throw error!;
    return funnel;
  }
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
  Future<TeamResponse> changeMyCurrency(String code) async {
    changedCurrency = code;
    final t = myTeam;
    return TeamResponse(
        id: t?.id ?? 1,
        name: t?.name ?? 'Downtown desk',
        memberCount: t?.memberCount ?? 1,
        currency: code);
  }

  /// The currency code the last change asked for.
  String? changedCurrency;

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

class FakeShareGateway implements ShareGateway {
  FakeShareGateway({this.outcome = ShareOutcome.shared});

  ShareOutcome outcome;

  String? sharedText;
  List<SharedImage> sharedImages = const [];
  int calls = 0;

  @override
  Future<ShareOutcome> share({
    required String text,
    String? subject,
    List<SharedImage> images = const [],
  }) async {
    calls++;
    sharedText = text;
    sharedImages = images;
    return outcome;
  }

  SharedFile? sharedFile;

  @override
  Future<ShareOutcome> shareFile(
    SharedFile file, {
    String? text,
    String? subject,
  }) async {
    calls++;
    sharedText = text;
    sharedFile = file;
    return outcome;
  }
}

/// Tasks held in memory. Writes change [tasks] and announce themselves on
/// [changes], the way the real repository does, so every list on screen
/// catches up.
class FakeTasksRepository implements TasksRepository {
  List<TaskResponse> tasks;

  /// When set, reading fails with it — a card's own error state.
  Object? readError;

  /// What each write sent, in order, for asserting on the request body.
  final List<Map<String, dynamic>> sent = [];

  /// Every query read with, in order.
  final List<TaskQuery> queries = [];

  final _changes = StreamController<void>.broadcast();

  FakeTasksRepository([this.tasks = const []]);

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<TaskResponse>> getTasks(
      [TaskQuery query = const TaskQuery()]) async {
    queries.add(query);
    if (readError != null) throw readError!;
    final found = tasks
        .where((t) => query.includeDone || t.isDone == query.done)
        .where((t) => query.from == null || !t.dueAt.isBefore(query.from!))
        .where((t) => query.to == null || t.dueAt.isBefore(query.to!))
        .where((t) => query.clientId == null || t.clientId == query.clientId)
        .where((t) => query.dealId == null || t.dealId == query.dealId)
        .where(
            (t) => query.assigneeId == null || t.assigneeId == query.assigneeId)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return found;
  }

  TaskResponse _replace(int id, TaskResponse Function(TaskResponse) change) {
    final updated = change(tasks.firstWhere((t) => t.id == id));
    tasks = [for (final t in tasks) t.id == id ? updated : t];
    _changes.add(null);
    return updated;
  }

  @override
  Future<TaskResponse> createTask(Map<String, dynamic> data) async {
    sent.add(data);
    final created = TaskResponse(
      id: tasks.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1,
      title: data['title'] as String,
      note: data['note'] as String?,
      dueAt: DateTime.parse(data['dueAt'] as String),
      clientId: data['clientId'] as int?,
      dealId: data['dealId'] as int?,
      assigneeId: data['assigneeId'] as int? ?? 5,
    );
    tasks = [...tasks, created];
    _changes.add(null);
    return created;
  }

  @override
  Future<TaskResponse> updateTask(int id, Map<String, dynamic> data) async {
    sent.add(data);
    return _replace(
        id,
        (t) => t.copyWith(
              title: data['title'] as String,
              note: data['note'] as String?,
              dueAt: DateTime.parse(data['dueAt'] as String),
              clientId: data['clientId'] as int?,
              dealId: data['dealId'] as int?,
            ));
  }

  @override
  Future<TaskResponse> completeTask(int id) async =>
      _replace(id, (t) => t.copyWith(completedAt: AppClock.now()));

  @override
  Future<TaskResponse> reopenTask(int id) async =>
      _replace(id, (t) => t.copyWith(completedAt: null));

  @override
  Future<void> deleteTask(int id) async {
    tasks = tasks.where((t) => t.id != id).toList();
    _changes.add(null);
  }
}

/// Clients going cold. The rule lives on the backend and is tested there; this
/// only honours the threshold, so a screen test can see it change the list —
/// a client never contacted is cold at any threshold.
class FakeColdClientsRepository implements ColdClientsRepository {
  List<ColdClient> clients;

  /// When set, reading fails with it — the card's own error state.
  Object? readError;

  /// Every read, as `(days, limit)`.
  final List<(int, int)> queries = [];

  /// When set, a read waits for it — the skeleton stays up until then.
  Future<void>? hold;

  FakeColdClientsRepository([this.clients = const []]);

  @override
  Future<List<ColdClient>> getColdClients({
    int days = ColdClientsRepository.defaultDays,
    int limit = 20,
  }) async {
    queries.add((days, limit));
    if (hold != null) await hold;
    if (readError != null) throw readError!;
    return clients
        .where((c) => c.lastContactAt == null || c.silentDays >= days)
        .take(limit)
        .toList();
  }
}

class FakeNotificationsRepository implements NotificationsRepository {
  List<AppNotification> items;

  Object? readError;

  int pageSize;

  final List<int> markedRead = [];
  int markAllCalls = 0;
  int unreadCountCalls = 0;

  final _counts = StreamController<int>.broadcast();
  int _last = 0;

  FakeNotificationsRepository([this.items = const [], this.pageSize = 20]);

  int get _unread => items.where((n) => !n.isRead).length;

  void _publish() {
    _last = _unread;
    _counts.add(_last);
  }

  @override
  Stream<int> get unreadCounts => _counts.stream;

  @override
  int get lastUnreadCount => _last;

  @override
  Future<PagedResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    if (readError != null) throw readError!;
    final all = unreadOnly ? items.where((n) => !n.isRead).toList() : items;
    final from = page * pageSize;
    final slice = all.skip(from).take(pageSize).toList();
    return PagedResponse(
      content: slice,
      page: page,
      totalPages: (all.length / pageSize).ceil(),
      totalElements: all.length,
      isLast: from + pageSize >= all.length,
    );
  }

  @override
  Future<int> refreshUnreadCount() async {
    unreadCountCalls++;
    _publish();
    return _last;
  }

  @override
  Future<AppNotification> markRead(int id) async {
    markedRead.add(id);
    final now = AppClock.now();
    items = [
      for (final n in items) n.id == id ? n.copyWith(readAt: now) : n,
    ];
    _publish();
    return items.firstWhere((n) => n.id == id);
  }

  @override
  Future<void> markAllRead() async {
    markAllCalls++;
    final now = AppClock.now();
    items = [for (final n in items) n.isRead ? n : n.copyWith(readAt: now)];
    _publish();
  }

  @override
  void clear() {
    _last = 0;
    _counts.add(0);
  }
}

/// The app icon's shortcuts. [launchedWith] is the one the app was cold
/// started from, handed over as soon as the handler is registered, the way
/// the platform does; [tap] is one pressed while the app is already running.
class FakeQuickActions implements QuickActions {
  FakeQuickActions({this.launchedWith});

  final String? launchedWith;
  QuickActionHandler? _handler;

  /// Every set of items put on the icon, in order.
  final List<List<ShortcutItem>> sets = [];

  @override
  Future<void> initialize(QuickActionHandler handler) async {
    _handler = handler;
    if (launchedWith != null) handler(launchedWith!);
  }

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async =>
      sets.add(items);

  @override
  Future<void> clearShortcutItems() async => sets.add(const []);

  void tap(String type) => _handler!(type);
}

/// Reads a sheet the way [onPreview] says and records every request, so a
/// test can see which mapping and options reached the server.
class FakeImportsRepository implements ImportsRepository {
  FakeImportsRepository({
    required this.onPreview,
    this.result = const ImportResult(kind: ImportKind.clients, created: 1),
    this.templateBytes = const [0xEF, 0xBB, 0xBF],
    this.failure,
  });

  ImportPreview Function(ImportKind kind, List<String?>? mapping) onPreview;
  ImportResult result;
  List<int> templateBytes;

  /// Thrown by every call when set.
  Object? failure;

  final previews = <List<String?>?>[];
  final commits = <({
    ImportKind kind,
    List<String?> mapping,
    bool skipDuplicates,
    int? assignToAgentId
  })>[];
  final templates = <String>[];

  @override
  Future<ImportPreview> preview(ImportKind kind, PickedFile file,
      {List<String?>? mapping}) async {
    if (failure != null) throw failure!;
    previews.add(mapping);
    return onPreview(kind, mapping);
  }

  @override
  Future<ImportResult> commit(ImportKind kind, PickedFile file,
      {required List<String?> mapping,
      required bool skipDuplicates,
      int? assignToAgentId}) async {
    if (failure != null) throw failure!;
    commits.add((
      kind: kind,
      mapping: mapping,
      skipDuplicates: skipDuplicates,
      assignToAgentId: assignToAgentId
    ));
    return result;
  }

  @override
  Future<List<int>> template(ImportKind kind, String lang) async {
    if (failure != null) throw failure!;
    templates.add('${kind.path}/$lang');
    return templateBytes;
  }
}

/// Tiles that draw nothing, so no test fetches a map picture from the
/// network. Counts what it was asked for, which proves a map was drawn.
class BlankTileProvider extends TileProvider {
  static int requests = 0;

  /// A 1x1 transparent PNG.
  static final _png = Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    requests++;
    return MemoryImage(_png);
  }
}

/// A deal's discussion in memory. Writes can be made to fail, or held open
/// with [gate] so a test can look at the screen while one is in flight.
class FakeDealCommentsRepository implements DealCommentsRepository {
  List<DealComment> comments;
  List<AgentOption> mentionable;
  bool hasEarlier;
  Object? readError;
  Object? writeError;
  Completer<void>? gate;
  int _nextId = 1000;

  final List<({String body, List<int> mentionedUserIds})> sent = [];
  final List<({int id, String body, List<int> mentionedUserIds})> updated = [];
  final List<int> deleted = [];
  final List<int?> requestedBefore = [];

  FakeDealCommentsRepository({
    this.comments = const [],
    this.mentionable = const [],
    this.hasEarlier = false,
  });

  Future<void> _write() async {
    if (gate != null) await gate!.future;
    if (writeError != null) throw writeError!;
  }

  @override
  Future<DealCommentPage> getComments(int dealId,
      {int? before, int? limit}) async {
    requestedBefore.add(before);
    if (readError != null) throw readError!;
    if (before != null) {
      return DealCommentPage(
          comments: comments.where((c) => c.id < before).toList());
    }
    return DealCommentPage(comments: comments, hasEarlier: hasEarlier);
  }

  @override
  Future<List<AgentOption>> getMentionable(int dealId) async => mentionable;

  @override
  Future<DealComment> addComment(int dealId,
      {required String body, List<int> mentionedUserIds = const []}) async {
    sent.add((body: body, mentionedUserIds: mentionedUserIds));
    await _write();
    final saved = DealComment(
      id: _nextId++,
      dealId: dealId,
      body: body,
      authorId: 1,
      authorName: 'Aigul Bekova',
      createdAt: AppClock.now(),
      mentions: [
        for (final p in mentionable)
          if (mentionedUserIds.contains(p.id))
            CommentMention(id: p.id, fullName: p.fullName)
      ],
    );
    comments = [...comments, saved];
    return saved;
  }

  @override
  Future<DealComment> updateComment(int dealId, int commentId,
      {required String body, required List<int> mentionedUserIds}) async {
    updated
        .add((id: commentId, body: body, mentionedUserIds: mentionedUserIds));
    await _write();
    final saved = comments
        .firstWhere((c) => c.id == commentId)
        .copyWith(body: body, editedAt: AppClock.now());
    comments = [for (final c in comments) c.id == commentId ? saved : c];
    return saved;
  }

  @override
  Future<void> deleteComment(int dealId, int commentId) async {
    deleted.add(commentId);
    await _write();
    comments = comments.where((c) => c.id != commentId).toList();
  }
}

/// Exports answered from memory. Records every request so a test can check
/// the filters, language and separator a screen sent.
class FakeExportsRepository implements ExportsRepository {
  FakeExportsRepository({
    this.fileName = 'clients-2026-09-28.csv',
    this.bytes = const [0xEF, 0xBB, 0xBF, 0x41],
    this.failure,
  });

  String fileName;
  List<int> bytes;

  /// Thrown by every call when set.
  Object? failure;

  final requests = <({
    ExportKind kind,
    ExportFilters filters,
    String lang,
    ExportDelimiter delimiter
  })>[];

  @override
  Future<ExportFile> export(
    ExportKind kind, {
    required ExportFilters filters,
    required String lang,
    required ExportDelimiter delimiter,
  }) async {
    requests
        .add((kind: kind, filters: filters, lang: lang, delimiter: delimiter));
    if (failure != null) throw failure!;
    return ExportFile(fileName: fileName, bytes: Uint8List.fromList(bytes));
  }
}

/// The keychain, in memory. [values] is what is on the "device".
class FakeSecretStore implements SecretStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// The real lock repository over [store], hashing on the test's own isolate
/// with few enough rounds that a widget test does not wait on it.
AppLockRepositoryImpl fakeAppLockRepository([FakeSecretStore? store]) =>
    AppLockRepositoryImpl(
      store: store ?? FakeSecretStore(),
      iterations: 64,
      inBackground: false,
    );

/// Deal checklists and the agency template in memory. Every write is
/// recorded; [writeError] makes writes fail.
class FakeChecklistRepository implements ChecklistRepository {
  Map<int, List<ChecklistItem>> byDeal;
  List<ChecklistItem> template;
  Object? readError;
  Object? writeError;
  int _nextId = 5000;

  final List<({int itemId, bool? done, int? documentId, bool detach})> updates =
      [];
  final List<({ChecklistStage stage, String title, bool required})> added = [];
  final List<int> deleted = [];
  final List<List<TemplateLine>> savedTemplates = [];

  FakeChecklistRepository({
    Map<int, List<ChecklistItem>>? byDeal,
    this.template = const [],
  }) : byDeal = byDeal ?? {};

  @override
  Future<List<ChecklistItem>> getDealChecklist(int dealId) async {
    if (readError != null) throw readError!;
    return byDeal[dealId] ?? const [];
  }

  @override
  Future<ChecklistItem> addItem(int dealId,
      {required ChecklistStage stage,
      required String title,
      bool required = false}) async {
    added.add((stage: stage, title: title, required: required));
    if (writeError != null) throw writeError!;
    final item = ChecklistItem(
        id: _nextId++,
        stage: stage,
        title: title,
        required: required,
        custom: true,
        position: 99);
    byDeal[dealId] = [...?byDeal[dealId], item];
    return item;
  }

  @override
  Future<ChecklistItem> updateItem(int dealId, int itemId,
      {bool? done, int? documentId, bool detachDocument = false}) async {
    updates.add((
      itemId: itemId,
      done: done,
      documentId: documentId,
      detach: detachDocument
    ));
    if (writeError != null) throw writeError!;
    final items = byDeal[dealId] ?? const <ChecklistItem>[];
    var item = items.firstWhere((i) => i.id == itemId);
    if (done != null) {
      item = item.copyWith(
        done: done,
        doneAt: done ? DateTime(2026, 9, 12, 10) : null,
        doneByName: done ? 'Aigul Bekova' : null,
        doneById: done ? 1 : null,
      );
    }
    if (documentId != null) {
      item = item.copyWith(
          documentId: documentId, documentName: 'document-$documentId.pdf');
    }
    if (detachDocument) {
      item = item.copyWith(documentId: null, documentName: null);
    }
    byDeal[dealId] = [for (final i in items) i.id == itemId ? item : i];
    return item;
  }

  @override
  Future<void> deleteItem(int dealId, int itemId) async {
    deleted.add(itemId);
    if (writeError != null) throw writeError!;
    byDeal[dealId] = [...?byDeal[dealId]]..removeWhere((i) => i.id == itemId);
  }

  @override
  Future<List<ChecklistItem>> getTemplate() async {
    if (readError != null) throw readError!;
    return template;
  }

  @override
  Future<List<ChecklistItem>> saveTemplate(List<TemplateLine> lines) async {
    savedTemplates.add(lines);
    if (writeError != null) throw writeError!;
    final positions = <ChecklistStage, int>{};
    template = [
      for (final l in lines)
        ChecklistItem(
          id: _nextId++,
          stage: l.stage,
          title: l.title,
          required: l.required,
          position: positions.update(l.stage, (p) => p + 1, ifAbsent: () => 0),
        ),
    ];
    return template;
  }
}

/// The agency's message templates in memory. Every write is recorded;
/// [readError] and [writeError] make reads and writes fail.
class FakeMessageTemplatesRepository implements MessageTemplatesRepository {
  List<MessageTemplate> templates;
  Object? readError;
  Object? writeError;
  int reads = 0;
  int _nextId = 7000;

  final List<({int? id, String title, String body})> saved = [];
  final List<int> deleted = [];

  FakeMessageTemplatesRepository([this.templates = const []]);

  @override
  Future<List<MessageTemplate>> getTemplates() async {
    reads++;
    if (readError != null) throw readError!;
    return templates;
  }

  @override
  Future<MessageTemplate> createTemplate(
      {required String title, required String body}) async {
    saved.add((id: null, title: title, body: body));
    if (writeError != null) throw writeError!;
    final template = MessageTemplate(id: _nextId++, title: title, body: body);
    templates = [...templates, template];
    return template;
  }

  @override
  Future<MessageTemplate> updateTemplate(int id,
      {required String title, required String body}) async {
    saved.add((id: id, title: title, body: body));
    if (writeError != null) throw writeError!;
    final template = MessageTemplate(id: id, title: title, body: body);
    templates = [for (final t in templates) t.id == id ? template : t];
    return template;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    deleted.add(id);
    if (writeError != null) throw writeError!;
    templates = templates.where((t) => t.id != id).toList();
  }
}
