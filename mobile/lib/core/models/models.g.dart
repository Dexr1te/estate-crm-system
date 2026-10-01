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
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.AGENT,
      teamId: (json['teamId'] as num?)?.toInt(),
      teamName: json['teamName'] as String?,
      teamCurrency: json['teamCurrency'] as String?,
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
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamCurrency': instance.teamCurrency,
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
      source: $enumDecodeNullable(_$ClientSourceEnumMap, json['source'],
              unknownValue: ClientSource.manual) ??
          ClientSource.manual,
      notes: json['notes'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      wantedType:
          $enumDecodeNullable(_$PropertyTypeEnumMap, json['wantedType']),
      wantedCity: json['wantedCity'] as String?,
      budgetMin: (json['budgetMin'] as num?)?.toDouble(),
      budgetMax: (json['budgetMax'] as num?)?.toDouble(),
      minRooms: (json['minRooms'] as num?)?.toInt(),
      minAreaSqm: (json['minAreaSqm'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      leadSource: $enumDecodeNullable(_$LeadSourceEnumMap, json['leadSource'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      leadSourceDetail: json['leadSourceDetail'] as String?,
    );

Map<String, dynamic> _$$ClientResponseImplToJson(
        _$ClientResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'type': _$ClientTypeEnumMap[instance.type]!,
      'source': _$ClientSourceEnumMap[instance.source]!,
      'notes': instance.notes,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'wantedType': _$PropertyTypeEnumMap[instance.wantedType],
      'wantedCity': instance.wantedCity,
      'budgetMin': instance.budgetMin,
      'budgetMax': instance.budgetMax,
      'minRooms': instance.minRooms,
      'minAreaSqm': instance.minAreaSqm,
      'tags': instance.tags,
      'leadSource': _$LeadSourceEnumMap[instance.leadSource],
      'leadSourceDetail': instance.leadSourceDetail,
    };

const _$ClientTypeEnumMap = {
  ClientType.BUYER: 'BUYER',
  ClientType.SELLER: 'SELLER',
};

const _$ClientSourceEnumMap = {
  ClientSource.manual: 'MANUAL',
  ClientSource.imported: 'IMPORT',
  ClientSource.publicLink: 'PUBLIC_LINK',
};

const _$PropertyTypeEnumMap = {
  PropertyType.APARTMENT: 'APARTMENT',
  PropertyType.HOUSE: 'HOUSE',
  PropertyType.COMMERCIAL: 'COMMERCIAL',
  PropertyType.LAND: 'LAND',
  PropertyType.OFFICE: 'OFFICE',
};

const _$LeadSourceEnumMap = {
  LeadSource.REFERRAL: 'REFERRAL',
  LeadSource.WEBSITE: 'WEBSITE',
  LeadSource.PORTAL: 'PORTAL',
  LeadSource.SOCIAL: 'SOCIAL',
  LeadSource.WALK_IN: 'WALK_IN',
  LeadSource.COLD_CALL: 'COLD_CALL',
  LeadSource.REPEAT: 'REPEAT',
  LeadSource.OTHER: 'OTHER',
};

_$ClientTagUsageImpl _$$ClientTagUsageImplFromJson(Map<String, dynamic> json) =>
    _$ClientTagUsageImpl(
      name: json['name'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ClientTagUsageImplToJson(
        _$ClientTagUsageImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
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
      source: $enumDecodeNullable(_$ClientSourceEnumMap, json['source'],
              unknownValue: ClientSource.manual) ??
          ClientSource.manual,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
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
      'source': _$ClientSourceEnumMap[instance.source]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$DealStatusEnumMap = {
  DealStatus.LEAD: 'LEAD',
  DealStatus.NEGOTIATION: 'NEGOTIATION',
  DealStatus.CLOSED_WON: 'CLOSED_WON',
  DealStatus.CLOSED_LOST: 'CLOSED_LOST',
};

_$ClientActivityImpl _$$ClientActivityImplFromJson(Map<String, dynamic> json) =>
    _$ClientActivityImpl(
      id: (json['id'] as num).toInt(),
      clientId: (json['clientId'] as num).toInt(),
      type: $enumDecodeNullable(_$ActivityTypeEnumMap, json['type']) ??
          ActivityType.NOTE,
      note: json['note'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      authorId: (json['authorId'] as num?)?.toInt(),
      authorName: json['authorName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      properties: (json['properties'] as List<dynamic>?)
              ?.map((e) => ActivityProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ActivityProperty>[],
    );

Map<String, dynamic> _$$ClientActivityImplToJson(
        _$ClientActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'note': instance.note,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'properties': instance.properties,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.CALL: 'CALL',
  ActivityType.MESSAGE: 'MESSAGE',
  ActivityType.EMAIL: 'EMAIL',
  ActivityType.NOTE: 'NOTE',
};

_$ActivityPropertyImpl _$$ActivityPropertyImplFromJson(
        Map<String, dynamic> json) =>
    _$ActivityPropertyImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$$ActivityPropertyImplToJson(
        _$ActivityPropertyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$ClientDuplicateImpl _$$ClientDuplicateImplFromJson(
        Map<String, dynamic> json) =>
    _$ClientDuplicateImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
      type: $enumDecodeNullable(_$ClientTypeEnumMap, json['type']) ??
          ClientType.BUYER,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      matchedOn: $enumDecodeNullable(_$DuplicateMatchEnumMap, json['matchedOn'],
              unknownValue: DuplicateMatch.PHONE) ??
          DuplicateMatch.PHONE,
      visible: json['visible'] as bool? ?? true,
    );

Map<String, dynamic> _$$ClientDuplicateImplToJson(
        _$ClientDuplicateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'type': _$ClientTypeEnumMap[instance.type]!,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'phone': instance.phone,
      'email': instance.email,
      'matchedOn': _$DuplicateMatchEnumMap[instance.matchedOn]!,
      'visible': instance.visible,
    };

const _$DuplicateMatchEnumMap = {
  DuplicateMatch.PHONE: 'PHONE',
  DuplicateMatch.EMAIL: 'EMAIL',
  DuplicateMatch.PHONE_AND_EMAIL: 'PHONE_AND_EMAIL',
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
      previousPrice: (json['previousPrice'] as num?)?.toDouble(),
      priceChangedAt: json['priceChangedAt'] == null
          ? null
          : DateTime.parse(json['priceChangedAt'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mandateType: $enumDecodeNullable(
          _$MandateTypeEnumMap, json['mandateType'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      mandateEndDate: json['mandateEndDate'] == null
          ? null
          : DateTime.parse(json['mandateEndDate'] as String),
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
      'previousPrice': instance.previousPrice,
      'priceChangedAt': instance.priceChangedAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'mandateType': _$MandateTypeEnumMap[instance.mandateType],
      'mandateEndDate': instance.mandateEndDate?.toIso8601String(),
    };

const _$PropertyStatusEnumMap = {
  PropertyStatus.AVAILABLE: 'AVAILABLE',
  PropertyStatus.RESERVED: 'RESERVED',
  PropertyStatus.SOLD: 'SOLD',
};

const _$MandateTypeEnumMap = {
  MandateType.EXCLUSIVE: 'EXCLUSIVE',
  MandateType.OPEN: 'OPEN',
};

_$PropertyPriceChangeImpl _$$PropertyPriceChangeImplFromJson(
        Map<String, dynamic> json) =>
    _$PropertyPriceChangeImpl(
      id: (json['id'] as num).toInt(),
      propertyId: (json['propertyId'] as num?)?.toInt(),
      oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0.0,
      newPrice: (json['newPrice'] as num?)?.toDouble() ?? 0.0,
      changedById: (json['changedById'] as num?)?.toInt(),
      changedByName: json['changedByName'] as String?,
      changedAt: json['changedAt'] == null
          ? null
          : DateTime.parse(json['changedAt'] as String),
    );

Map<String, dynamic> _$$PropertyPriceChangeImplToJson(
        _$PropertyPriceChangeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'oldPrice': instance.oldPrice,
      'newPrice': instance.newPrice,
      'changedById': instance.changedById,
      'changedByName': instance.changedByName,
      'changedAt': instance.changedAt?.toIso8601String(),
    };

_$PriceInsightStatsImpl _$$PriceInsightStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceInsightStatsImpl(
      count: (json['count'] as num?)?.toInt() ?? 0,
      medianPerSqm: (json['medianPerSqm'] as num?)?.toDouble(),
      p25PerSqm: (json['p25PerSqm'] as num?)?.toDouble(),
      p75PerSqm: (json['p75PerSqm'] as num?)?.toDouble(),
      medianDaysOnMarket: (json['medianDaysOnMarket'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PriceInsightStatsImplToJson(
        _$PriceInsightStatsImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'medianPerSqm': instance.medianPerSqm,
      'p25PerSqm': instance.p25PerSqm,
      'p75PerSqm': instance.p75PerSqm,
      'medianDaysOnMarket': instance.medianDaysOnMarket,
    };

_$PriceInsightRangeImpl _$$PriceInsightRangeImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceInsightRangeImpl(
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      median: (json['median'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$PriceInsightRangeImplToJson(
        _$PriceInsightRangeImpl instance) =>
    <String, dynamic>{
      'low': instance.low,
      'median': instance.median,
      'high': instance.high,
    };

_$PriceInsightPositionImpl _$$PriceInsightPositionImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceInsightPositionImpl(
      pricePerSqm: (json['pricePerSqm'] as num?)?.toDouble() ?? 0.0,
      percentile: (json['percentile'] as num?)?.toInt(),
      vsMedianPercent: (json['vsMedianPercent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PriceInsightPositionImplToJson(
        _$PriceInsightPositionImpl instance) =>
    <String, dynamic>{
      'pricePerSqm': instance.pricePerSqm,
      'percentile': instance.percentile,
      'vsMedianPercent': instance.vsMedianPercent,
    };

_$PriceInsightCriteriaImpl _$$PriceInsightCriteriaImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceInsightCriteriaImpl(
      city: json['city'] as String?,
      type: $enumDecodeNullable(_$PropertyTypeEnumMap, json['type']),
      rooms: (json['rooms'] as num?)?.toInt(),
      areaSqm: (json['areaSqm'] as num?)?.toDouble(),
      roomsRule: $enumDecodeNullable(_$PriceRoomsRuleEnumMap, json['roomsRule'],
              unknownValue: PriceRoomsRule.ANY) ??
          PriceRoomsRule.ANY,
      minRooms: (json['minRooms'] as num?)?.toInt(),
      maxRooms: (json['maxRooms'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PriceInsightCriteriaImplToJson(
        _$PriceInsightCriteriaImpl instance) =>
    <String, dynamic>{
      'city': instance.city,
      'type': _$PropertyTypeEnumMap[instance.type],
      'rooms': instance.rooms,
      'areaSqm': instance.areaSqm,
      'roomsRule': _$PriceRoomsRuleEnumMap[instance.roomsRule]!,
      'minRooms': instance.minRooms,
      'maxRooms': instance.maxRooms,
    };

const _$PriceRoomsRuleEnumMap = {
  PriceRoomsRule.EXACT: 'EXACT',
  PriceRoomsRule.NEAR: 'NEAR',
  PriceRoomsRule.ANY: 'ANY',
};

_$PriceComparableImpl _$$PriceComparableImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceComparableImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      areaSqm: (json['areaSqm'] as num?)?.toDouble(),
      pricePerSqm: (json['pricePerSqm'] as num?)?.toDouble() ?? 0.0,
      rooms: (json['rooms'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$PropertyStatusEnumMap, json['status']) ??
          PropertyStatus.AVAILABLE,
      sold: json['sold'] as bool? ?? false,
    );

Map<String, dynamic> _$$PriceComparableImplToJson(
        _$PriceComparableImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'areaSqm': instance.areaSqm,
      'pricePerSqm': instance.pricePerSqm,
      'rooms': instance.rooms,
      'status': _$PropertyStatusEnumMap[instance.status]!,
      'sold': instance.sold,
    };

_$PriceInsightImpl _$$PriceInsightImplFromJson(Map<String, dynamic> json) =>
    _$PriceInsightImpl(
      count: (json['count'] as num?)?.toInt() ?? 0,
      lowConfidence: json['lowConfidence'] as bool? ?? true,
      criteria: json['criteria'] == null
          ? const PriceInsightCriteria()
          : PriceInsightCriteria.fromJson(
              json['criteria'] as Map<String, dynamic>),
      active: json['active'] == null
          ? const PriceInsightStats()
          : PriceInsightStats.fromJson(json['active'] as Map<String, dynamic>),
      sold: json['sold'] == null
          ? const PriceInsightStats()
          : PriceInsightStats.fromJson(json['sold'] as Map<String, dynamic>),
      suggested: json['suggested'] == null
          ? null
          : PriceInsightRange.fromJson(
              json['suggested'] as Map<String, dynamic>),
      position: json['position'] == null
          ? null
          : PriceInsightPosition.fromJson(
              json['position'] as Map<String, dynamic>),
      comparables: (json['comparables'] as List<dynamic>?)
              ?.map((e) => PriceComparable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PriceComparable>[],
    );

Map<String, dynamic> _$$PriceInsightImplToJson(_$PriceInsightImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'lowConfidence': instance.lowConfidence,
      'criteria': instance.criteria,
      'active': instance.active,
      'sold': instance.sold,
      'suggested': instance.suggested,
      'position': instance.position,
      'comparables': instance.comparables,
    };

_$PropertyShareLinkImpl _$$PropertyShareLinkImplFromJson(
        Map<String, dynamic> json) =>
    _$PropertyShareLinkImpl(
      url: json['url'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      lastViewedAt: json['lastViewedAt'] == null
          ? null
          : DateTime.parse(json['lastViewedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      leadCount: (json['leadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PropertyShareLinkImplToJson(
        _$PropertyShareLinkImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'viewCount': instance.viewCount,
      'lastViewedAt': instance.lastViewedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'leadCount': instance.leadCount,
    };

_$SellerReportViewingsImpl _$$SellerReportViewingsImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerReportViewingsImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      held: (json['held'] as num?)?.toInt() ?? 0,
      upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
      outcomes: (json['outcomes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      awaitingOutcome: (json['awaitingOutcome'] as num?)?.toInt() ?? 0,
      lastHeldAt: json['lastHeldAt'] == null
          ? null
          : DateTime.parse(json['lastHeldAt'] as String),
      nextAt: json['nextAt'] == null
          ? null
          : DateTime.parse(json['nextAt'] as String),
    );

Map<String, dynamic> _$$SellerReportViewingsImplToJson(
        _$SellerReportViewingsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'held': instance.held,
      'upcoming': instance.upcoming,
      'outcomes': instance.outcomes,
      'awaitingOutcome': instance.awaitingOutcome,
      'lastHeldAt': instance.lastHeldAt?.toIso8601String(),
      'nextAt': instance.nextAt?.toIso8601String(),
    };

_$SellerReportLinkImpl _$$SellerReportLinkImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerReportLinkImpl(
      active: json['active'] as bool? ?? false,
      views: (json['views'] as num?)?.toInt() ?? 0,
      leads: (json['leads'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SellerReportLinkImplToJson(
        _$SellerReportLinkImpl instance) =>
    <String, dynamic>{
      'active': instance.active,
      'views': instance.views,
      'leads': instance.leads,
    };

_$SellerReportPriceImpl _$$SellerReportPriceImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerReportPriceImpl(
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      original: (json['original'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble(),
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) =>
                  PropertyPriceChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PropertyPriceChange>[],
    );

Map<String, dynamic> _$$SellerReportPriceImplToJson(
        _$SellerReportPriceImpl instance) =>
    <String, dynamic>{
      'current': instance.current,
      'original': instance.original,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'changes': instance.changes,
    };

_$SellerReportImpl _$$SellerReportImplFromJson(Map<String, dynamic> json) =>
    _$SellerReportImpl(
      propertyId: (json['propertyId'] as num).toInt(),
      title: json['title'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      status: $enumDecodeNullable(_$PropertyStatusEnumMap, json['status']) ??
          PropertyStatus.AVAILABLE,
      listedAt: json['listedAt'] == null
          ? null
          : DateTime.parse(json['listedAt'] as String),
      daysOnMarket: (json['daysOnMarket'] as num?)?.toInt() ?? 0,
      soldAt: json['soldAt'] == null
          ? null
          : DateTime.parse(json['soldAt'] as String),
      generatedOn: json['generatedOn'] == null
          ? null
          : DateTime.parse(json['generatedOn'] as String),
      viewings: json['viewings'] == null
          ? const SellerReportViewings()
          : SellerReportViewings.fromJson(
              json['viewings'] as Map<String, dynamic>),
      publicLink: json['publicLink'] == null
          ? const SellerReportLink()
          : SellerReportLink.fromJson(
              json['publicLink'] as Map<String, dynamic>),
      price: json['price'] == null
          ? const SellerReportPrice()
          : SellerReportPrice.fromJson(json['price'] as Map<String, dynamic>),
      matchingBuyers: (json['matchingBuyers'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SellerReportImplToJson(_$SellerReportImpl instance) =>
    <String, dynamic>{
      'propertyId': instance.propertyId,
      'title': instance.title,
      'address': instance.address,
      'city': instance.city,
      'status': _$PropertyStatusEnumMap[instance.status]!,
      'listedAt': instance.listedAt?.toIso8601String(),
      'daysOnMarket': instance.daysOnMarket,
      'soldAt': instance.soldAt?.toIso8601String(),
      'generatedOn': instance.generatedOn?.toIso8601String(),
      'viewings': instance.viewings,
      'publicLink': instance.publicLink,
      'price': instance.price,
      'matchingBuyers': instance.matchingBuyers,
    };

_$PropertyMatchImpl _$$PropertyMatchImplFromJson(Map<String, dynamic> json) =>
    _$PropertyMatchImpl(
      property:
          PropertyResponse.fromJson(json['property'] as Map<String, dynamic>),
      overBudget: json['overBudget'] as bool? ?? false,
      lastShownAt: json['lastShownAt'] == null
          ? null
          : DateTime.parse(json['lastShownAt'] as String),
      lastSentAt: json['lastSentAt'] == null
          ? null
          : DateTime.parse(json['lastSentAt'] as String),
    );

Map<String, dynamic> _$$PropertyMatchImplToJson(_$PropertyMatchImpl instance) =>
    <String, dynamic>{
      'property': instance.property,
      'overBudget': instance.overBudget,
      'lastShownAt': instance.lastShownAt?.toIso8601String(),
      'lastSentAt': instance.lastSentAt?.toIso8601String(),
    };

_$PropertyPhotoImpl _$$PropertyPhotoImplFromJson(Map<String, dynamic> json) =>
    _$PropertyPhotoImpl(
      id: (json['id'] as num).toInt(),
      propertyId: (json['propertyId'] as num).toInt(),
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? 'image/jpeg',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      hasThumbnail: json['hasThumbnail'] as bool? ?? false,
      uploadedById: (json['uploadedById'] as num?)?.toInt(),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$PropertyPhotoImplToJson(_$PropertyPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'fileSize': instance.fileSize,
      'sortOrder': instance.sortOrder,
      'hasThumbnail': instance.hasThumbnail,
      'uploadedById': instance.uploadedById,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

_$ClientMatchImpl _$$ClientMatchImplFromJson(Map<String, dynamic> json) =>
    _$ClientMatchImpl(
      client: ClientResponse.fromJson(json['client'] as Map<String, dynamic>),
      overBudget: json['overBudget'] as bool? ?? false,
    );

Map<String, dynamic> _$$ClientMatchImplToJson(_$ClientMatchImpl instance) =>
    <String, dynamic>{
      'client': instance.client,
      'overBudget': instance.overBudget,
    };

_$DealResponseImpl _$$DealResponseImplFromJson(Map<String, dynamic> json) =>
    _$DealResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      status: $enumDecodeNullable(_$DealStatusEnumMap, json['status']) ??
          DealStatus.LEAD,
      dealPrice: (json['dealPrice'] as num?)?.toDouble(),
      budget: (json['budget'] as num?)?.toDouble(),
      commissionPercent: (json['commissionPercent'] as num?)?.toDouble(),
      commission: (json['commission'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      lostReason: $enumDecodeNullable(
          _$DealLostReasonEnumMap, json['lostReason'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      lostNote: json['lostNote'] as String?,
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
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      checklistDone: (json['checklistDone'] as num?)?.toInt() ?? 0,
      checklistTotal: (json['checklistTotal'] as num?)?.toInt() ?? 0,
      openRequired: (json['openRequired'] as num?)?.toInt() ?? 0,
      openRequiredByStage:
          (json['openRequiredByStage'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const <String, int>{},
    );

Map<String, dynamic> _$$DealResponseImplToJson(_$DealResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': _$DealStatusEnumMap[instance.status]!,
      'dealPrice': instance.dealPrice,
      'budget': instance.budget,
      'commissionPercent': instance.commissionPercent,
      'commission': instance.commission,
      'notes': instance.notes,
      'lostReason': _$DealLostReasonEnumMap[instance.lostReason],
      'lostNote': instance.lostNote,
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
      'commentCount': instance.commentCount,
      'checklistDone': instance.checklistDone,
      'checklistTotal': instance.checklistTotal,
      'openRequired': instance.openRequired,
      'openRequiredByStage': instance.openRequiredByStage,
    };

const _$DealLostReasonEnumMap = {
  DealLostReason.PRICE: 'PRICE',
  DealLostReason.CHOSE_ANOTHER: 'CHOSE_ANOTHER',
  DealLostReason.FINANCING: 'FINANCING',
  DealLostReason.CHANGED_MIND: 'CHANGED_MIND',
  DealLostReason.NO_RESPONSE: 'NO_RESPONSE',
  DealLostReason.OTHER: 'OTHER',
};

_$ChecklistItemImpl _$$ChecklistItemImplFromJson(Map<String, dynamic> json) =>
    _$ChecklistItemImpl(
      id: (json['id'] as num).toInt(),
      stage: $enumDecodeNullable(_$ChecklistStageEnumMap, json['stage'],
              unknownValue: ChecklistStage.LEAD) ??
          ChecklistStage.LEAD,
      title: json['title'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      required: json['required'] as bool? ?? false,
      custom: json['custom'] as bool? ?? false,
      done: json['done'] as bool? ?? false,
      doneAt: json['doneAt'] == null
          ? null
          : DateTime.parse(json['doneAt'] as String),
      doneById: (json['doneById'] as num?)?.toInt(),
      doneByName: json['doneByName'] as String?,
      documentId: (json['documentId'] as num?)?.toInt(),
      documentName: json['documentName'] as String?,
    );

Map<String, dynamic> _$$ChecklistItemImplToJson(_$ChecklistItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stage': _$ChecklistStageEnumMap[instance.stage]!,
      'title': instance.title,
      'position': instance.position,
      'required': instance.required,
      'custom': instance.custom,
      'done': instance.done,
      'doneAt': instance.doneAt?.toIso8601String(),
      'doneById': instance.doneById,
      'doneByName': instance.doneByName,
      'documentId': instance.documentId,
      'documentName': instance.documentName,
    };

const _$ChecklistStageEnumMap = {
  ChecklistStage.LEAD: 'LEAD',
  ChecklistStage.NEGOTIATION: 'NEGOTIATION',
  ChecklistStage.CLOSED_WON: 'CLOSED_WON',
};

_$MessageTemplateImpl _$$MessageTemplateImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageTemplateImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MessageTemplateImplToJson(
        _$MessageTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$DealCommentImpl _$$DealCommentImplFromJson(Map<String, dynamic> json) =>
    _$DealCommentImpl(
      id: (json['id'] as num).toInt(),
      dealId: (json['dealId'] as num).toInt(),
      body: json['body'] as String? ?? '',
      authorId: (json['authorId'] as num?)?.toInt(),
      authorName: json['authorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => CommentMention.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CommentMention>[],
    );

Map<String, dynamic> _$$DealCommentImplToJson(_$DealCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dealId': instance.dealId,
      'body': instance.body,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'mentions': instance.mentions,
    };

_$CommentMentionImpl _$$CommentMentionImplFromJson(Map<String, dynamic> json) =>
    _$CommentMentionImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
    );

Map<String, dynamic> _$$CommentMentionImplToJson(
        _$CommentMentionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
    };

_$DealCommentPageImpl _$$DealCommentPageImplFromJson(
        Map<String, dynamic> json) =>
    _$DealCommentPageImpl(
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => DealComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DealComment>[],
      hasEarlier: json['hasEarlier'] as bool? ?? false,
    );

Map<String, dynamic> _$$DealCommentPageImplToJson(
        _$DealCommentPageImpl instance) =>
    <String, dynamic>{
      'comments': instance.comments,
      'hasEarlier': instance.hasEarlier,
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
      propertyId: (json['propertyId'] as num?)?.toInt(),
      propertyTitle: json['propertyTitle'] as String?,
      propertyAddress: json['propertyAddress'] as String?,
      propertyLatitude: (json['propertyLatitude'] as num?)?.toDouble(),
      propertyLongitude: (json['propertyLongitude'] as num?)?.toDouble(),
      outcome: $enumDecodeNullable(_$ViewingOutcomeEnumMap, json['outcome']),
      outcomeNote: json['outcomeNote'] as String?,
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
      'propertyId': instance.propertyId,
      'propertyTitle': instance.propertyTitle,
      'propertyAddress': instance.propertyAddress,
      'propertyLatitude': instance.propertyLatitude,
      'propertyLongitude': instance.propertyLongitude,
      'outcome': _$ViewingOutcomeEnumMap[instance.outcome],
      'outcomeNote': instance.outcomeNote,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ViewingOutcomeEnumMap = {
  ViewingOutcome.INTERESTED: 'INTERESTED',
  ViewingOutcome.REJECTED: 'REJECTED',
  ViewingOutcome.NO_SHOW: 'NO_SHOW',
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

_$TaskResponseImpl _$$TaskResponseImplFromJson(Map<String, dynamic> json) =>
    _$TaskResponseImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      note: json['note'] as String?,
      dueAt: DateTime.parse(json['dueAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      assigneeId: (json['assigneeId'] as num?)?.toInt(),
      assigneeName: json['assigneeName'] as String?,
      createdById: (json['createdById'] as num?)?.toInt(),
      createdByName: json['createdByName'] as String?,
      clientId: (json['clientId'] as num?)?.toInt(),
      clientName: json['clientName'] as String?,
      dealId: (json['dealId'] as num?)?.toInt(),
      dealTitle: json['dealTitle'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TaskResponseImplToJson(_$TaskResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'note': instance.note,
      'dueAt': instance.dueAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'assigneeId': instance.assigneeId,
      'assigneeName': instance.assigneeName,
      'createdById': instance.createdById,
      'createdByName': instance.createdByName,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'dealId': instance.dealId,
      'dealTitle': instance.dealTitle,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryImpl(
      totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
      activeDeals: (json['activeDeals'] as num?)?.toInt() ?? 0,
      closedDeals: (json['closedDeals'] as num?)?.toInt() ?? 0,
      totalClients: (json['totalClients'] as num?)?.toInt() ?? 0,
      upcomingMeetings: (json['upcomingMeetings'] as num?)?.toInt() ?? 0,
      commissionThisMonth:
          (json['commissionThisMonth'] as num?)?.toDouble() ?? 0,
      tasksDueToday: (json['tasksDueToday'] as num?)?.toInt() ?? 0,
      tasksOverdue: (json['tasksOverdue'] as num?)?.toInt() ?? 0,
      coldCount: (json['coldCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DashboardSummaryImplToJson(
        _$DashboardSummaryImpl instance) =>
    <String, dynamic>{
      'totalDeals': instance.totalDeals,
      'activeDeals': instance.activeDeals,
      'closedDeals': instance.closedDeals,
      'totalClients': instance.totalClients,
      'upcomingMeetings': instance.upcomingMeetings,
      'commissionThisMonth': instance.commissionThisMonth,
      'tasksDueToday': instance.tasksDueToday,
      'tasksOverdue': instance.tasksOverdue,
      'coldCount': instance.coldCount,
    };

_$GoalProgressImpl _$$GoalProgressImplFromJson(Map<String, dynamic> json) =>
    _$GoalProgressImpl(
      month: json['month'] as String? ?? '',
      currency: json['currency'] as String?,
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      source: json['source'] as String?,
      commissionTarget: (json['commissionTarget'] as num?)?.toDouble(),
      dealsTarget: (json['dealsTarget'] as num?)?.toInt(),
      personalCommissionTarget:
          (json['personalCommissionTarget'] as num?)?.toDouble(),
      personalDealsTarget: (json['personalDealsTarget'] as num?)?.toInt(),
      commissionAchieved: (json['commissionAchieved'] as num?)?.toDouble() ?? 0,
      dealsWon: (json['dealsWon'] as num?)?.toInt() ?? 0,
      commissionPercent: (json['commissionPercent'] as num?)?.toInt(),
      dealsPercent: (json['dealsPercent'] as num?)?.toInt(),
      daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
      commissionPerDay: (json['commissionPerDay'] as num?)?.toDouble(),
      dealsPerDay: (json['dealsPerDay'] as num?)?.toDouble(),
      personalEditable: json['personalEditable'] as bool? ?? false,
    );

Map<String, dynamic> _$$GoalProgressImplToJson(_$GoalProgressImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'currency': instance.currency,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'source': instance.source,
      'commissionTarget': instance.commissionTarget,
      'dealsTarget': instance.dealsTarget,
      'personalCommissionTarget': instance.personalCommissionTarget,
      'personalDealsTarget': instance.personalDealsTarget,
      'commissionAchieved': instance.commissionAchieved,
      'dealsWon': instance.dealsWon,
      'commissionPercent': instance.commissionPercent,
      'dealsPercent': instance.dealsPercent,
      'daysLeft': instance.daysLeft,
      'commissionPerDay': instance.commissionPerDay,
      'dealsPerDay': instance.dealsPerDay,
      'personalEditable': instance.personalEditable,
    };

_$TeamGoalsImpl _$$TeamGoalsImplFromJson(Map<String, dynamic> json) =>
    _$TeamGoalsImpl(
      month: json['month'] as String? ?? '',
      currency: json['currency'] as String?,
      daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
      agency: GoalProgress.fromJson(json['agency'] as Map<String, dynamic>),
      agents: (json['agents'] as List<dynamic>?)
              ?.map((e) => GoalProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GoalProgress>[],
      copied: (json['copied'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TeamGoalsImplToJson(_$TeamGoalsImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'currency': instance.currency,
      'daysLeft': instance.daysLeft,
      'agency': instance.agency,
      'agents': instance.agents,
      'copied': instance.copied,
    };

_$ColdReasonImpl _$$ColdReasonImplFromJson(Map<String, dynamic> json) =>
    _$ColdReasonImpl(
      code: $enumDecodeNullable(_$ColdReasonCodeEnumMap, json['code'],
              unknownValue: ColdReasonCode.unknown) ??
          ColdReasonCode.unknown,
      dealTitle: json['dealTitle'] as String?,
      dealStatus: $enumDecodeNullable(_$DealStatusEnumMap, json['dealStatus'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      matchCount: (json['matchCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ColdReasonImplToJson(_$ColdReasonImpl instance) =>
    <String, dynamic>{
      'code': _$ColdReasonCodeEnumMap[instance.code]!,
      'dealTitle': instance.dealTitle,
      'dealStatus': _$DealStatusEnumMap[instance.dealStatus],
      'matchCount': instance.matchCount,
    };

const _$ColdReasonCodeEnumMap = {
  ColdReasonCode.openDeal: 'OPEN_DEAL',
  ColdReasonCode.matches: 'MATCHES',
  ColdReasonCode.newLead: 'NEW_LEAD',
  ColdReasonCode.unknown: 'unknown',
};

_$ColdClientImpl _$$ColdClientImplFromJson(Map<String, dynamic> json) =>
    _$ColdClientImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
      type: $enumDecodeNullable(_$ClientTypeEnumMap, json['type'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
      agentId: (json['agentId'] as num?)?.toInt(),
      agentName: json['agentName'] as String?,
      lastContactAt: json['lastContactAt'] == null
          ? null
          : DateTime.parse(json['lastContactAt'] as String),
      silentDays: (json['silentDays'] as num?)?.toInt() ?? 0,
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => ColdReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ColdReason>[],
      nextStep: $enumDecodeNullable(_$ColdNextStepEnumMap, json['nextStep'],
          unknownValue: JsonKey.nullForUndefinedEnumValue),
    );

Map<String, dynamic> _$$ColdClientImplToJson(_$ColdClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'type': _$ClientTypeEnumMap[instance.type],
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'lastContactAt': instance.lastContactAt?.toIso8601String(),
      'silentDays': instance.silentDays,
      'reasons': instance.reasons,
      'nextStep': _$ColdNextStepEnumMap[instance.nextStep],
    };

const _$ColdNextStepEnumMap = {
  ColdNextStep.pushDeal: 'PUSH_DEAL',
  ColdNextStep.sendMatches: 'SEND_MATCHES',
  ColdNextStep.firstCall: 'FIRST_CALL',
  ColdNextStep.checkIn: 'CHECK_IN',
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

_$DealFunnelImpl _$$DealFunnelImplFromJson(Map<String, dynamic> json) =>
    _$DealFunnelImpl(
      from:
          json['from'] == null ? null : DateTime.parse(json['from'] as String),
      to: json['to'] == null ? null : DateTime.parse(json['to'] as String),
      created: (json['created'] as num?)?.toInt() ?? 0,
      reachedNegotiation: (json['reachedNegotiation'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      leadToNegotiationRate:
          (json['leadToNegotiationRate'] as num?)?.toDouble(),
      negotiationToWonRate: (json['negotiationToWonRate'] as num?)?.toDouble(),
      leadToWonRate: (json['leadToWonRate'] as num?)?.toDouble(),
      wonValue: (json['wonValue'] as num?)?.toDouble() ?? 0,
      avgDaysToWin: (json['avgDaysToWin'] as num?)?.toDouble(),
      lostReasons: (json['lostReasons'] as List<dynamic>?)
              ?.map((e) => FunnelLostReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FunnelLostReason>[],
      monthly: (json['monthly'] as List<dynamic>?)
              ?.map((e) => FunnelMonth.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FunnelMonth>[],
    );

Map<String, dynamic> _$$DealFunnelImplToJson(_$DealFunnelImpl instance) =>
    <String, dynamic>{
      'from': instance.from?.toIso8601String(),
      'to': instance.to?.toIso8601String(),
      'created': instance.created,
      'reachedNegotiation': instance.reachedNegotiation,
      'won': instance.won,
      'lost': instance.lost,
      'leadToNegotiationRate': instance.leadToNegotiationRate,
      'negotiationToWonRate': instance.negotiationToWonRate,
      'leadToWonRate': instance.leadToWonRate,
      'wonValue': instance.wonValue,
      'avgDaysToWin': instance.avgDaysToWin,
      'lostReasons': instance.lostReasons,
      'monthly': instance.monthly,
    };

_$LeadSourceBreakdownImpl _$$LeadSourceBreakdownImplFromJson(
        Map<String, dynamic> json) =>
    _$LeadSourceBreakdownImpl(
      from:
          json['from'] == null ? null : DateTime.parse(json['from'] as String),
      to: json['to'] == null ? null : DateTime.parse(json['to'] as String),
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => LeadSourceRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LeadSourceRow>[],
    );

Map<String, dynamic> _$$LeadSourceBreakdownImplToJson(
        _$LeadSourceBreakdownImpl instance) =>
    <String, dynamic>{
      'from': instance.from?.toIso8601String(),
      'to': instance.to?.toIso8601String(),
      'clients': instance.clients,
      'won': instance.won,
      'sources': instance.sources,
    };

_$LeadSourceRowImpl _$$LeadSourceRowImplFromJson(Map<String, dynamic> json) =>
    _$LeadSourceRowImpl(
      source: json['source'] as String? ?? 'UNKNOWN',
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$LeadSourceRowImplToJson(_$LeadSourceRowImpl instance) =>
    <String, dynamic>{
      'source': instance.source,
      'clients': instance.clients,
      'won': instance.won,
      'conversionRate': instance.conversionRate,
    };

_$FunnelLostReasonImpl _$$FunnelLostReasonImplFromJson(
        Map<String, dynamic> json) =>
    _$FunnelLostReasonImpl(
      reason: json['reason'] as String? ?? 'UNSPECIFIED',
      count: (json['count'] as num?)?.toInt() ?? 0,
      share: (json['share'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$FunnelLostReasonImplToJson(
        _$FunnelLostReasonImpl instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'count': instance.count,
      'share': instance.share,
    };

_$FunnelMonthImpl _$$FunnelMonthImplFromJson(Map<String, dynamic> json) =>
    _$FunnelMonthImpl(
      month: DateTime.parse(json['month'] as String),
      created: (json['created'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FunnelMonthImplToJson(_$FunnelMonthImpl instance) =>
    <String, dynamic>{
      'month': instance.month.toIso8601String(),
      'created': instance.created,
      'won': instance.won,
      'lost': instance.lost,
    };

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type'],
              unknownValue: NotificationType.unknown) ??
          NotificationType.unknown,
      targetId: (json['targetId'] as num?)?.toInt(),
      params:
          json['params'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'targetId': instance.targetId,
      'params': instance.params,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.taskAssigned: 'TASK_ASSIGNED',
  NotificationType.recordsHandedOver: 'RECORDS_HANDED_OVER',
  NotificationType.joinRequest: 'JOIN_REQUEST',
  NotificationType.joinAccepted: 'JOIN_ACCEPTED',
  NotificationType.newMatch: 'NEW_MATCH',
  NotificationType.priceDropMatch: 'PRICE_DROP_MATCH',
  NotificationType.dealStatusChanged: 'DEAL_STATUS_CHANGED',
  NotificationType.listingLead: 'LISTING_LEAD',
  NotificationType.dealMention: 'DEAL_MENTION',
  NotificationType.dealComment: 'DEAL_COMMENT',
  NotificationType.unknown: 'unknown',
};
