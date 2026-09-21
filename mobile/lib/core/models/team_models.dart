import 'package:real_estate_crm/core/models/models.dart';

class TeamResponse {
  final int id;
  final String name;
  final int? managerId;
  final String? managerName;
  final int memberCount;
  final DateTime? createdAt;

  const TeamResponse({
    required this.id,
    required this.name,
    this.managerId,
    this.managerName,
    required this.memberCount,
    this.createdAt,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) => TeamResponse(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '') as String,
        managerId: (json['managerId'] as num?)?.toInt(),
        managerName: json['managerName'] as String?,
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class TeamStatsResponse {
  final int teamId;
  final String teamName;
  final int? managerId;
  final String? managerName;
  final int totalAgents;
  final int totalClients;
  final int totalDeals;
  final int activeDeals;
  final int upcomingMeetings;

  const TeamStatsResponse({
    required this.teamId,
    required this.teamName,
    this.managerId,
    this.managerName,
    required this.totalAgents,
    required this.totalClients,
    required this.totalDeals,
    required this.activeDeals,
    required this.upcomingMeetings,
  });

  factory TeamStatsResponse.fromJson(Map<String, dynamic> json) =>
      TeamStatsResponse(
        teamId: (json['teamId'] as num).toInt(),
        teamName: (json['teamName'] ?? '') as String,
        managerId: (json['managerId'] as num?)?.toInt(),
        managerName: json['managerName'] as String?,
        totalAgents: (json['totalAgents'] as num?)?.toInt() ?? 0,
        totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
        totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
        activeDeals: (json['activeDeals'] as num?)?.toInt() ?? 0,
        upcomingMeetings: (json['upcomingMeetings'] as num?)?.toInt() ?? 0,
      );
}

class TeamMemberResponse {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final Role role;
  final UserAccountStatus status;
  final bool isActive;
  final bool isTeamManager;

  const TeamMemberResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.isActive,
    required this.isTeamManager,
  });

  factory TeamMemberResponse.fromJson(Map<String, dynamic> json) =>
      TeamMemberResponse(
        id: (json['id'] as num).toInt(),
        fullName: (json['fullName'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        phone: json['phone'] as String?,
        role: Role.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => Role.AGENT,
        ),
        status: UserAccountStatus.parse(json['status'] as String?),
        isActive: (json['active'] ?? json['isActive'] ?? false) as bool,
        isTeamManager:
            (json['teamManager'] ?? json['isTeamManager'] ?? false) as bool,
      );
}

enum UserAccountStatus {
  active,
  pendingInvite,
  pendingVerification;

  static UserAccountStatus parse(String? raw) {
    switch (raw) {
      case 'PENDING_INVITE':
        return UserAccountStatus.pendingInvite;
      case 'PENDING_VERIFICATION':
        return UserAccountStatus.pendingVerification;
      default:
        return UserAccountStatus.active;
    }
  }
}

class TeamJoinRequestResponse {
  final int id;
  final int teamId;
  final String teamName;
  final String? invitedByName;
  final int userId;
  final String userFullName;
  final String userEmail;
  final DateTime? createdAt;

  const TeamJoinRequestResponse({
    required this.id,
    required this.teamId,
    required this.teamName,
    this.invitedByName,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    this.createdAt,
  });

  factory TeamJoinRequestResponse.fromJson(Map<String, dynamic> json) =>
      TeamJoinRequestResponse(
        id: (json['id'] as num).toInt(),
        teamId: (json['teamId'] as num).toInt(),
        teamName: (json['teamName'] ?? '') as String,
        invitedByName: json['invitedByName'] as String?,
        userId: (json['userId'] as num).toInt(),
        userFullName: (json['userFullName'] ?? '') as String,
        userEmail: (json['userEmail'] ?? '') as String,
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class AddMemberResult {
  final bool requestSent;
  final TeamJoinRequestResponse? request;
  final TeamMemberResponse? member;

  const AddMemberResult({
    required this.requestSent,
    this.request,
    this.member,
  });

  factory AddMemberResult.fromJson(Map<String, dynamic> json) {
    final request = json['request'];
    final member = json['member'];
    return AddMemberResult(
      requestSent: json['result'] == 'REQUEST_SENT',
      request: request is Map<String, dynamic>
          ? TeamJoinRequestResponse.fromJson(request)
          : null,
      member: member is Map<String, dynamic>
          ? TeamMemberResponse.fromJson(member)
          : null,
    );
  }
}
