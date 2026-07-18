// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: $enumDecodeNullable(_$RoleEnumMap, json['role'],
              unknownValue: Role.AGENT) ??
          Role.AGENT,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenType': instance.tokenType,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'email': instance.email,
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {
  Role.ADMIN: 'ADMIN',
  Role.MANAGER: 'MANAGER',
  Role.AGENT: 'AGENT',
};

_$ClientResponseImpl _$$ClientResponseImplFromJson(Map<String, dynamic> json) =>
    _$ClientResponseImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      type: $enumDecodeNullable(_$ClientTypeEnumMap, json['type']) ??
          ClientType.BUYER,
      notes: json['notes'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ClientResponseImplToJson(
        _$ClientResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'type': _$ClientTypeEnumMap[instance.type]!,
      'notes': instance.notes,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ClientTypeEnumMap = {
  ClientType.BUYER: 'BUYER',
  ClientType.SELLER: 'SELLER',
};

_$ClientListItemImpl _$$ClientListItemImplFromJson(Map<String, dynamic> json) =>
    _$ClientListItemImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: $enumDecodeNullable(_$DealStatusEnumMap, json['status']),
      budget: (json['budget'] as num?)?.toDouble(),
      propertyTitle: json['propertyTitle'] as String?,
      nextMeetingAt: json['nextMeetingAt'] == null
          ? null
          : DateTime.parse(json['nextMeetingAt'] as String),
      lastContactAt: json['lastContactAt'] == null
          ? null
          : DateTime.parse(json['lastContactAt'] as String),
    );

Map<String, dynamic> _$$ClientListItemImplToJson(
        _$ClientListItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'status': _$DealStatusEnumMap[instance.status],
      'budget': instance.budget,
      'propertyTitle': instance.propertyTitle,
      'nextMeetingAt': instance.nextMeetingAt?.toIso8601String(),
      'lastContactAt': instance.lastContactAt?.toIso8601String(),
    };

const _$DealStatusEnumMap = {
  DealStatus.LEAD: 'LEAD',
  DealStatus.NEGOTIATION: 'NEGOTIATION',
  DealStatus.CLOSED_WON: 'CLOSED_WON',
  DealStatus.CLOSED_LOST: 'CLOSED_LOST',
};

_$PropertyResponseImpl _$$PropertyResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PropertyResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      type: $enumDecodeNullable(_$PropertyTypeEnumMap, json['type']) ??
          PropertyType.APARTMENT,
      status: $enumDecodeNullable(_$PropertyStatusEnumMap, json['status']) ??
          PropertyStatus.AVAILABLE,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      areaSqm: (json['areaSqm'] as num?)?.toDouble(),
      rooms: (json['rooms'] as num?)?.toInt(),
      floor: (json['floor'] as num?)?.toInt(),
      totalFloors: (json['totalFloors'] as num?)?.toInt(),
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PropertyResponseImplToJson(
        _$PropertyResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'address': instance.address,
      'city': instance.city,
      'type': _$PropertyTypeEnumMap[instance.type]!,
      'status': _$PropertyStatusEnumMap[instance.status]!,
      'price': instance.price,
      'areaSqm': instance.areaSqm,
      'rooms': instance.rooms,
      'floor': instance.floor,
      'totalFloors': instance.totalFloors,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PropertyTypeEnumMap = {
  PropertyType.APARTMENT: 'APARTMENT',
  PropertyType.HOUSE: 'HOUSE',
  PropertyType.COMMERCIAL: 'COMMERCIAL',
  PropertyType.LAND: 'LAND',
  PropertyType.OFFICE: 'OFFICE',
};

const _$PropertyStatusEnumMap = {
  PropertyStatus.AVAILABLE: 'AVAILABLE',
  PropertyStatus.RESERVED: 'RESERVED',
  PropertyStatus.SOLD: 'SOLD',
};

_$DealResponseImpl _$$DealResponseImplFromJson(Map<String, dynamic> json) =>
    _$DealResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      status: $enumDecodeNullable(_$DealStatusEnumMap, json['status']) ??
          DealStatus.LEAD,
      dealPrice: (json['dealPrice'] as num?)?.toDouble(),
      budget: (json['budget'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      clientId: (json['clientId'] as num).toInt(),
      clientName: json['clientName'] as String? ?? '',
      propertyId: (json['propertyId'] as num?)?.toInt(),
      propertyTitle: json['propertyTitle'] as String?,
      propertyAddress: json['propertyAddress'] as String?,
      agentId: (json['agentId'] as num).toInt(),
      agentName: json['agentName'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
    );

Map<String, dynamic> _$$DealResponseImplToJson(_$DealResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': _$DealStatusEnumMap[instance.status]!,
      'dealPrice': instance.dealPrice,
      'budget': instance.budget,
      'notes': instance.notes,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'propertyId': instance.propertyId,
      'propertyTitle': instance.propertyTitle,
      'propertyAddress': instance.propertyAddress,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
    };

_$MeetingResponseImpl _$$MeetingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$MeetingResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      location: json['location'] as String?,
      completed: json['completed'] as bool? ?? false,
      dealId: (json['dealId'] as num?)?.toInt(),
      dealTitle: json['dealTitle'] as String?,
      agentId: (json['agentId'] as num).toInt(),
      agentName: json['agentName'] as String? ?? '',
      clientId: (json['clientId'] as num).toInt(),
      clientName: json['clientName'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MeetingResponseImplToJson(
        _$MeetingResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'location': instance.location,
      'completed': instance.completed,
      'dealId': instance.dealId,
      'dealTitle': instance.dealTitle,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$UpcomingMeetingResponseImpl _$$UpcomingMeetingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$UpcomingMeetingResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      clientName: json['clientName'] as String? ?? '',
    );

Map<String, dynamic> _$$UpcomingMeetingResponseImplToJson(
        _$UpcomingMeetingResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'clientName': instance.clientName,
    };

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryImpl(
      totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
      activeDeals: (json['activeDeals'] as num?)?.toInt() ?? 0,
      closedDeals: (json['closedDeals'] as num?)?.toInt() ?? 0,
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      upcomingMeetings: (json['upcomingMeetings'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DashboardSummaryImplToJson(
        _$DashboardSummaryImpl instance) =>
    <String, dynamic>{
      'totalDeals': instance.totalDeals,
      'activeDeals': instance.activeDeals,
      'closedDeals': instance.closedDeals,
      'totalClients': instance.totalClients,
      'upcomingMeetings': instance.upcomingMeetings,
    };

_$AgentOptionImpl _$$AgentOptionImplFromJson(Map<String, dynamic> json) =>
    _$AgentOptionImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$AgentOptionImplToJson(_$AgentOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
    };
