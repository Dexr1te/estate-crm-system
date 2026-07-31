import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// ignore: constant_identifier_names
enum Role { ADMIN, MANAGER, AGENT }

// ignore: constant_identifier_names
enum DataScope { OWN, TEAM, ALL }

// ignore: constant_identifier_names
enum ClientType { BUYER, SELLER }

// ignore: constant_identifier_names
enum PropertyType { APARTMENT, HOUSE, COMMERCIAL, LAND, OFFICE }

// ignore: constant_identifier_names
enum PropertyStatus { AVAILABLE, RESERVED, SOLD }

// ignore: constant_identifier_names
enum DealStatus { LEAD, NEGOTIATION, CLOSED_WON, CLOSED_LOST }

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default('Bearer') String tokenType,
    @Default(0) int userId,
    @Default('') String fullName,
    @Default('') String email,
    @Default(Role.AGENT) Role role,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class ClientResponse with _$ClientResponse {
  const factory ClientResponse({
    required int id,
    @Default('') String fullName,
    String? email,
    String? phone,
    @Default(ClientType.BUYER) ClientType type,
    String? notes,
    int? agentId,
    String? agentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ClientResponse;

  factory ClientResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientResponseFromJson(json);
}

@freezed
class ClientListItem with _$ClientListItem {
  const factory ClientListItem({
    required int id,
    @Default('') String fullName,
    String? phone,
    String? email,
    DealStatus? status,
    double? budget,
    String? propertyTitle,
    DateTime? nextMeetingAt,
    DateTime? lastContactAt,
  }) = _ClientListItem;

  factory ClientListItem.fromJson(Map<String, dynamic> json) =>
      _$ClientListItemFromJson(json);
}

@freezed
class PropertyResponse with _$PropertyResponse {
  const factory PropertyResponse({
    required int id,
    @Default('') String title,
    String? description,
    @Default('') String address,
    String? city,
    @Default(PropertyType.APARTMENT) PropertyType type,
    @Default(PropertyStatus.AVAILABLE) PropertyStatus status,
    @Default(0.0) double price,
    double? areaSqm,
    int? rooms,
    int? floor,
    int? totalFloors,
    int? agentId,
    String? agentName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PropertyResponse;

  factory PropertyResponse.fromJson(Map<String, dynamic> json) =>
      _$PropertyResponseFromJson(json);
}

@freezed
class DealResponse with _$DealResponse {
  const factory DealResponse({
    required int id,
    @Default('') String title,
    @Default(DealStatus.LEAD) DealStatus status,
    double? dealPrice,
    double? budget,
    String? notes,
    required int clientId,
    @Default('') String clientName,
    int? propertyId,
    String? propertyTitle,
    String? propertyAddress,
    required int agentId,
    @Default('') String agentName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) = _DealResponse;

  factory DealResponse.fromJson(Map<String, dynamic> json) =>
      _$DealResponseFromJson(json);
}

@freezed
class MeetingResponse with _$MeetingResponse {
  const factory MeetingResponse({
    required int id,
    @Default('') String title,
    String? description,
    required DateTime scheduledAt,
    String? location,
    @Default(false) bool completed,
    int? dealId,
    String? dealTitle,
    required int agentId,
    @Default('') String agentName,
    required int clientId,
    @Default('') String clientName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MeetingResponse;

  factory MeetingResponse.fromJson(Map<String, dynamic> json) =>
      _$MeetingResponseFromJson(json);
}

@freezed
class UpcomingMeetingResponse with _$UpcomingMeetingResponse {
  const factory UpcomingMeetingResponse({
    required int id,
    @Default('') String title,
    required DateTime scheduledAt,
    @Default('') String clientName,
  }) = _UpcomingMeetingResponse;

  factory UpcomingMeetingResponse.fromJson(Map<String, dynamic> json) =>
      _$UpcomingMeetingResponseFromJson(json);
}

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    @Default(0) int totalDeals,
    @Default(0) int activeDeals,
    @Default(0) int closedDeals,
    @Default(0) int totalClients,
    @Default(0) int upcomingMeetings,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

@freezed
class AgentOption with _$AgentOption {
  const factory AgentOption({
    required int id,
    required String fullName,
    String? email,
  }) = _AgentOption;

  factory AgentOption.fromJson(Map<String, dynamic> json) =>
      _$AgentOptionFromJson(json);
}
