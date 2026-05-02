// ─────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────

// ignore: constant_identifier_names
enum Role { ADMIN, AGENT }

// ignore: constant_identifier_names
enum ClientType { BUYER, SELLER }

// ignore: constant_identifier_names
enum PropertyType { APARTMENT, HOUSE, COMMERCIAL, LAND, OFFICE }

// ignore: constant_identifier_names
enum PropertyStatus { AVAILABLE, RESERVED, SOLD }

// ignore: constant_identifier_names
enum DealStatus { LEAD, NEGOTIATION, CLOSED_WON, CLOSED_LOST }

// ─────────────────────────────────────────────
// Auth
// ─────────────────────────────────────────────

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int userId;
  final String fullName;
  final String email;
  final Role role;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        tokenType: json['tokenType'] ?? 'Bearer',
        userId: json['userId'] ?? 0,
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: Role.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => Role.AGENT,
        ),
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'role': role.name,
      };
}

// ─────────────────────────────────────────────
// Client
// ─────────────────────────────────────────────

class ClientResponse {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final ClientType type;
  final String? notes;
  final int? agentId;
  final String? agentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientResponse({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.type,
    this.notes,
    this.agentId,
    this.agentName,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) => ClientResponse(
        id: json['id'],
        fullName: json['fullName'] ?? '',
        email: json['email'],
        phone: json['phone'],
        type: ClientType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ClientType.BUYER,
        ),
        notes: json['notes'],
        agentId: json['agentId'],
        agentName: json['agentName'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}

class ClientListItem {
  final int id;
  final String fullName;
  final String? phone;
  final String? email;
  final DealStatus? status;
  final double? budget;
  final String? propertyTitle;
  final DateTime? nextMeetingAt;
  final DateTime? lastContactAt;

  ClientListItem({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.status,
    this.budget,
    this.propertyTitle,
    this.nextMeetingAt,
    this.lastContactAt,
  });

  factory ClientListItem.fromJson(Map<String, dynamic> json) => ClientListItem(
        id: json['id'],
        fullName: json['fullName'] ?? '',
        phone: json['phone'],
        email: json['email'],
        status: json['status'] != null
            ? DealStatus.values.firstWhere(
                (e) => e.name == json['status'],
                orElse: () => DealStatus.LEAD,
              )
            : null,
        budget:
            json['budget'] != null ? (json['budget'] as num).toDouble() : null,
        propertyTitle: json['propertyTitle'],
        nextMeetingAt: json['nextMeetingAt'] != null
            ? DateTime.parse(json['nextMeetingAt'])
            : null,
        lastContactAt: json['lastContactAt'] != null
            ? DateTime.parse(json['lastContactAt'])
            : null,
      );
}

// ─────────────────────────────────────────────
// Property
// ─────────────────────────────────────────────

class PropertyResponse {
  final int id;
  final String title;
  final String? description;
  final String address;
  final String? city;
  final PropertyType type;
  final PropertyStatus status;
  final double price;
  final double? areaSqm;
  final int? rooms;
  final int? floor;
  final int? totalFloors;
  final int? agentId;
  final String? agentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PropertyResponse({
    required this.id,
    required this.title,
    this.description,
    required this.address,
    this.city,
    required this.type,
    required this.status,
    required this.price,
    this.areaSqm,
    this.rooms,
    this.floor,
    this.totalFloors,
    this.agentId,
    this.agentName,
    this.createdAt,
    this.updatedAt,
  });

  factory PropertyResponse.fromJson(Map<String, dynamic> json) =>
      PropertyResponse(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        address: json['address'] ?? '',
        city: json['city'],
        type: PropertyType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PropertyType.APARTMENT,
        ),
        status: PropertyStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PropertyStatus.AVAILABLE,
        ),
        price: (json['price'] as num).toDouble(),
        areaSqm: json['areaSqm'] != null
            ? (json['areaSqm'] as num).toDouble()
            : null,
        rooms: json['rooms'],
        floor: json['floor'],
        totalFloors: json['totalFloors'],
        agentId: json['agentId'],
        agentName: json['agentName'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}

// ─────────────────────────────────────────────
// Deal
// ─────────────────────────────────────────────

class DealResponse {
  final int id;
  final String title;
  final DealStatus status;
  final double? dealPrice;
  final double? budget;
  final String? notes;
  final int clientId;
  final String clientName;
  final int? propertyId;
  final String? propertyTitle;
  final String? propertyAddress;
  final int agentId;
  final String agentName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;

  DealResponse({
    required this.id,
    required this.title,
    required this.status,
    this.dealPrice,
    this.budget,
    this.notes,
    required this.clientId,
    required this.clientName,
    this.propertyId,
    this.propertyTitle,
    this.propertyAddress,
    required this.agentId,
    required this.agentName,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  factory DealResponse.fromJson(Map<String, dynamic> json) => DealResponse(
        id: json['id'],
        title: json['title'] ?? '',
        status: DealStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => DealStatus.LEAD,
        ),
        dealPrice: json['dealPrice'] != null
            ? (json['dealPrice'] as num).toDouble()
            : null,
        budget:
            json['budget'] != null ? (json['budget'] as num).toDouble() : null,
        notes: json['notes'],
        clientId: json['clientId'],
        clientName: json['clientName'] ?? '',
        propertyId: json['propertyId'],
        propertyTitle: json['propertyTitle'],
        propertyAddress: json['propertyAddress'],
        agentId: json['agentId'],
        agentName: json['agentName'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        closedAt:
            json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      );
}

// ─────────────────────────────────────────────
// Meeting
// ─────────────────────────────────────────────

class MeetingResponse {
  final int id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final String? location;
  final bool completed;
  final int? dealId;
  final String? dealTitle;
  final int agentId;
  final String agentName;
  final int clientId;
  final String clientName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MeetingResponse({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    this.location,
    required this.completed,
    this.dealId,
    this.dealTitle,
    required this.agentId,
    required this.agentName,
    required this.clientId,
    required this.clientName,
    this.createdAt,
    this.updatedAt,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) =>
      MeetingResponse(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        scheduledAt: DateTime.parse(json['scheduledAt']),
        location: json['location'],
        completed: json['completed'] ?? false,
        dealId: json['dealId'],
        dealTitle: json['dealTitle'],
        agentId: json['agentId'],
        agentName: json['agentName'] ?? '',
        clientId: json['clientId'],
        clientName: json['clientName'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}

class UpcomingMeetingResponse {
  final int id;
  final String title;
  final DateTime scheduledAt;
  final String clientName;

  UpcomingMeetingResponse({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.clientName,
  });

  factory UpcomingMeetingResponse.fromJson(Map<String, dynamic> json) =>
      UpcomingMeetingResponse(
        id: json['id'],
        title: json['title'] ?? '',
        scheduledAt: DateTime.parse(json['scheduledAt']),
        clientName: json['clientName'] ?? '',
      );
}

// ─────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────

class DashboardSummary {
  final int totalDeals;
  final int activeDeals;
  final int closedDeals;
  final int totalClients;
  final int upcomingMeetings;

  DashboardSummary({
    required this.totalDeals,
    required this.activeDeals,
    required this.closedDeals,
    required this.totalClients,
    required this.upcomingMeetings,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalDeals: json['totalDeals'] ?? 0,
        activeDeals: json['activeDeals'] ?? 0,
        closedDeals: json['closedDeals'] ?? 0,
        totalClients: json['totalClients'] ?? 0,
        upcomingMeetings: json['upcomingMeetings'] ?? 0,
      );
}
