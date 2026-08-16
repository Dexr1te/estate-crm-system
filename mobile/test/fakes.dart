import 'dart:async';

import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';
import 'package:real_estate_crm/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final AuthResponse? user;
  FakeAuthRepository({this.user});

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
  Future<void> logout() async {}
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
  FakeClientsRepository({this.clients = const [], this.listItems = const []});

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) async =>
      clients;
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
  FakePropertiesRepository(this.properties);

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
        .toList();
    return PagedResponse(
      content: filtered,
      page: 0,
      totalPages: 1,
      totalElements: filtered.length,
      isLast: true,
    );
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
  noSuchMethod(Invocation i) => throw UnimplementedError();
}

class FakeTeamsRepository implements TeamsRepository {
  final List<TeamResponse> teams;
  final TeamStatsResponse stats;
  final bool pending;

  FakeTeamsRepository({
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
  noSuchMethod(Invocation i) => throw UnimplementedError();
}
