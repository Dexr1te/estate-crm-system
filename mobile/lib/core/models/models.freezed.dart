// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  String get tokenType => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  Role get role => throw _privateConstructorUsedError;
  int? get teamId => throw _privateConstructorUsedError;
  String? get teamName => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
          AuthResponse value, $Res Function(AuthResponse) then) =
      _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      String tokenType,
      int userId,
      String fullName,
      String email,
      Role role,
      int? teamId,
      String? teamName});
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? tokenType = null,
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? role = null,
    Object? teamId = freezed,
    Object? teamName = freezed,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      teamId: freezed == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as int?,
      teamName: freezed == teamName
          ? _value.teamName
          : teamName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
          _$AuthResponseImpl value, $Res Function(_$AuthResponseImpl) then) =
      __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      String tokenType,
      int userId,
      String fullName,
      String email,
      Role role,
      int? teamId,
      String? teamName});
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
      _$AuthResponseImpl _value, $Res Function(_$AuthResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? tokenType = null,
    Object? userId = null,
    Object? fullName = null,
    Object? email = null,
    Object? role = null,
    Object? teamId = freezed,
    Object? teamName = freezed,
  }) {
    return _then(_$AuthResponseImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      teamId: freezed == teamId
          ? _value.teamId
          : teamId // ignore: cast_nullable_to_non_nullable
              as int?,
      teamName: freezed == teamName
          ? _value.teamName
          : teamName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl(
      {this.accessToken = '',
      this.refreshToken = '',
      this.tokenType = 'Bearer',
      this.userId = 0,
      this.fullName = '',
      this.email = '',
      this.role = Role.AGENT,
      this.teamId,
      this.teamName});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  @JsonKey()
  final String accessToken;
  @override
  @JsonKey()
  final String refreshToken;
  @override
  @JsonKey()
  final String tokenType;
  @override
  @JsonKey()
  final int userId;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final Role role;
  @override
  final int? teamId;
  @override
  final String? teamName;

  @override
  String toString() {
    return 'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, userId: $userId, fullName: $fullName, email: $email, role: $role, teamId: $teamId, teamName: $teamName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.teamName, teamName) ||
                other.teamName == teamName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken,
      tokenType, userId, fullName, email, role, teamId, teamName);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse(
      {final String accessToken,
      final String refreshToken,
      final String tokenType,
      final int userId,
      final String fullName,
      final String email,
      final Role role,
      final int? teamId,
      final String? teamName}) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  String get tokenType;
  @override
  int get userId;
  @override
  String get fullName;
  @override
  String get email;
  @override
  Role get role;
  @override
  int? get teamId;
  @override
  String? get teamName;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientResponse _$ClientResponseFromJson(Map<String, dynamic> json) {
  return _ClientResponse.fromJson(json);
}

/// @nodoc
mixin _$ClientResponse {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  ClientType get type => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  PropertyType? get wantedType => throw _privateConstructorUsedError;
  String? get wantedCity => throw _privateConstructorUsedError;
  double? get budgetMin => throw _privateConstructorUsedError;
  double? get budgetMax => throw _privateConstructorUsedError;
  int? get minRooms => throw _privateConstructorUsedError;
  double? get minAreaSqm => throw _privateConstructorUsedError;

  /// Serializes this ClientResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientResponseCopyWith<ClientResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientResponseCopyWith<$Res> {
  factory $ClientResponseCopyWith(
          ClientResponse value, $Res Function(ClientResponse) then) =
      _$ClientResponseCopyWithImpl<$Res, ClientResponse>;
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? email,
      String? phone,
      ClientType type,
      String? notes,
      int? agentId,
      String? agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      PropertyType? wantedType,
      String? wantedCity,
      double? budgetMin,
      double? budgetMax,
      int? minRooms,
      double? minAreaSqm});
}

/// @nodoc
class _$ClientResponseCopyWithImpl<$Res, $Val extends ClientResponse>
    implements $ClientResponseCopyWith<$Res> {
  _$ClientResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? type = null,
    Object? notes = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? wantedType = freezed,
    Object? wantedCity = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? minRooms = freezed,
    Object? minAreaSqm = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wantedType: freezed == wantedType
          ? _value.wantedType
          : wantedType // ignore: cast_nullable_to_non_nullable
              as PropertyType?,
      wantedCity: freezed == wantedCity
          ? _value.wantedCity
          : wantedCity // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as double?,
      minRooms: freezed == minRooms
          ? _value.minRooms
          : minRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      minAreaSqm: freezed == minAreaSqm
          ? _value.minAreaSqm
          : minAreaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientResponseImplCopyWith<$Res>
    implements $ClientResponseCopyWith<$Res> {
  factory _$$ClientResponseImplCopyWith(_$ClientResponseImpl value,
          $Res Function(_$ClientResponseImpl) then) =
      __$$ClientResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? email,
      String? phone,
      ClientType type,
      String? notes,
      int? agentId,
      String? agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      PropertyType? wantedType,
      String? wantedCity,
      double? budgetMin,
      double? budgetMax,
      int? minRooms,
      double? minAreaSqm});
}

/// @nodoc
class __$$ClientResponseImplCopyWithImpl<$Res>
    extends _$ClientResponseCopyWithImpl<$Res, _$ClientResponseImpl>
    implements _$$ClientResponseImplCopyWith<$Res> {
  __$$ClientResponseImplCopyWithImpl(
      _$ClientResponseImpl _value, $Res Function(_$ClientResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? type = null,
    Object? notes = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? wantedType = freezed,
    Object? wantedCity = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? minRooms = freezed,
    Object? minAreaSqm = freezed,
  }) {
    return _then(_$ClientResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wantedType: freezed == wantedType
          ? _value.wantedType
          : wantedType // ignore: cast_nullable_to_non_nullable
              as PropertyType?,
      wantedCity: freezed == wantedCity
          ? _value.wantedCity
          : wantedCity // ignore: cast_nullable_to_non_nullable
              as String?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as double?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as double?,
      minRooms: freezed == minRooms
          ? _value.minRooms
          : minRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      minAreaSqm: freezed == minAreaSqm
          ? _value.minAreaSqm
          : minAreaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientResponseImpl implements _ClientResponse {
  const _$ClientResponseImpl(
      {required this.id,
      this.fullName = '',
      this.email,
      this.phone,
      this.type = ClientType.BUYER,
      this.notes,
      this.agentId,
      this.agentName,
      this.createdAt,
      this.updatedAt,
      this.wantedType,
      this.wantedCity,
      this.budgetMin,
      this.budgetMax,
      this.minRooms,
      this.minAreaSqm});

  factory _$ClientResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String fullName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  @JsonKey()
  final ClientType type;
  @override
  final String? notes;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final PropertyType? wantedType;
  @override
  final String? wantedCity;
  @override
  final double? budgetMin;
  @override
  final double? budgetMax;
  @override
  final int? minRooms;
  @override
  final double? minAreaSqm;

  @override
  String toString() {
    return 'ClientResponse(id: $id, fullName: $fullName, email: $email, phone: $phone, type: $type, notes: $notes, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt, wantedType: $wantedType, wantedCity: $wantedCity, budgetMin: $budgetMin, budgetMax: $budgetMax, minRooms: $minRooms, minAreaSqm: $minAreaSqm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.wantedType, wantedType) ||
                other.wantedType == wantedType) &&
            (identical(other.wantedCity, wantedCity) ||
                other.wantedCity == wantedCity) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            (identical(other.minRooms, minRooms) ||
                other.minRooms == minRooms) &&
            (identical(other.minAreaSqm, minAreaSqm) ||
                other.minAreaSqm == minAreaSqm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      email,
      phone,
      type,
      notes,
      agentId,
      agentName,
      createdAt,
      updatedAt,
      wantedType,
      wantedCity,
      budgetMin,
      budgetMax,
      minRooms,
      minAreaSqm);

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientResponseImplCopyWith<_$ClientResponseImpl> get copyWith =>
      __$$ClientResponseImplCopyWithImpl<_$ClientResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientResponseImplToJson(
      this,
    );
  }
}

abstract class _ClientResponse implements ClientResponse {
  const factory _ClientResponse(
      {required final int id,
      final String fullName,
      final String? email,
      final String? phone,
      final ClientType type,
      final String? notes,
      final int? agentId,
      final String? agentName,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final PropertyType? wantedType,
      final String? wantedCity,
      final double? budgetMin,
      final double? budgetMax,
      final int? minRooms,
      final double? minAreaSqm}) = _$ClientResponseImpl;

  factory _ClientResponse.fromJson(Map<String, dynamic> json) =
      _$ClientResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  ClientType get type;
  @override
  String? get notes;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  PropertyType? get wantedType;
  @override
  String? get wantedCity;
  @override
  double? get budgetMin;
  @override
  double? get budgetMax;
  @override
  int? get minRooms;
  @override
  double? get minAreaSqm;

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientResponseImplCopyWith<_$ClientResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientListItem _$ClientListItemFromJson(Map<String, dynamic> json) {
  return _ClientListItem.fromJson(json);
}

/// @nodoc
mixin _$ClientListItem {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  DealStatus? get status => throw _privateConstructorUsedError;
  double? get budget => throw _privateConstructorUsedError;
  String? get propertyTitle => throw _privateConstructorUsedError;
  DateTime? get nextMeetingAt => throw _privateConstructorUsedError;
  DateTime? get lastContactAt => throw _privateConstructorUsedError;

  /// Serializes this ClientListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientListItemCopyWith<ClientListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientListItemCopyWith<$Res> {
  factory $ClientListItemCopyWith(
          ClientListItem value, $Res Function(ClientListItem) then) =
      _$ClientListItemCopyWithImpl<$Res, ClientListItem>;
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? phone,
      String? email,
      DealStatus? status,
      double? budget,
      String? propertyTitle,
      DateTime? nextMeetingAt,
      DateTime? lastContactAt});
}

/// @nodoc
class _$ClientListItemCopyWithImpl<$Res, $Val extends ClientListItem>
    implements $ClientListItemCopyWith<$Res> {
  _$ClientListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? status = freezed,
    Object? budget = freezed,
    Object? propertyTitle = freezed,
    Object? nextMeetingAt = freezed,
    Object? lastContactAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      nextMeetingAt: freezed == nextMeetingAt
          ? _value.nextMeetingAt
          : nextMeetingAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastContactAt: freezed == lastContactAt
          ? _value.lastContactAt
          : lastContactAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientListItemImplCopyWith<$Res>
    implements $ClientListItemCopyWith<$Res> {
  factory _$$ClientListItemImplCopyWith(_$ClientListItemImpl value,
          $Res Function(_$ClientListItemImpl) then) =
      __$$ClientListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? phone,
      String? email,
      DealStatus? status,
      double? budget,
      String? propertyTitle,
      DateTime? nextMeetingAt,
      DateTime? lastContactAt});
}

/// @nodoc
class __$$ClientListItemImplCopyWithImpl<$Res>
    extends _$ClientListItemCopyWithImpl<$Res, _$ClientListItemImpl>
    implements _$$ClientListItemImplCopyWith<$Res> {
  __$$ClientListItemImplCopyWithImpl(
      _$ClientListItemImpl _value, $Res Function(_$ClientListItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? status = freezed,
    Object? budget = freezed,
    Object? propertyTitle = freezed,
    Object? nextMeetingAt = freezed,
    Object? lastContactAt = freezed,
  }) {
    return _then(_$ClientListItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      nextMeetingAt: freezed == nextMeetingAt
          ? _value.nextMeetingAt
          : nextMeetingAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastContactAt: freezed == lastContactAt
          ? _value.lastContactAt
          : lastContactAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientListItemImpl implements _ClientListItem {
  const _$ClientListItemImpl(
      {required this.id,
      this.fullName = '',
      this.phone,
      this.email,
      this.status,
      this.budget,
      this.propertyTitle,
      this.nextMeetingAt,
      this.lastContactAt});

  factory _$ClientListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientListItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String fullName;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final DealStatus? status;
  @override
  final double? budget;
  @override
  final String? propertyTitle;
  @override
  final DateTime? nextMeetingAt;
  @override
  final DateTime? lastContactAt;

  @override
  String toString() {
    return 'ClientListItem(id: $id, fullName: $fullName, phone: $phone, email: $email, status: $status, budget: $budget, propertyTitle: $propertyTitle, nextMeetingAt: $nextMeetingAt, lastContactAt: $lastContactAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.nextMeetingAt, nextMeetingAt) ||
                other.nextMeetingAt == nextMeetingAt) &&
            (identical(other.lastContactAt, lastContactAt) ||
                other.lastContactAt == lastContactAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, phone, email,
      status, budget, propertyTitle, nextMeetingAt, lastContactAt);

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientListItemImplCopyWith<_$ClientListItemImpl> get copyWith =>
      __$$ClientListItemImplCopyWithImpl<_$ClientListItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientListItemImplToJson(
      this,
    );
  }
}

abstract class _ClientListItem implements ClientListItem {
  const factory _ClientListItem(
      {required final int id,
      final String fullName,
      final String? phone,
      final String? email,
      final DealStatus? status,
      final double? budget,
      final String? propertyTitle,
      final DateTime? nextMeetingAt,
      final DateTime? lastContactAt}) = _$ClientListItemImpl;

  factory _ClientListItem.fromJson(Map<String, dynamic> json) =
      _$ClientListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  DealStatus? get status;
  @override
  double? get budget;
  @override
  String? get propertyTitle;
  @override
  DateTime? get nextMeetingAt;
  @override
  DateTime? get lastContactAt;

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientListItemImplCopyWith<_$ClientListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyResponse _$PropertyResponseFromJson(Map<String, dynamic> json) {
  return _PropertyResponse.fromJson(json);
}

/// @nodoc
mixin _$PropertyResponse {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  PropertyType get type => throw _privateConstructorUsedError;
  PropertyStatus get status => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get areaSqm => throw _privateConstructorUsedError;
  int? get rooms => throw _privateConstructorUsedError;
  int? get floor => throw _privateConstructorUsedError;
  int? get totalFloors => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PropertyResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyResponseCopyWith<PropertyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyResponseCopyWith<$Res> {
  factory $PropertyResponseCopyWith(
          PropertyResponse value, $Res Function(PropertyResponse) then) =
      _$PropertyResponseCopyWithImpl<$Res, PropertyResponse>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String address,
      String? city,
      PropertyType type,
      PropertyStatus status,
      double price,
      double? areaSqm,
      int? rooms,
      int? floor,
      int? totalFloors,
      int? agentId,
      String? agentName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PropertyResponseCopyWithImpl<$Res, $Val extends PropertyResponse>
    implements $PropertyResponseCopyWith<$Res> {
  _$PropertyResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? address = null,
    Object? city = freezed,
    Object? type = null,
    Object? status = null,
    Object? price = null,
    Object? areaSqm = freezed,
    Object? rooms = freezed,
    Object? floor = freezed,
    Object? totalFloors = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PropertyType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int?,
      totalFloors: freezed == totalFloors
          ? _value.totalFloors
          : totalFloors // ignore: cast_nullable_to_non_nullable
              as int?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyResponseImplCopyWith<$Res>
    implements $PropertyResponseCopyWith<$Res> {
  factory _$$PropertyResponseImplCopyWith(_$PropertyResponseImpl value,
          $Res Function(_$PropertyResponseImpl) then) =
      __$$PropertyResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String address,
      String? city,
      PropertyType type,
      PropertyStatus status,
      double price,
      double? areaSqm,
      int? rooms,
      int? floor,
      int? totalFloors,
      int? agentId,
      String? agentName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PropertyResponseImplCopyWithImpl<$Res>
    extends _$PropertyResponseCopyWithImpl<$Res, _$PropertyResponseImpl>
    implements _$$PropertyResponseImplCopyWith<$Res> {
  __$$PropertyResponseImplCopyWithImpl(_$PropertyResponseImpl _value,
      $Res Function(_$PropertyResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? address = null,
    Object? city = freezed,
    Object? type = null,
    Object? status = null,
    Object? price = null,
    Object? areaSqm = freezed,
    Object? rooms = freezed,
    Object? floor = freezed,
    Object? totalFloors = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PropertyResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PropertyType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int?,
      totalFloors: freezed == totalFloors
          ? _value.totalFloors
          : totalFloors // ignore: cast_nullable_to_non_nullable
              as int?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyResponseImpl implements _PropertyResponse {
  const _$PropertyResponseImpl(
      {required this.id,
      this.title = '',
      this.description,
      this.address = '',
      this.city,
      this.type = PropertyType.APARTMENT,
      this.status = PropertyStatus.AVAILABLE,
      this.price = 0.0,
      this.areaSqm,
      this.rooms,
      this.floor,
      this.totalFloors,
      this.agentId,
      this.agentName,
      this.createdAt,
      this.updatedAt});

  factory _$PropertyResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final String address;
  @override
  final String? city;
  @override
  @JsonKey()
  final PropertyType type;
  @override
  @JsonKey()
  final PropertyStatus status;
  @override
  @JsonKey()
  final double price;
  @override
  final double? areaSqm;
  @override
  final int? rooms;
  @override
  final int? floor;
  @override
  final int? totalFloors;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PropertyResponse(id: $id, title: $title, description: $description, address: $address, city: $city, type: $type, status: $status, price: $price, areaSqm: $areaSqm, rooms: $rooms, floor: $floor, totalFloors: $totalFloors, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm) &&
            (identical(other.rooms, rooms) || other.rooms == rooms) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.totalFloors, totalFloors) ||
                other.totalFloors == totalFloors) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      address,
      city,
      type,
      status,
      price,
      areaSqm,
      rooms,
      floor,
      totalFloors,
      agentId,
      agentName,
      createdAt,
      updatedAt);

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyResponseImplCopyWith<_$PropertyResponseImpl> get copyWith =>
      __$$PropertyResponseImplCopyWithImpl<_$PropertyResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyResponseImplToJson(
      this,
    );
  }
}

abstract class _PropertyResponse implements PropertyResponse {
  const factory _PropertyResponse(
      {required final int id,
      final String title,
      final String? description,
      final String address,
      final String? city,
      final PropertyType type,
      final PropertyStatus status,
      final double price,
      final double? areaSqm,
      final int? rooms,
      final int? floor,
      final int? totalFloors,
      final int? agentId,
      final String? agentName,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PropertyResponseImpl;

  factory _PropertyResponse.fromJson(Map<String, dynamic> json) =
      _$PropertyResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get address;
  @override
  String? get city;
  @override
  PropertyType get type;
  @override
  PropertyStatus get status;
  @override
  double get price;
  @override
  double? get areaSqm;
  @override
  int? get rooms;
  @override
  int? get floor;
  @override
  int? get totalFloors;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyResponseImplCopyWith<_$PropertyResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyMatch _$PropertyMatchFromJson(Map<String, dynamic> json) {
  return _PropertyMatch.fromJson(json);
}

/// @nodoc
mixin _$PropertyMatch {
  PropertyResponse get property => throw _privateConstructorUsedError;
  bool get overBudget => throw _privateConstructorUsedError;
  DateTime? get lastShownAt => throw _privateConstructorUsedError;

  /// Serializes this PropertyMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyMatchCopyWith<PropertyMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyMatchCopyWith<$Res> {
  factory $PropertyMatchCopyWith(
          PropertyMatch value, $Res Function(PropertyMatch) then) =
      _$PropertyMatchCopyWithImpl<$Res, PropertyMatch>;
  @useResult
  $Res call(
      {PropertyResponse property, bool overBudget, DateTime? lastShownAt});

  $PropertyResponseCopyWith<$Res> get property;
}

/// @nodoc
class _$PropertyMatchCopyWithImpl<$Res, $Val extends PropertyMatch>
    implements $PropertyMatchCopyWith<$Res> {
  _$PropertyMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? property = null,
    Object? overBudget = null,
    Object? lastShownAt = freezed,
  }) {
    return _then(_value.copyWith(
      property: null == property
          ? _value.property
          : property // ignore: cast_nullable_to_non_nullable
              as PropertyResponse,
      overBudget: null == overBudget
          ? _value.overBudget
          : overBudget // ignore: cast_nullable_to_non_nullable
              as bool,
      lastShownAt: freezed == lastShownAt
          ? _value.lastShownAt
          : lastShownAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PropertyResponseCopyWith<$Res> get property {
    return $PropertyResponseCopyWith<$Res>(_value.property, (value) {
      return _then(_value.copyWith(property: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PropertyMatchImplCopyWith<$Res>
    implements $PropertyMatchCopyWith<$Res> {
  factory _$$PropertyMatchImplCopyWith(
          _$PropertyMatchImpl value, $Res Function(_$PropertyMatchImpl) then) =
      __$$PropertyMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PropertyResponse property, bool overBudget, DateTime? lastShownAt});

  @override
  $PropertyResponseCopyWith<$Res> get property;
}

/// @nodoc
class __$$PropertyMatchImplCopyWithImpl<$Res>
    extends _$PropertyMatchCopyWithImpl<$Res, _$PropertyMatchImpl>
    implements _$$PropertyMatchImplCopyWith<$Res> {
  __$$PropertyMatchImplCopyWithImpl(
      _$PropertyMatchImpl _value, $Res Function(_$PropertyMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? property = null,
    Object? overBudget = null,
    Object? lastShownAt = freezed,
  }) {
    return _then(_$PropertyMatchImpl(
      property: null == property
          ? _value.property
          : property // ignore: cast_nullable_to_non_nullable
              as PropertyResponse,
      overBudget: null == overBudget
          ? _value.overBudget
          : overBudget // ignore: cast_nullable_to_non_nullable
              as bool,
      lastShownAt: freezed == lastShownAt
          ? _value.lastShownAt
          : lastShownAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyMatchImpl implements _PropertyMatch {
  const _$PropertyMatchImpl(
      {required this.property, this.overBudget = false, this.lastShownAt});

  factory _$PropertyMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyMatchImplFromJson(json);

  @override
  final PropertyResponse property;
  @override
  @JsonKey()
  final bool overBudget;
  @override
  final DateTime? lastShownAt;

  @override
  String toString() {
    return 'PropertyMatch(property: $property, overBudget: $overBudget, lastShownAt: $lastShownAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyMatchImpl &&
            (identical(other.property, property) ||
                other.property == property) &&
            (identical(other.overBudget, overBudget) ||
                other.overBudget == overBudget) &&
            (identical(other.lastShownAt, lastShownAt) ||
                other.lastShownAt == lastShownAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, property, overBudget, lastShownAt);

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyMatchImplCopyWith<_$PropertyMatchImpl> get copyWith =>
      __$$PropertyMatchImplCopyWithImpl<_$PropertyMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyMatchImplToJson(
      this,
    );
  }
}

abstract class _PropertyMatch implements PropertyMatch {
  const factory _PropertyMatch(
      {required final PropertyResponse property,
      final bool overBudget,
      final DateTime? lastShownAt}) = _$PropertyMatchImpl;

  factory _PropertyMatch.fromJson(Map<String, dynamic> json) =
      _$PropertyMatchImpl.fromJson;

  @override
  PropertyResponse get property;
  @override
  bool get overBudget;
  @override
  DateTime? get lastShownAt;

  /// Create a copy of PropertyMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyMatchImplCopyWith<_$PropertyMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyPhoto _$PropertyPhotoFromJson(Map<String, dynamic> json) {
  return _PropertyPhoto.fromJson(json);
}

/// @nodoc
mixin _$PropertyPhoto {
  int get id => throw _privateConstructorUsedError;
  int get propertyId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get hasThumbnail => throw _privateConstructorUsedError;
  int? get uploadedById => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this PropertyPhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyPhotoCopyWith<PropertyPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyPhotoCopyWith<$Res> {
  factory $PropertyPhotoCopyWith(
          PropertyPhoto value, $Res Function(PropertyPhoto) then) =
      _$PropertyPhotoCopyWithImpl<$Res, PropertyPhoto>;
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String fileName,
      String contentType,
      int fileSize,
      int sortOrder,
      bool hasThumbnail,
      int? uploadedById,
      DateTime? uploadedAt});
}

/// @nodoc
class _$PropertyPhotoCopyWithImpl<$Res, $Val extends PropertyPhoto>
    implements $PropertyPhotoCopyWith<$Res> {
  _$PropertyPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? fileSize = null,
    Object? sortOrder = null,
    Object? hasThumbnail = null,
    Object? uploadedById = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      hasThumbnail: null == hasThumbnail
          ? _value.hasThumbnail
          : hasThumbnail // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedById: freezed == uploadedById
          ? _value.uploadedById
          : uploadedById // ignore: cast_nullable_to_non_nullable
              as int?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyPhotoImplCopyWith<$Res>
    implements $PropertyPhotoCopyWith<$Res> {
  factory _$$PropertyPhotoImplCopyWith(
          _$PropertyPhotoImpl value, $Res Function(_$PropertyPhotoImpl) then) =
      __$$PropertyPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String fileName,
      String contentType,
      int fileSize,
      int sortOrder,
      bool hasThumbnail,
      int? uploadedById,
      DateTime? uploadedAt});
}

/// @nodoc
class __$$PropertyPhotoImplCopyWithImpl<$Res>
    extends _$PropertyPhotoCopyWithImpl<$Res, _$PropertyPhotoImpl>
    implements _$$PropertyPhotoImplCopyWith<$Res> {
  __$$PropertyPhotoImplCopyWithImpl(
      _$PropertyPhotoImpl _value, $Res Function(_$PropertyPhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? fileSize = null,
    Object? sortOrder = null,
    Object? hasThumbnail = null,
    Object? uploadedById = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(_$PropertyPhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      hasThumbnail: null == hasThumbnail
          ? _value.hasThumbnail
          : hasThumbnail // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedById: freezed == uploadedById
          ? _value.uploadedById
          : uploadedById // ignore: cast_nullable_to_non_nullable
              as int?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyPhotoImpl implements _PropertyPhoto {
  const _$PropertyPhotoImpl(
      {required this.id,
      required this.propertyId,
      this.fileName = '',
      this.contentType = 'image/jpeg',
      this.fileSize = 0,
      this.sortOrder = 0,
      this.hasThumbnail = false,
      this.uploadedById,
      this.uploadedAt});

  factory _$PropertyPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyPhotoImplFromJson(json);

  @override
  final int id;
  @override
  final int propertyId;
  @override
  @JsonKey()
  final String fileName;
  @override
  @JsonKey()
  final String contentType;
  @override
  @JsonKey()
  final int fileSize;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool hasThumbnail;
  @override
  final int? uploadedById;
  @override
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'PropertyPhoto(id: $id, propertyId: $propertyId, fileName: $fileName, contentType: $contentType, fileSize: $fileSize, sortOrder: $sortOrder, hasThumbnail: $hasThumbnail, uploadedById: $uploadedById, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyPhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.hasThumbnail, hasThumbnail) ||
                other.hasThumbnail == hasThumbnail) &&
            (identical(other.uploadedById, uploadedById) ||
                other.uploadedById == uploadedById) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, propertyId, fileName,
      contentType, fileSize, sortOrder, hasThumbnail, uploadedById, uploadedAt);

  /// Create a copy of PropertyPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyPhotoImplCopyWith<_$PropertyPhotoImpl> get copyWith =>
      __$$PropertyPhotoImplCopyWithImpl<_$PropertyPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyPhotoImplToJson(
      this,
    );
  }
}

abstract class _PropertyPhoto implements PropertyPhoto {
  const factory _PropertyPhoto(
      {required final int id,
      required final int propertyId,
      final String fileName,
      final String contentType,
      final int fileSize,
      final int sortOrder,
      final bool hasThumbnail,
      final int? uploadedById,
      final DateTime? uploadedAt}) = _$PropertyPhotoImpl;

  factory _PropertyPhoto.fromJson(Map<String, dynamic> json) =
      _$PropertyPhotoImpl.fromJson;

  @override
  int get id;
  @override
  int get propertyId;
  @override
  String get fileName;
  @override
  String get contentType;
  @override
  int get fileSize;
  @override
  int get sortOrder;
  @override
  bool get hasThumbnail;
  @override
  int? get uploadedById;
  @override
  DateTime? get uploadedAt;

  /// Create a copy of PropertyPhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyPhotoImplCopyWith<_$PropertyPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientMatch _$ClientMatchFromJson(Map<String, dynamic> json) {
  return _ClientMatch.fromJson(json);
}

/// @nodoc
mixin _$ClientMatch {
  ClientResponse get client => throw _privateConstructorUsedError;
  bool get overBudget => throw _privateConstructorUsedError;

  /// Serializes this ClientMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientMatchCopyWith<ClientMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientMatchCopyWith<$Res> {
  factory $ClientMatchCopyWith(
          ClientMatch value, $Res Function(ClientMatch) then) =
      _$ClientMatchCopyWithImpl<$Res, ClientMatch>;
  @useResult
  $Res call({ClientResponse client, bool overBudget});

  $ClientResponseCopyWith<$Res> get client;
}

/// @nodoc
class _$ClientMatchCopyWithImpl<$Res, $Val extends ClientMatch>
    implements $ClientMatchCopyWith<$Res> {
  _$ClientMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? client = null,
    Object? overBudget = null,
  }) {
    return _then(_value.copyWith(
      client: null == client
          ? _value.client
          : client // ignore: cast_nullable_to_non_nullable
              as ClientResponse,
      overBudget: null == overBudget
          ? _value.overBudget
          : overBudget // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClientResponseCopyWith<$Res> get client {
    return $ClientResponseCopyWith<$Res>(_value.client, (value) {
      return _then(_value.copyWith(client: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClientMatchImplCopyWith<$Res>
    implements $ClientMatchCopyWith<$Res> {
  factory _$$ClientMatchImplCopyWith(
          _$ClientMatchImpl value, $Res Function(_$ClientMatchImpl) then) =
      __$$ClientMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ClientResponse client, bool overBudget});

  @override
  $ClientResponseCopyWith<$Res> get client;
}

/// @nodoc
class __$$ClientMatchImplCopyWithImpl<$Res>
    extends _$ClientMatchCopyWithImpl<$Res, _$ClientMatchImpl>
    implements _$$ClientMatchImplCopyWith<$Res> {
  __$$ClientMatchImplCopyWithImpl(
      _$ClientMatchImpl _value, $Res Function(_$ClientMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? client = null,
    Object? overBudget = null,
  }) {
    return _then(_$ClientMatchImpl(
      client: null == client
          ? _value.client
          : client // ignore: cast_nullable_to_non_nullable
              as ClientResponse,
      overBudget: null == overBudget
          ? _value.overBudget
          : overBudget // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientMatchImpl implements _ClientMatch {
  const _$ClientMatchImpl({required this.client, this.overBudget = false});

  factory _$ClientMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientMatchImplFromJson(json);

  @override
  final ClientResponse client;
  @override
  @JsonKey()
  final bool overBudget;

  @override
  String toString() {
    return 'ClientMatch(client: $client, overBudget: $overBudget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientMatchImpl &&
            (identical(other.client, client) || other.client == client) &&
            (identical(other.overBudget, overBudget) ||
                other.overBudget == overBudget));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, client, overBudget);

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientMatchImplCopyWith<_$ClientMatchImpl> get copyWith =>
      __$$ClientMatchImplCopyWithImpl<_$ClientMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientMatchImplToJson(
      this,
    );
  }
}

abstract class _ClientMatch implements ClientMatch {
  const factory _ClientMatch(
      {required final ClientResponse client,
      final bool overBudget}) = _$ClientMatchImpl;

  factory _ClientMatch.fromJson(Map<String, dynamic> json) =
      _$ClientMatchImpl.fromJson;

  @override
  ClientResponse get client;
  @override
  bool get overBudget;

  /// Create a copy of ClientMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientMatchImplCopyWith<_$ClientMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DealResponse _$DealResponseFromJson(Map<String, dynamic> json) {
  return _DealResponse.fromJson(json);
}

/// @nodoc
mixin _$DealResponse {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DealStatus get status => throw _privateConstructorUsedError;
  double? get dealPrice => throw _privateConstructorUsedError;
  double? get budget => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;
  String get clientName => throw _privateConstructorUsedError;
  int? get propertyId => throw _privateConstructorUsedError;
  String? get propertyTitle => throw _privateConstructorUsedError;
  String? get propertyAddress => throw _privateConstructorUsedError;
  int get agentId => throw _privateConstructorUsedError;
  String get agentName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;

  /// Serializes this DealResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealResponseCopyWith<DealResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealResponseCopyWith<$Res> {
  factory $DealResponseCopyWith(
          DealResponse value, $Res Function(DealResponse) then) =
      _$DealResponseCopyWithImpl<$Res, DealResponse>;
  @useResult
  $Res call(
      {int id,
      String title,
      DealStatus status,
      double? dealPrice,
      double? budget,
      String? notes,
      int clientId,
      String clientName,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      int agentId,
      String agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? closedAt});
}

/// @nodoc
class _$DealResponseCopyWithImpl<$Res, $Val extends DealResponse>
    implements $DealResponseCopyWith<$Res> {
  _$DealResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? dealPrice = freezed,
    Object? budget = freezed,
    Object? notes = freezed,
    Object? clientId = null,
    Object? clientName = null,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? propertyAddress = freezed,
    Object? agentId = null,
    Object? agentName = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus,
      dealPrice: freezed == dealPrice
          ? _value.dealPrice
          : dealPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      agentName: null == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealResponseImplCopyWith<$Res>
    implements $DealResponseCopyWith<$Res> {
  factory _$$DealResponseImplCopyWith(
          _$DealResponseImpl value, $Res Function(_$DealResponseImpl) then) =
      __$$DealResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      DealStatus status,
      double? dealPrice,
      double? budget,
      String? notes,
      int clientId,
      String clientName,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      int agentId,
      String agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? closedAt});
}

/// @nodoc
class __$$DealResponseImplCopyWithImpl<$Res>
    extends _$DealResponseCopyWithImpl<$Res, _$DealResponseImpl>
    implements _$$DealResponseImplCopyWith<$Res> {
  __$$DealResponseImplCopyWithImpl(
      _$DealResponseImpl _value, $Res Function(_$DealResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? dealPrice = freezed,
    Object? budget = freezed,
    Object? notes = freezed,
    Object? clientId = null,
    Object? clientName = null,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? propertyAddress = freezed,
    Object? agentId = null,
    Object? agentName = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? closedAt = freezed,
  }) {
    return _then(_$DealResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus,
      dealPrice: freezed == dealPrice
          ? _value.dealPrice
          : dealPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      agentName: null == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealResponseImpl implements _DealResponse {
  const _$DealResponseImpl(
      {required this.id,
      this.title = '',
      this.status = DealStatus.LEAD,
      this.dealPrice,
      this.budget,
      this.notes,
      required this.clientId,
      this.clientName = '',
      this.propertyId,
      this.propertyTitle,
      this.propertyAddress,
      required this.agentId,
      this.agentName = '',
      this.createdAt,
      this.updatedAt,
      this.closedAt});

  factory _$DealResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final DealStatus status;
  @override
  final double? dealPrice;
  @override
  final double? budget;
  @override
  final String? notes;
  @override
  final int clientId;
  @override
  @JsonKey()
  final String clientName;
  @override
  final int? propertyId;
  @override
  final String? propertyTitle;
  @override
  final String? propertyAddress;
  @override
  final int agentId;
  @override
  @JsonKey()
  final String agentName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? closedAt;

  @override
  String toString() {
    return 'DealResponse(id: $id, title: $title, status: $status, dealPrice: $dealPrice, budget: $budget, notes: $notes, clientId: $clientId, clientName: $clientName, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dealPrice, dealPrice) ||
                other.dealPrice == dealPrice) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.propertyAddress, propertyAddress) ||
                other.propertyAddress == propertyAddress) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      status,
      dealPrice,
      budget,
      notes,
      clientId,
      clientName,
      propertyId,
      propertyTitle,
      propertyAddress,
      agentId,
      agentName,
      createdAt,
      updatedAt,
      closedAt);

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealResponseImplCopyWith<_$DealResponseImpl> get copyWith =>
      __$$DealResponseImplCopyWithImpl<_$DealResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealResponseImplToJson(
      this,
    );
  }
}

abstract class _DealResponse implements DealResponse {
  const factory _DealResponse(
      {required final int id,
      final String title,
      final DealStatus status,
      final double? dealPrice,
      final double? budget,
      final String? notes,
      required final int clientId,
      final String clientName,
      final int? propertyId,
      final String? propertyTitle,
      final String? propertyAddress,
      required final int agentId,
      final String agentName,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? closedAt}) = _$DealResponseImpl;

  factory _DealResponse.fromJson(Map<String, dynamic> json) =
      _$DealResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  DealStatus get status;
  @override
  double? get dealPrice;
  @override
  double? get budget;
  @override
  String? get notes;
  @override
  int get clientId;
  @override
  String get clientName;
  @override
  int? get propertyId;
  @override
  String? get propertyTitle;
  @override
  String? get propertyAddress;
  @override
  int get agentId;
  @override
  String get agentName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get closedAt;

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealResponseImplCopyWith<_$DealResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeetingResponse _$MeetingResponseFromJson(Map<String, dynamic> json) {
  return _MeetingResponse.fromJson(json);
}

/// @nodoc
mixin _$MeetingResponse {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  int? get dealId => throw _privateConstructorUsedError;
  String? get dealTitle => throw _privateConstructorUsedError;
  int? get propertyId => throw _privateConstructorUsedError;
  String? get propertyTitle => throw _privateConstructorUsedError;
  String? get propertyAddress => throw _privateConstructorUsedError;
  ViewingOutcome? get outcome => throw _privateConstructorUsedError;
  String? get outcomeNote => throw _privateConstructorUsedError;
  int get agentId => throw _privateConstructorUsedError;
  String get agentName => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;
  String get clientName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MeetingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingResponseCopyWith<MeetingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingResponseCopyWith<$Res> {
  factory $MeetingResponseCopyWith(
          MeetingResponse value, $Res Function(MeetingResponse) then) =
      _$MeetingResponseCopyWithImpl<$Res, MeetingResponse>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      DateTime scheduledAt,
      String? location,
      bool completed,
      int? dealId,
      String? dealTitle,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      ViewingOutcome? outcome,
      String? outcomeNote,
      int agentId,
      String agentName,
      int clientId,
      String clientName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$MeetingResponseCopyWithImpl<$Res, $Val extends MeetingResponse>
    implements $MeetingResponseCopyWith<$Res> {
  _$MeetingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? scheduledAt = null,
    Object? location = freezed,
    Object? completed = null,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? propertyAddress = freezed,
    Object? outcome = freezed,
    Object? outcomeNote = freezed,
    Object? agentId = null,
    Object? agentName = null,
    Object? clientId = null,
    Object? clientName = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as ViewingOutcome?,
      outcomeNote: freezed == outcomeNote
          ? _value.outcomeNote
          : outcomeNote // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      agentName: null == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingResponseImplCopyWith<$Res>
    implements $MeetingResponseCopyWith<$Res> {
  factory _$$MeetingResponseImplCopyWith(_$MeetingResponseImpl value,
          $Res Function(_$MeetingResponseImpl) then) =
      __$$MeetingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      DateTime scheduledAt,
      String? location,
      bool completed,
      int? dealId,
      String? dealTitle,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      ViewingOutcome? outcome,
      String? outcomeNote,
      int agentId,
      String agentName,
      int clientId,
      String clientName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$MeetingResponseImplCopyWithImpl<$Res>
    extends _$MeetingResponseCopyWithImpl<$Res, _$MeetingResponseImpl>
    implements _$$MeetingResponseImplCopyWith<$Res> {
  __$$MeetingResponseImplCopyWithImpl(
      _$MeetingResponseImpl _value, $Res Function(_$MeetingResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? scheduledAt = null,
    Object? location = freezed,
    Object? completed = null,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? propertyAddress = freezed,
    Object? outcome = freezed,
    Object? outcomeNote = freezed,
    Object? agentId = null,
    Object? agentName = null,
    Object? clientId = null,
    Object? clientName = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MeetingResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as ViewingOutcome?,
      outcomeNote: freezed == outcomeNote
          ? _value.outcomeNote
          : outcomeNote // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int,
      agentName: null == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingResponseImpl implements _MeetingResponse {
  const _$MeetingResponseImpl(
      {required this.id,
      this.title = '',
      this.description,
      required this.scheduledAt,
      this.location,
      this.completed = false,
      this.dealId,
      this.dealTitle,
      this.propertyId,
      this.propertyTitle,
      this.propertyAddress,
      this.outcome,
      this.outcomeNote,
      required this.agentId,
      this.agentName = '',
      required this.clientId,
      this.clientName = '',
      this.createdAt,
      this.updatedAt});

  factory _$MeetingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  final String? description;
  @override
  final DateTime scheduledAt;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool completed;
  @override
  final int? dealId;
  @override
  final String? dealTitle;
  @override
  final int? propertyId;
  @override
  final String? propertyTitle;
  @override
  final String? propertyAddress;
  @override
  final ViewingOutcome? outcome;
  @override
  final String? outcomeNote;
  @override
  final int agentId;
  @override
  @JsonKey()
  final String agentName;
  @override
  final int clientId;
  @override
  @JsonKey()
  final String clientName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MeetingResponse(id: $id, title: $title, description: $description, scheduledAt: $scheduledAt, location: $location, completed: $completed, dealId: $dealId, dealTitle: $dealTitle, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, outcome: $outcome, outcomeNote: $outcomeNote, agentId: $agentId, agentName: $agentName, clientId: $clientId, clientName: $clientName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.propertyAddress, propertyAddress) ||
                other.propertyAddress == propertyAddress) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.outcomeNote, outcomeNote) ||
                other.outcomeNote == outcomeNote) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        scheduledAt,
        location,
        completed,
        dealId,
        dealTitle,
        propertyId,
        propertyTitle,
        propertyAddress,
        outcome,
        outcomeNote,
        agentId,
        agentName,
        clientId,
        clientName,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of MeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingResponseImplCopyWith<_$MeetingResponseImpl> get copyWith =>
      __$$MeetingResponseImplCopyWithImpl<_$MeetingResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingResponseImplToJson(
      this,
    );
  }
}

abstract class _MeetingResponse implements MeetingResponse {
  const factory _MeetingResponse(
      {required final int id,
      final String title,
      final String? description,
      required final DateTime scheduledAt,
      final String? location,
      final bool completed,
      final int? dealId,
      final String? dealTitle,
      final int? propertyId,
      final String? propertyTitle,
      final String? propertyAddress,
      final ViewingOutcome? outcome,
      final String? outcomeNote,
      required final int agentId,
      final String agentName,
      required final int clientId,
      final String clientName,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$MeetingResponseImpl;

  factory _MeetingResponse.fromJson(Map<String, dynamic> json) =
      _$MeetingResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  DateTime get scheduledAt;
  @override
  String? get location;
  @override
  bool get completed;
  @override
  int? get dealId;
  @override
  String? get dealTitle;
  @override
  int? get propertyId;
  @override
  String? get propertyTitle;
  @override
  String? get propertyAddress;
  @override
  ViewingOutcome? get outcome;
  @override
  String? get outcomeNote;
  @override
  int get agentId;
  @override
  String get agentName;
  @override
  int get clientId;
  @override
  String get clientName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingResponseImplCopyWith<_$MeetingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpcomingMeetingResponse _$UpcomingMeetingResponseFromJson(
    Map<String, dynamic> json) {
  return _UpcomingMeetingResponse.fromJson(json);
}

/// @nodoc
mixin _$UpcomingMeetingResponse {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  String get clientName => throw _privateConstructorUsedError;

  /// Serializes this UpcomingMeetingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingMeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingMeetingResponseCopyWith<UpcomingMeetingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingMeetingResponseCopyWith<$Res> {
  factory $UpcomingMeetingResponseCopyWith(UpcomingMeetingResponse value,
          $Res Function(UpcomingMeetingResponse) then) =
      _$UpcomingMeetingResponseCopyWithImpl<$Res, UpcomingMeetingResponse>;
  @useResult
  $Res call({int id, String title, DateTime scheduledAt, String clientName});
}

/// @nodoc
class _$UpcomingMeetingResponseCopyWithImpl<$Res,
        $Val extends UpcomingMeetingResponse>
    implements $UpcomingMeetingResponseCopyWith<$Res> {
  _$UpcomingMeetingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingMeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? scheduledAt = null,
    Object? clientName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpcomingMeetingResponseImplCopyWith<$Res>
    implements $UpcomingMeetingResponseCopyWith<$Res> {
  factory _$$UpcomingMeetingResponseImplCopyWith(
          _$UpcomingMeetingResponseImpl value,
          $Res Function(_$UpcomingMeetingResponseImpl) then) =
      __$$UpcomingMeetingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, DateTime scheduledAt, String clientName});
}

/// @nodoc
class __$$UpcomingMeetingResponseImplCopyWithImpl<$Res>
    extends _$UpcomingMeetingResponseCopyWithImpl<$Res,
        _$UpcomingMeetingResponseImpl>
    implements _$$UpcomingMeetingResponseImplCopyWith<$Res> {
  __$$UpcomingMeetingResponseImplCopyWithImpl(
      _$UpcomingMeetingResponseImpl _value,
      $Res Function(_$UpcomingMeetingResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpcomingMeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? scheduledAt = null,
    Object? clientName = null,
  }) {
    return _then(_$UpcomingMeetingResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingMeetingResponseImpl implements _UpcomingMeetingResponse {
  const _$UpcomingMeetingResponseImpl(
      {required this.id,
      this.title = '',
      required this.scheduledAt,
      this.clientName = ''});

  factory _$UpcomingMeetingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingMeetingResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  final DateTime scheduledAt;
  @override
  @JsonKey()
  final String clientName;

  @override
  String toString() {
    return 'UpcomingMeetingResponse(id: $id, title: $title, scheduledAt: $scheduledAt, clientName: $clientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingMeetingResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, scheduledAt, clientName);

  /// Create a copy of UpcomingMeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingMeetingResponseImplCopyWith<_$UpcomingMeetingResponseImpl>
      get copyWith => __$$UpcomingMeetingResponseImplCopyWithImpl<
          _$UpcomingMeetingResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingMeetingResponseImplToJson(
      this,
    );
  }
}

abstract class _UpcomingMeetingResponse implements UpcomingMeetingResponse {
  const factory _UpcomingMeetingResponse(
      {required final int id,
      final String title,
      required final DateTime scheduledAt,
      final String clientName}) = _$UpcomingMeetingResponseImpl;

  factory _UpcomingMeetingResponse.fromJson(Map<String, dynamic> json) =
      _$UpcomingMeetingResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  DateTime get scheduledAt;
  @override
  String get clientName;

  /// Create a copy of UpcomingMeetingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingMeetingResponseImplCopyWith<_$UpcomingMeetingResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) {
  return _DashboardSummary.fromJson(json);
}

/// @nodoc
mixin _$DashboardSummary {
  int get totalDeals => throw _privateConstructorUsedError;
  int get activeDeals => throw _privateConstructorUsedError;
  int get closedDeals => throw _privateConstructorUsedError;
  int get totalClients => throw _privateConstructorUsedError;
  int get upcomingMeetings => throw _privateConstructorUsedError;

  /// Serializes this DashboardSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardSummaryCopyWith<DashboardSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardSummaryCopyWith<$Res> {
  factory $DashboardSummaryCopyWith(
          DashboardSummary value, $Res Function(DashboardSummary) then) =
      _$DashboardSummaryCopyWithImpl<$Res, DashboardSummary>;
  @useResult
  $Res call(
      {int totalDeals,
      int activeDeals,
      int closedDeals,
      int totalClients,
      int upcomingMeetings});
}

/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res, $Val extends DashboardSummary>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeals = null,
    Object? activeDeals = null,
    Object? closedDeals = null,
    Object? totalClients = null,
    Object? upcomingMeetings = null,
  }) {
    return _then(_value.copyWith(
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      closedDeals: null == closedDeals
          ? _value.closedDeals
          : closedDeals // ignore: cast_nullable_to_non_nullable
              as int,
      totalClients: null == totalClients
          ? _value.totalClients
          : totalClients // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingMeetings: null == upcomingMeetings
          ? _value.upcomingMeetings
          : upcomingMeetings // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardSummaryImplCopyWith<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  factory _$$DashboardSummaryImplCopyWith(_$DashboardSummaryImpl value,
          $Res Function(_$DashboardSummaryImpl) then) =
      __$$DashboardSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalDeals,
      int activeDeals,
      int closedDeals,
      int totalClients,
      int upcomingMeetings});
}

/// @nodoc
class __$$DashboardSummaryImplCopyWithImpl<$Res>
    extends _$DashboardSummaryCopyWithImpl<$Res, _$DashboardSummaryImpl>
    implements _$$DashboardSummaryImplCopyWith<$Res> {
  __$$DashboardSummaryImplCopyWithImpl(_$DashboardSummaryImpl _value,
      $Res Function(_$DashboardSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeals = null,
    Object? activeDeals = null,
    Object? closedDeals = null,
    Object? totalClients = null,
    Object? upcomingMeetings = null,
  }) {
    return _then(_$DashboardSummaryImpl(
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      closedDeals: null == closedDeals
          ? _value.closedDeals
          : closedDeals // ignore: cast_nullable_to_non_nullable
              as int,
      totalClients: null == totalClients
          ? _value.totalClients
          : totalClients // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingMeetings: null == upcomingMeetings
          ? _value.upcomingMeetings
          : upcomingMeetings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardSummaryImpl implements _DashboardSummary {
  const _$DashboardSummaryImpl(
      {this.totalDeals = 0,
      this.activeDeals = 0,
      this.closedDeals = 0,
      this.totalClients = 0,
      this.upcomingMeetings = 0});

  factory _$DashboardSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int totalDeals;
  @override
  @JsonKey()
  final int activeDeals;
  @override
  @JsonKey()
  final int closedDeals;
  @override
  @JsonKey()
  final int totalClients;
  @override
  @JsonKey()
  final int upcomingMeetings;

  @override
  String toString() {
    return 'DashboardSummary(totalDeals: $totalDeals, activeDeals: $activeDeals, closedDeals: $closedDeals, totalClients: $totalClients, upcomingMeetings: $upcomingMeetings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardSummaryImpl &&
            (identical(other.totalDeals, totalDeals) ||
                other.totalDeals == totalDeals) &&
            (identical(other.activeDeals, activeDeals) ||
                other.activeDeals == activeDeals) &&
            (identical(other.closedDeals, closedDeals) ||
                other.closedDeals == closedDeals) &&
            (identical(other.totalClients, totalClients) ||
                other.totalClients == totalClients) &&
            (identical(other.upcomingMeetings, upcomingMeetings) ||
                other.upcomingMeetings == upcomingMeetings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalDeals, activeDeals,
      closedDeals, totalClients, upcomingMeetings);

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      __$$DashboardSummaryImplCopyWithImpl<_$DashboardSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardSummaryImplToJson(
      this,
    );
  }
}

abstract class _DashboardSummary implements DashboardSummary {
  const factory _DashboardSummary(
      {final int totalDeals,
      final int activeDeals,
      final int closedDeals,
      final int totalClients,
      final int upcomingMeetings}) = _$DashboardSummaryImpl;

  factory _DashboardSummary.fromJson(Map<String, dynamic> json) =
      _$DashboardSummaryImpl.fromJson;

  @override
  int get totalDeals;
  @override
  int get activeDeals;
  @override
  int get closedDeals;
  @override
  int get totalClients;
  @override
  int get upcomingMeetings;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentOption _$AgentOptionFromJson(Map<String, dynamic> json) {
  return _AgentOption.fromJson(json);
}

/// @nodoc
mixin _$AgentOption {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  /// Serializes this AgentOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentOptionCopyWith<AgentOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentOptionCopyWith<$Res> {
  factory $AgentOptionCopyWith(
          AgentOption value, $Res Function(AgentOption) then) =
      _$AgentOptionCopyWithImpl<$Res, AgentOption>;
  @useResult
  $Res call({int id, String fullName, String? email});
}

/// @nodoc
class _$AgentOptionCopyWithImpl<$Res, $Val extends AgentOption>
    implements $AgentOptionCopyWith<$Res> {
  _$AgentOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AgentOptionImplCopyWith<$Res>
    implements $AgentOptionCopyWith<$Res> {
  factory _$$AgentOptionImplCopyWith(
          _$AgentOptionImpl value, $Res Function(_$AgentOptionImpl) then) =
      __$$AgentOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String fullName, String? email});
}

/// @nodoc
class __$$AgentOptionImplCopyWithImpl<$Res>
    extends _$AgentOptionCopyWithImpl<$Res, _$AgentOptionImpl>
    implements _$$AgentOptionImplCopyWith<$Res> {
  __$$AgentOptionImplCopyWithImpl(
      _$AgentOptionImpl _value, $Res Function(_$AgentOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AgentOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
  }) {
    return _then(_$AgentOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentOptionImpl implements _AgentOption {
  const _$AgentOptionImpl(
      {required this.id, required this.fullName, this.email});

  factory _$AgentOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentOptionImplFromJson(json);

  @override
  final int id;
  @override
  final String fullName;
  @override
  final String? email;

  @override
  String toString() {
    return 'AgentOption(id: $id, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, email);

  /// Create a copy of AgentOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentOptionImplCopyWith<_$AgentOptionImpl> get copyWith =>
      __$$AgentOptionImplCopyWithImpl<_$AgentOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentOptionImplToJson(
      this,
    );
  }
}

abstract class _AgentOption implements AgentOption {
  const factory _AgentOption(
      {required final int id,
      required final String fullName,
      final String? email}) = _$AgentOptionImpl;

  factory _AgentOption.fromJson(Map<String, dynamic> json) =
      _$AgentOptionImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  String? get email;

  /// Create a copy of AgentOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentOptionImplCopyWith<_$AgentOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
