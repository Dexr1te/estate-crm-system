import 'package:real_estate_crm/core/models/models.dart';

/// Parses a backend role string to [Role], defaulting to [Role.AGENT] for
/// unknown/absent values (mirrors the AuthResponse fallback).
Role roleFromName(dynamic value) {
  if (value is String) {
    for (final r in Role.values) {
      if (r.name == value) return r;
    }
  }
  return Role.AGENT;
}

/// Reads a nullable ISO date-time.
DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;

/// Jackson serializes a `boolean isActive` getter as the JSON key `active`;
/// accept either spelling.
bool _activeOf(Map<String, dynamic> json) =>
    (json['active'] ?? json['isActive'] ?? false) as bool;

/// A user/agent as returned by the admin endpoints (`/admin/users`).
class AgentResponse {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final Role role;
  final bool isActive;
  final DateTime? createdAt;

  const AgentResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) => AgentResponse(
        id: (json['id'] as num).toInt(),
        fullName: (json['fullName'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        phone: json['phone'] as String?,
        role: roleFromName(json['role']),
        isActive: _activeOf(json),
        createdAt: _date(json['createdAt']),
      );
}

/// Work statistics for a single agent (`/admin/users/{id}/stats`).
class AgentStatsResponse {
  final int agentId;
  final String fullName;
  final String email;
  final bool isActive;
  final int totalClients;
  final int totalDeals;
  final int activeDeals;
  final int closedDeals;
  final int upcomingMeetings;

  const AgentStatsResponse({
    required this.agentId,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.totalClients,
    required this.totalDeals,
    required this.activeDeals,
    required this.closedDeals,
    required this.upcomingMeetings,
  });

  factory AgentStatsResponse.fromJson(Map<String, dynamic> json) =>
      AgentStatsResponse(
        agentId: (json['agentId'] as num).toInt(),
        fullName: (json['fullName'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        isActive: _activeOf(json),
        totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
        totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
        activeDeals: (json['activeDeals'] as num?)?.toInt() ?? 0,
        closedDeals: (json['closedDeals'] as num?)?.toInt() ?? 0,
        upcomingMeetings: (json['upcomingMeetings'] as num?)?.toInt() ?? 0,
      );
}

/// One audit-log entry (`/admin/audit-log`).
class AuditLogResponse {
  final int id;
  final int? actorId;
  final String? actorEmail;
  final String action;
  final String? entityType;
  final int? entityId;
  final String? metadata;
  final DateTime? createdAt;

  const AuditLogResponse({
    required this.id,
    this.actorId,
    this.actorEmail,
    required this.action,
    this.entityType,
    this.entityId,
    this.metadata,
    this.createdAt,
  });

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) =>
      AuditLogResponse(
        id: (json['id'] as num).toInt(),
        actorId: (json['actorId'] as num?)?.toInt(),
        actorEmail: json['actorEmail'] as String?,
        action: (json['action'] ?? '') as String,
        entityType: json['entityType'] as String?,
        entityId: (json['entityId'] as num?)?.toInt(),
        metadata: json['metadata'] as String?,
        createdAt: _date(json['createdAt']),
      );
}
