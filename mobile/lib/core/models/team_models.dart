/// A team as returned by `/teams`.
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
        createdAt:
            json['createdAt'] is String ? DateTime.tryParse(json['createdAt']) : null,
      );
}

/// Aggregated statistics for a team (`/teams/{id}/stats`).
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
