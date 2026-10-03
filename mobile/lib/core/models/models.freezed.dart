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

  /// The team's currency (ISO 4217), or null with no team; see AppCurrency.
  String? get teamCurrency => throw _privateConstructorUsedError;

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
      String? teamName,
      String? teamCurrency});
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
    Object? teamCurrency = freezed,
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
      teamCurrency: freezed == teamCurrency
          ? _value.teamCurrency
          : teamCurrency // ignore: cast_nullable_to_non_nullable
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
      String? teamName,
      String? teamCurrency});
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
    Object? teamCurrency = freezed,
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
      teamCurrency: freezed == teamCurrency
          ? _value.teamCurrency
          : teamCurrency // ignore: cast_nullable_to_non_nullable
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
      this.teamName,
      this.teamCurrency});

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

  /// The team's currency (ISO 4217), or null with no team; see AppCurrency.
  @override
  final String? teamCurrency;

  @override
  String toString() {
    return 'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, userId: $userId, fullName: $fullName, email: $email, role: $role, teamId: $teamId, teamName: $teamName, teamCurrency: $teamCurrency)';
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
                other.teamName == teamName) &&
            (identical(other.teamCurrency, teamCurrency) ||
                other.teamCurrency == teamCurrency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken,
      tokenType, userId, fullName, email, role, teamId, teamName, teamCurrency);

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
      final String? teamName,
      final String? teamCurrency}) = _$AuthResponseImpl;

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

  /// The team's currency (ISO 4217), or null with no team; see AppCurrency.
  @override
  String? get teamCurrency;

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
  @JsonKey(unknownEnumValue: ClientSource.manual)
  ClientSource get source => throw _privateConstructorUsedError;
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

  /// The agency's tags on this client, in name order.
  List<String> get tags => throw _privateConstructorUsedError;

  /// How the client reached the agency; null when nobody recorded it.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  LeadSource? get leadSource => throw _privateConstructorUsedError;
  String? get leadSourceDetail => throw _privateConstructorUsedError;

  /// `1990-05-14`, or `--05-14` when the year is not known. Read it
  /// through `ClientBirthday.parse`.
  String? get birthday => throw _privateConstructorUsedError;

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
      @JsonKey(unknownEnumValue: ClientSource.manual) ClientSource source,
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
      double? minAreaSqm,
      List<String> tags,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      LeadSource? leadSource,
      String? leadSourceDetail,
      String? birthday});
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
    Object? source = null,
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
    Object? tags = null,
    Object? leadSource = freezed,
    Object? leadSourceDetail = freezed,
    Object? birthday = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ClientSource,
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
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      leadSource: freezed == leadSource
          ? _value.leadSource
          : leadSource // ignore: cast_nullable_to_non_nullable
              as LeadSource?,
      leadSourceDetail: freezed == leadSourceDetail
          ? _value.leadSourceDetail
          : leadSourceDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
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
      @JsonKey(unknownEnumValue: ClientSource.manual) ClientSource source,
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
      double? minAreaSqm,
      List<String> tags,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      LeadSource? leadSource,
      String? leadSourceDetail,
      String? birthday});
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
    Object? source = null,
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
    Object? tags = null,
    Object? leadSource = freezed,
    Object? leadSourceDetail = freezed,
    Object? birthday = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ClientSource,
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
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      leadSource: freezed == leadSource
          ? _value.leadSource
          : leadSource // ignore: cast_nullable_to_non_nullable
              as LeadSource?,
      leadSourceDetail: freezed == leadSourceDetail
          ? _value.leadSourceDetail
          : leadSourceDetail // ignore: cast_nullable_to_non_nullable
              as String?,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
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
      @JsonKey(unknownEnumValue: ClientSource.manual)
      this.source = ClientSource.manual,
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
      this.minAreaSqm,
      final List<String> tags = const <String>[],
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.leadSource,
      this.leadSourceDetail,
      this.birthday})
      : _tags = tags;

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
  @JsonKey(unknownEnumValue: ClientSource.manual)
  final ClientSource source;
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

  /// The agency's tags on this client, in name order.
  final List<String> _tags;

  /// The agency's tags on this client, in name order.
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// How the client reached the agency; null when nobody recorded it.
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final LeadSource? leadSource;
  @override
  final String? leadSourceDetail;

  /// `1990-05-14`, or `--05-14` when the year is not known. Read it
  /// through `ClientBirthday.parse`.
  @override
  final String? birthday;

  @override
  String toString() {
    return 'ClientResponse(id: $id, fullName: $fullName, email: $email, phone: $phone, type: $type, source: $source, notes: $notes, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt, wantedType: $wantedType, wantedCity: $wantedCity, budgetMin: $budgetMin, budgetMax: $budgetMax, minRooms: $minRooms, minAreaSqm: $minAreaSqm, tags: $tags, leadSource: $leadSource, leadSourceDetail: $leadSourceDetail, birthday: $birthday)';
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
            (identical(other.source, source) || other.source == source) &&
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
                other.minAreaSqm == minAreaSqm) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.leadSource, leadSource) ||
                other.leadSource == leadSource) &&
            (identical(other.leadSourceDetail, leadSourceDetail) ||
                other.leadSourceDetail == leadSourceDetail) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        fullName,
        email,
        phone,
        type,
        source,
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
        minAreaSqm,
        const DeepCollectionEquality().hash(_tags),
        leadSource,
        leadSourceDetail,
        birthday
      ]);

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
      @JsonKey(unknownEnumValue: ClientSource.manual) final ClientSource source,
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
      final double? minAreaSqm,
      final List<String> tags,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final LeadSource? leadSource,
      final String? leadSourceDetail,
      final String? birthday}) = _$ClientResponseImpl;

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
  @JsonKey(unknownEnumValue: ClientSource.manual)
  ClientSource get source;
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

  /// The agency's tags on this client, in name order.
  @override
  List<String> get tags;

  /// How the client reached the agency; null when nobody recorded it.
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  LeadSource? get leadSource;
  @override
  String? get leadSourceDetail;

  /// `1990-05-14`, or `--05-14` when the year is not known. Read it
  /// through `ClientBirthday.parse`.
  @override
  String? get birthday;

  /// Create a copy of ClientResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientResponseImplCopyWith<_$ClientResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientTagUsage _$ClientTagUsageFromJson(Map<String, dynamic> json) {
  return _ClientTagUsage.fromJson(json);
}

/// @nodoc
mixin _$ClientTagUsage {
  String get name => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this ClientTagUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientTagUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientTagUsageCopyWith<ClientTagUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientTagUsageCopyWith<$Res> {
  factory $ClientTagUsageCopyWith(
          ClientTagUsage value, $Res Function(ClientTagUsage) then) =
      _$ClientTagUsageCopyWithImpl<$Res, ClientTagUsage>;
  @useResult
  $Res call({String name, int count});
}

/// @nodoc
class _$ClientTagUsageCopyWithImpl<$Res, $Val extends ClientTagUsage>
    implements $ClientTagUsageCopyWith<$Res> {
  _$ClientTagUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientTagUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientTagUsageImplCopyWith<$Res>
    implements $ClientTagUsageCopyWith<$Res> {
  factory _$$ClientTagUsageImplCopyWith(_$ClientTagUsageImpl value,
          $Res Function(_$ClientTagUsageImpl) then) =
      __$$ClientTagUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int count});
}

/// @nodoc
class __$$ClientTagUsageImplCopyWithImpl<$Res>
    extends _$ClientTagUsageCopyWithImpl<$Res, _$ClientTagUsageImpl>
    implements _$$ClientTagUsageImplCopyWith<$Res> {
  __$$ClientTagUsageImplCopyWithImpl(
      _$ClientTagUsageImpl _value, $Res Function(_$ClientTagUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientTagUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? count = null,
  }) {
    return _then(_$ClientTagUsageImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientTagUsageImpl implements _ClientTagUsage {
  const _$ClientTagUsageImpl({required this.name, this.count = 0});

  factory _$ClientTagUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientTagUsageImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'ClientTagUsage(name: $name, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientTagUsageImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, count);

  /// Create a copy of ClientTagUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientTagUsageImplCopyWith<_$ClientTagUsageImpl> get copyWith =>
      __$$ClientTagUsageImplCopyWithImpl<_$ClientTagUsageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientTagUsageImplToJson(
      this,
    );
  }
}

abstract class _ClientTagUsage implements ClientTagUsage {
  const factory _ClientTagUsage({required final String name, final int count}) =
      _$ClientTagUsageImpl;

  factory _ClientTagUsage.fromJson(Map<String, dynamic> json) =
      _$ClientTagUsageImpl.fromJson;

  @override
  String get name;
  @override
  int get count;

  /// Create a copy of ClientTagUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientTagUsageImplCopyWith<_$ClientTagUsageImpl> get copyWith =>
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
  @JsonKey(unknownEnumValue: ClientSource.manual)
  ClientSource get source => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

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
      DateTime? lastContactAt,
      @JsonKey(unknownEnumValue: ClientSource.manual) ClientSource source,
      DateTime? createdAt});
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
    Object? source = null,
    Object? createdAt = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ClientSource,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
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
      DateTime? lastContactAt,
      @JsonKey(unknownEnumValue: ClientSource.manual) ClientSource source,
      DateTime? createdAt});
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
    Object? source = null,
    Object? createdAt = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as ClientSource,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
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
      this.lastContactAt,
      @JsonKey(unknownEnumValue: ClientSource.manual)
      this.source = ClientSource.manual,
      this.createdAt});

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
  @JsonKey(unknownEnumValue: ClientSource.manual)
  final ClientSource source;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ClientListItem(id: $id, fullName: $fullName, phone: $phone, email: $email, status: $status, budget: $budget, propertyTitle: $propertyTitle, nextMeetingAt: $nextMeetingAt, lastContactAt: $lastContactAt, source: $source, createdAt: $createdAt)';
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
                other.lastContactAt == lastContactAt) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      phone,
      email,
      status,
      budget,
      propertyTitle,
      nextMeetingAt,
      lastContactAt,
      source,
      createdAt);

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
      final DateTime? lastContactAt,
      @JsonKey(unknownEnumValue: ClientSource.manual) final ClientSource source,
      final DateTime? createdAt}) = _$ClientListItemImpl;

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
  @override
  @JsonKey(unknownEnumValue: ClientSource.manual)
  ClientSource get source;
  @override
  DateTime? get createdAt;

  /// Create a copy of ClientListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientListItemImplCopyWith<_$ClientListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientActivity _$ClientActivityFromJson(Map<String, dynamic> json) {
  return _ClientActivity.fromJson(json);
}

/// @nodoc
mixin _$ClientActivity {
  int get id => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;
  ActivityType get type => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get occurredAt => throw _privateConstructorUsedError;
  int? get authorId => throw _privateConstructorUsedError;
  String? get authorName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// The listings this entry was about — what went out in a message.
  List<ActivityProperty> get properties => throw _privateConstructorUsedError;

  /// Set when the entry is a visit signed in at an open house.
  int? get openHouseId => throw _privateConstructorUsedError;

  /// Set, both of them, on the line a manager's handover wrote: who held
  /// the client before and who holds it now. The from name is empty when
  /// nobody held it.
  String? get handoverFromName => throw _privateConstructorUsedError;
  String? get handoverToName => throw _privateConstructorUsedError;

  /// Serializes this ClientActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientActivityCopyWith<ClientActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientActivityCopyWith<$Res> {
  factory $ClientActivityCopyWith(
          ClientActivity value, $Res Function(ClientActivity) then) =
      _$ClientActivityCopyWithImpl<$Res, ClientActivity>;
  @useResult
  $Res call(
      {int id,
      int clientId,
      ActivityType type,
      String? note,
      DateTime occurredAt,
      int? authorId,
      String? authorName,
      DateTime? createdAt,
      List<ActivityProperty> properties,
      int? openHouseId,
      String? handoverFromName,
      String? handoverToName});
}

/// @nodoc
class _$ClientActivityCopyWithImpl<$Res, $Val extends ClientActivity>
    implements $ClientActivityCopyWith<$Res> {
  _$ClientActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? type = null,
    Object? note = freezed,
    Object? occurredAt = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? createdAt = freezed,
    Object? properties = null,
    Object? openHouseId = freezed,
    Object? handoverFromName = freezed,
    Object? handoverToName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as List<ActivityProperty>,
      openHouseId: freezed == openHouseId
          ? _value.openHouseId
          : openHouseId // ignore: cast_nullable_to_non_nullable
              as int?,
      handoverFromName: freezed == handoverFromName
          ? _value.handoverFromName
          : handoverFromName // ignore: cast_nullable_to_non_nullable
              as String?,
      handoverToName: freezed == handoverToName
          ? _value.handoverToName
          : handoverToName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientActivityImplCopyWith<$Res>
    implements $ClientActivityCopyWith<$Res> {
  factory _$$ClientActivityImplCopyWith(_$ClientActivityImpl value,
          $Res Function(_$ClientActivityImpl) then) =
      __$$ClientActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int clientId,
      ActivityType type,
      String? note,
      DateTime occurredAt,
      int? authorId,
      String? authorName,
      DateTime? createdAt,
      List<ActivityProperty> properties,
      int? openHouseId,
      String? handoverFromName,
      String? handoverToName});
}

/// @nodoc
class __$$ClientActivityImplCopyWithImpl<$Res>
    extends _$ClientActivityCopyWithImpl<$Res, _$ClientActivityImpl>
    implements _$$ClientActivityImplCopyWith<$Res> {
  __$$ClientActivityImplCopyWithImpl(
      _$ClientActivityImpl _value, $Res Function(_$ClientActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? type = null,
    Object? note = freezed,
    Object? occurredAt = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? createdAt = freezed,
    Object? properties = null,
    Object? openHouseId = freezed,
    Object? handoverFromName = freezed,
    Object? handoverToName = freezed,
  }) {
    return _then(_$ClientActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as List<ActivityProperty>,
      openHouseId: freezed == openHouseId
          ? _value.openHouseId
          : openHouseId // ignore: cast_nullable_to_non_nullable
              as int?,
      handoverFromName: freezed == handoverFromName
          ? _value.handoverFromName
          : handoverFromName // ignore: cast_nullable_to_non_nullable
              as String?,
      handoverToName: freezed == handoverToName
          ? _value.handoverToName
          : handoverToName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientActivityImpl implements _ClientActivity {
  const _$ClientActivityImpl(
      {required this.id,
      required this.clientId,
      this.type = ActivityType.NOTE,
      this.note,
      required this.occurredAt,
      this.authorId,
      this.authorName,
      this.createdAt,
      final List<ActivityProperty> properties = const <ActivityProperty>[],
      this.openHouseId,
      this.handoverFromName,
      this.handoverToName})
      : _properties = properties;

  factory _$ClientActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientActivityImplFromJson(json);

  @override
  final int id;
  @override
  final int clientId;
  @override
  @JsonKey()
  final ActivityType type;
  @override
  final String? note;
  @override
  final DateTime occurredAt;
  @override
  final int? authorId;
  @override
  final String? authorName;
  @override
  final DateTime? createdAt;

  /// The listings this entry was about — what went out in a message.
  final List<ActivityProperty> _properties;

  /// The listings this entry was about — what went out in a message.
  @override
  @JsonKey()
  List<ActivityProperty> get properties {
    if (_properties is EqualUnmodifiableListView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_properties);
  }

  /// Set when the entry is a visit signed in at an open house.
  @override
  final int? openHouseId;

  /// Set, both of them, on the line a manager's handover wrote: who held
  /// the client before and who holds it now. The from name is empty when
  /// nobody held it.
  @override
  final String? handoverFromName;
  @override
  final String? handoverToName;

  @override
  String toString() {
    return 'ClientActivity(id: $id, clientId: $clientId, type: $type, note: $note, occurredAt: $occurredAt, authorId: $authorId, authorName: $authorName, createdAt: $createdAt, properties: $properties, openHouseId: $openHouseId, handoverFromName: $handoverFromName, handoverToName: $handoverToName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties) &&
            (identical(other.openHouseId, openHouseId) ||
                other.openHouseId == openHouseId) &&
            (identical(other.handoverFromName, handoverFromName) ||
                other.handoverFromName == handoverFromName) &&
            (identical(other.handoverToName, handoverToName) ||
                other.handoverToName == handoverToName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      clientId,
      type,
      note,
      occurredAt,
      authorId,
      authorName,
      createdAt,
      const DeepCollectionEquality().hash(_properties),
      openHouseId,
      handoverFromName,
      handoverToName);

  /// Create a copy of ClientActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientActivityImplCopyWith<_$ClientActivityImpl> get copyWith =>
      __$$ClientActivityImplCopyWithImpl<_$ClientActivityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientActivityImplToJson(
      this,
    );
  }
}

abstract class _ClientActivity implements ClientActivity {
  const factory _ClientActivity(
      {required final int id,
      required final int clientId,
      final ActivityType type,
      final String? note,
      required final DateTime occurredAt,
      final int? authorId,
      final String? authorName,
      final DateTime? createdAt,
      final List<ActivityProperty> properties,
      final int? openHouseId,
      final String? handoverFromName,
      final String? handoverToName}) = _$ClientActivityImpl;

  factory _ClientActivity.fromJson(Map<String, dynamic> json) =
      _$ClientActivityImpl.fromJson;

  @override
  int get id;
  @override
  int get clientId;
  @override
  ActivityType get type;
  @override
  String? get note;
  @override
  DateTime get occurredAt;
  @override
  int? get authorId;
  @override
  String? get authorName;
  @override
  DateTime? get createdAt;

  /// The listings this entry was about — what went out in a message.
  @override
  List<ActivityProperty> get properties;

  /// Set when the entry is a visit signed in at an open house.
  @override
  int? get openHouseId;

  /// Set, both of them, on the line a manager's handover wrote: who held
  /// the client before and who holds it now. The from name is empty when
  /// nobody held it.
  @override
  String? get handoverFromName;
  @override
  String? get handoverToName;

  /// Create a copy of ClientActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientActivityImplCopyWith<_$ClientActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityProperty _$ActivityPropertyFromJson(Map<String, dynamic> json) {
  return _ActivityProperty.fromJson(json);
}

/// @nodoc
mixin _$ActivityProperty {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this ActivityProperty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityProperty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityPropertyCopyWith<ActivityProperty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityPropertyCopyWith<$Res> {
  factory $ActivityPropertyCopyWith(
          ActivityProperty value, $Res Function(ActivityProperty) then) =
      _$ActivityPropertyCopyWithImpl<$Res, ActivityProperty>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$ActivityPropertyCopyWithImpl<$Res, $Val extends ActivityProperty>
    implements $ActivityPropertyCopyWith<$Res> {
  _$ActivityPropertyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityProperty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityPropertyImplCopyWith<$Res>
    implements $ActivityPropertyCopyWith<$Res> {
  factory _$$ActivityPropertyImplCopyWith(_$ActivityPropertyImpl value,
          $Res Function(_$ActivityPropertyImpl) then) =
      __$$ActivityPropertyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$ActivityPropertyImplCopyWithImpl<$Res>
    extends _$ActivityPropertyCopyWithImpl<$Res, _$ActivityPropertyImpl>
    implements _$$ActivityPropertyImplCopyWith<$Res> {
  __$$ActivityPropertyImplCopyWithImpl(_$ActivityPropertyImpl _value,
      $Res Function(_$ActivityPropertyImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityProperty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$ActivityPropertyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityPropertyImpl implements _ActivityProperty {
  const _$ActivityPropertyImpl({required this.id, this.title = ''});

  factory _$ActivityPropertyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityPropertyImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;

  @override
  String toString() {
    return 'ActivityProperty(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityPropertyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of ActivityProperty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityPropertyImplCopyWith<_$ActivityPropertyImpl> get copyWith =>
      __$$ActivityPropertyImplCopyWithImpl<_$ActivityPropertyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityPropertyImplToJson(
      this,
    );
  }
}

abstract class _ActivityProperty implements ActivityProperty {
  const factory _ActivityProperty({required final int id, final String title}) =
      _$ActivityPropertyImpl;

  factory _ActivityProperty.fromJson(Map<String, dynamic> json) =
      _$ActivityPropertyImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of ActivityProperty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityPropertyImplCopyWith<_$ActivityPropertyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClientDuplicate _$ClientDuplicateFromJson(Map<String, dynamic> json) {
  return _ClientDuplicate.fromJson(json);
}

/// @nodoc
mixin _$ClientDuplicate {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  ClientType get type => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
  DuplicateMatch get matchedOn => throw _privateConstructorUsedError;

  /// Whether this person may open the card: an agent on their own clients
  /// learns who holds a colleague's buyer, not the file itself.
  bool get visible => throw _privateConstructorUsedError;

  /// Serializes this ClientDuplicate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientDuplicate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientDuplicateCopyWith<ClientDuplicate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientDuplicateCopyWith<$Res> {
  factory $ClientDuplicateCopyWith(
          ClientDuplicate value, $Res Function(ClientDuplicate) then) =
      _$ClientDuplicateCopyWithImpl<$Res, ClientDuplicate>;
  @useResult
  $Res call(
      {int id,
      String fullName,
      ClientType type,
      int? agentId,
      String? agentName,
      String? phone,
      String? email,
      @JsonKey(unknownEnumValue: DuplicateMatch.PHONE) DuplicateMatch matchedOn,
      bool visible});
}

/// @nodoc
class _$ClientDuplicateCopyWithImpl<$Res, $Val extends ClientDuplicate>
    implements $ClientDuplicateCopyWith<$Res> {
  _$ClientDuplicateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientDuplicate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? type = null,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? matchedOn = null,
    Object? visible = null,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedOn: null == matchedOn
          ? _value.matchedOn
          : matchedOn // ignore: cast_nullable_to_non_nullable
              as DuplicateMatch,
      visible: null == visible
          ? _value.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientDuplicateImplCopyWith<$Res>
    implements $ClientDuplicateCopyWith<$Res> {
  factory _$$ClientDuplicateImplCopyWith(_$ClientDuplicateImpl value,
          $Res Function(_$ClientDuplicateImpl) then) =
      __$$ClientDuplicateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String fullName,
      ClientType type,
      int? agentId,
      String? agentName,
      String? phone,
      String? email,
      @JsonKey(unknownEnumValue: DuplicateMatch.PHONE) DuplicateMatch matchedOn,
      bool visible});
}

/// @nodoc
class __$$ClientDuplicateImplCopyWithImpl<$Res>
    extends _$ClientDuplicateCopyWithImpl<$Res, _$ClientDuplicateImpl>
    implements _$$ClientDuplicateImplCopyWith<$Res> {
  __$$ClientDuplicateImplCopyWithImpl(
      _$ClientDuplicateImpl _value, $Res Function(_$ClientDuplicateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientDuplicate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? type = null,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? matchedOn = null,
    Object? visible = null,
  }) {
    return _then(_$ClientDuplicateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      matchedOn: null == matchedOn
          ? _value.matchedOn
          : matchedOn // ignore: cast_nullable_to_non_nullable
              as DuplicateMatch,
      visible: null == visible
          ? _value.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientDuplicateImpl implements _ClientDuplicate {
  const _$ClientDuplicateImpl(
      {required this.id,
      this.fullName = '',
      this.type = ClientType.BUYER,
      this.agentId,
      this.agentName,
      this.phone,
      this.email,
      @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
      this.matchedOn = DuplicateMatch.PHONE,
      this.visible = true});

  factory _$ClientDuplicateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientDuplicateImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final ClientType type;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
  final DuplicateMatch matchedOn;

  /// Whether this person may open the card: an agent on their own clients
  /// learns who holds a colleague's buyer, not the file itself.
  @override
  @JsonKey()
  final bool visible;

  @override
  String toString() {
    return 'ClientDuplicate(id: $id, fullName: $fullName, type: $type, agentId: $agentId, agentName: $agentName, phone: $phone, email: $email, matchedOn: $matchedOn, visible: $visible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientDuplicateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.matchedOn, matchedOn) ||
                other.matchedOn == matchedOn) &&
            (identical(other.visible, visible) || other.visible == visible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, type, agentId,
      agentName, phone, email, matchedOn, visible);

  /// Create a copy of ClientDuplicate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientDuplicateImplCopyWith<_$ClientDuplicateImpl> get copyWith =>
      __$$ClientDuplicateImplCopyWithImpl<_$ClientDuplicateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientDuplicateImplToJson(
      this,
    );
  }
}

abstract class _ClientDuplicate implements ClientDuplicate {
  const factory _ClientDuplicate(
      {required final int id,
      final String fullName,
      final ClientType type,
      final int? agentId,
      final String? agentName,
      final String? phone,
      final String? email,
      @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
      final DuplicateMatch matchedOn,
      final bool visible}) = _$ClientDuplicateImpl;

  factory _ClientDuplicate.fromJson(Map<String, dynamic> json) =
      _$ClientDuplicateImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  ClientType get type;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
  DuplicateMatch get matchedOn;

  /// Whether this person may open the card: an agent on their own clients
  /// learns who holds a colleague's buyer, not the file itself.
  @override
  bool get visible;

  /// Create a copy of ClientDuplicate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientDuplicateImplCopyWith<_$ClientDuplicateImpl> get copyWith =>
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
  double? get previousPrice => throw _privateConstructorUsedError;
  DateTime? get priceChangedAt => throw _privateConstructorUsedError;

  /// Where it stands, in degrees; both null until an agent drops a pin.
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// The seller's agreement; null when none is recorded. A kind this build
  /// does not know reads as none rather than failing the whole listing.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  MandateType? get mandateType => throw _privateConstructorUsedError;

  /// Its last day (a date, no time); null when it has no end date.
  DateTime? get mandateEndDate => throw _privateConstructorUsedError;

  /// The last day the listing is held for a buyer's deposit; null when no
  /// deal on it has an active deposit. While set, the listing is reserved.
  DateTime? get depositHoldUntil => throw _privateConstructorUsedError;

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
      DateTime? updatedAt,
      double? previousPrice,
      DateTime? priceChangedAt,
      double? latitude,
      double? longitude,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      MandateType? mandateType,
      DateTime? mandateEndDate,
      DateTime? depositHoldUntil});
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
    Object? previousPrice = freezed,
    Object? priceChangedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? mandateType = freezed,
    Object? mandateEndDate = freezed,
    Object? depositHoldUntil = freezed,
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
      previousPrice: freezed == previousPrice
          ? _value.previousPrice
          : previousPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      priceChangedAt: freezed == priceChangedAt
          ? _value.priceChangedAt
          : priceChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mandateType: freezed == mandateType
          ? _value.mandateType
          : mandateType // ignore: cast_nullable_to_non_nullable
              as MandateType?,
      mandateEndDate: freezed == mandateEndDate
          ? _value.mandateEndDate
          : mandateEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      depositHoldUntil: freezed == depositHoldUntil
          ? _value.depositHoldUntil
          : depositHoldUntil // ignore: cast_nullable_to_non_nullable
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
      DateTime? updatedAt,
      double? previousPrice,
      DateTime? priceChangedAt,
      double? latitude,
      double? longitude,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      MandateType? mandateType,
      DateTime? mandateEndDate,
      DateTime? depositHoldUntil});
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
    Object? previousPrice = freezed,
    Object? priceChangedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? mandateType = freezed,
    Object? mandateEndDate = freezed,
    Object? depositHoldUntil = freezed,
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
      previousPrice: freezed == previousPrice
          ? _value.previousPrice
          : previousPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      priceChangedAt: freezed == priceChangedAt
          ? _value.priceChangedAt
          : priceChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mandateType: freezed == mandateType
          ? _value.mandateType
          : mandateType // ignore: cast_nullable_to_non_nullable
              as MandateType?,
      mandateEndDate: freezed == mandateEndDate
          ? _value.mandateEndDate
          : mandateEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      depositHoldUntil: freezed == depositHoldUntil
          ? _value.depositHoldUntil
          : depositHoldUntil // ignore: cast_nullable_to_non_nullable
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
      this.updatedAt,
      this.previousPrice,
      this.priceChangedAt,
      this.latitude,
      this.longitude,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.mandateType,
      this.mandateEndDate,
      this.depositHoldUntil});

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
  final double? previousPrice;
  @override
  final DateTime? priceChangedAt;

  /// Where it stands, in degrees; both null until an agent drops a pin.
  @override
  final double? latitude;
  @override
  final double? longitude;

  /// The seller's agreement; null when none is recorded. A kind this build
  /// does not know reads as none rather than failing the whole listing.
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final MandateType? mandateType;

  /// Its last day (a date, no time); null when it has no end date.
  @override
  final DateTime? mandateEndDate;

  /// The last day the listing is held for a buyer's deposit; null when no
  /// deal on it has an active deposit. While set, the listing is reserved.
  @override
  final DateTime? depositHoldUntil;

  @override
  String toString() {
    return 'PropertyResponse(id: $id, title: $title, description: $description, address: $address, city: $city, type: $type, status: $status, price: $price, areaSqm: $areaSqm, rooms: $rooms, floor: $floor, totalFloors: $totalFloors, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt, previousPrice: $previousPrice, priceChangedAt: $priceChangedAt, latitude: $latitude, longitude: $longitude, mandateType: $mandateType, mandateEndDate: $mandateEndDate, depositHoldUntil: $depositHoldUntil)';
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
                other.updatedAt == updatedAt) &&
            (identical(other.previousPrice, previousPrice) ||
                other.previousPrice == previousPrice) &&
            (identical(other.priceChangedAt, priceChangedAt) ||
                other.priceChangedAt == priceChangedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.mandateType, mandateType) ||
                other.mandateType == mandateType) &&
            (identical(other.mandateEndDate, mandateEndDate) ||
                other.mandateEndDate == mandateEndDate) &&
            (identical(other.depositHoldUntil, depositHoldUntil) ||
                other.depositHoldUntil == depositHoldUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
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
        updatedAt,
        previousPrice,
        priceChangedAt,
        latitude,
        longitude,
        mandateType,
        mandateEndDate,
        depositHoldUntil
      ]);

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
      final DateTime? updatedAt,
      final double? previousPrice,
      final DateTime? priceChangedAt,
      final double? latitude,
      final double? longitude,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final MandateType? mandateType,
      final DateTime? mandateEndDate,
      final DateTime? depositHoldUntil}) = _$PropertyResponseImpl;

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
  @override
  double? get previousPrice;
  @override
  DateTime? get priceChangedAt;

  /// Where it stands, in degrees; both null until an agent drops a pin.
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// The seller's agreement; null when none is recorded. A kind this build
  /// does not know reads as none rather than failing the whole listing.
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  MandateType? get mandateType;

  /// Its last day (a date, no time); null when it has no end date.
  @override
  DateTime? get mandateEndDate;

  /// The last day the listing is held for a buyer's deposit; null when no
  /// deal on it has an active deposit. While set, the listing is reserved.
  @override
  DateTime? get depositHoldUntil;

  /// Create a copy of PropertyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyResponseImplCopyWith<_$PropertyResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyPriceChange _$PropertyPriceChangeFromJson(Map<String, dynamic> json) {
  return _PropertyPriceChange.fromJson(json);
}

/// @nodoc
mixin _$PropertyPriceChange {
  int get id => throw _privateConstructorUsedError;
  int? get propertyId => throw _privateConstructorUsedError;
  double get oldPrice => throw _privateConstructorUsedError;
  double get newPrice => throw _privateConstructorUsedError;
  int? get changedById => throw _privateConstructorUsedError;
  String? get changedByName => throw _privateConstructorUsedError;
  DateTime? get changedAt => throw _privateConstructorUsedError;

  /// Serializes this PropertyPriceChange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyPriceChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyPriceChangeCopyWith<PropertyPriceChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyPriceChangeCopyWith<$Res> {
  factory $PropertyPriceChangeCopyWith(
          PropertyPriceChange value, $Res Function(PropertyPriceChange) then) =
      _$PropertyPriceChangeCopyWithImpl<$Res, PropertyPriceChange>;
  @useResult
  $Res call(
      {int id,
      int? propertyId,
      double oldPrice,
      double newPrice,
      int? changedById,
      String? changedByName,
      DateTime? changedAt});
}

/// @nodoc
class _$PropertyPriceChangeCopyWithImpl<$Res, $Val extends PropertyPriceChange>
    implements $PropertyPriceChangeCopyWith<$Res> {
  _$PropertyPriceChangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyPriceChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = freezed,
    Object? oldPrice = null,
    Object? newPrice = null,
    Object? changedById = freezed,
    Object? changedByName = freezed,
    Object? changedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      oldPrice: null == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as double,
      newPrice: null == newPrice
          ? _value.newPrice
          : newPrice // ignore: cast_nullable_to_non_nullable
              as double,
      changedById: freezed == changedById
          ? _value.changedById
          : changedById // ignore: cast_nullable_to_non_nullable
              as int?,
      changedByName: freezed == changedByName
          ? _value.changedByName
          : changedByName // ignore: cast_nullable_to_non_nullable
              as String?,
      changedAt: freezed == changedAt
          ? _value.changedAt
          : changedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyPriceChangeImplCopyWith<$Res>
    implements $PropertyPriceChangeCopyWith<$Res> {
  factory _$$PropertyPriceChangeImplCopyWith(_$PropertyPriceChangeImpl value,
          $Res Function(_$PropertyPriceChangeImpl) then) =
      __$$PropertyPriceChangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int? propertyId,
      double oldPrice,
      double newPrice,
      int? changedById,
      String? changedByName,
      DateTime? changedAt});
}

/// @nodoc
class __$$PropertyPriceChangeImplCopyWithImpl<$Res>
    extends _$PropertyPriceChangeCopyWithImpl<$Res, _$PropertyPriceChangeImpl>
    implements _$$PropertyPriceChangeImplCopyWith<$Res> {
  __$$PropertyPriceChangeImplCopyWithImpl(_$PropertyPriceChangeImpl _value,
      $Res Function(_$PropertyPriceChangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyPriceChange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = freezed,
    Object? oldPrice = null,
    Object? newPrice = null,
    Object? changedById = freezed,
    Object? changedByName = freezed,
    Object? changedAt = freezed,
  }) {
    return _then(_$PropertyPriceChangeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      oldPrice: null == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as double,
      newPrice: null == newPrice
          ? _value.newPrice
          : newPrice // ignore: cast_nullable_to_non_nullable
              as double,
      changedById: freezed == changedById
          ? _value.changedById
          : changedById // ignore: cast_nullable_to_non_nullable
              as int?,
      changedByName: freezed == changedByName
          ? _value.changedByName
          : changedByName // ignore: cast_nullable_to_non_nullable
              as String?,
      changedAt: freezed == changedAt
          ? _value.changedAt
          : changedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyPriceChangeImpl implements _PropertyPriceChange {
  const _$PropertyPriceChangeImpl(
      {required this.id,
      this.propertyId,
      this.oldPrice = 0.0,
      this.newPrice = 0.0,
      this.changedById,
      this.changedByName,
      this.changedAt});

  factory _$PropertyPriceChangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyPriceChangeImplFromJson(json);

  @override
  final int id;
  @override
  final int? propertyId;
  @override
  @JsonKey()
  final double oldPrice;
  @override
  @JsonKey()
  final double newPrice;
  @override
  final int? changedById;
  @override
  final String? changedByName;
  @override
  final DateTime? changedAt;

  @override
  String toString() {
    return 'PropertyPriceChange(id: $id, propertyId: $propertyId, oldPrice: $oldPrice, newPrice: $newPrice, changedById: $changedById, changedByName: $changedByName, changedAt: $changedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyPriceChangeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.oldPrice, oldPrice) ||
                other.oldPrice == oldPrice) &&
            (identical(other.newPrice, newPrice) ||
                other.newPrice == newPrice) &&
            (identical(other.changedById, changedById) ||
                other.changedById == changedById) &&
            (identical(other.changedByName, changedByName) ||
                other.changedByName == changedByName) &&
            (identical(other.changedAt, changedAt) ||
                other.changedAt == changedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, propertyId, oldPrice,
      newPrice, changedById, changedByName, changedAt);

  /// Create a copy of PropertyPriceChange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyPriceChangeImplCopyWith<_$PropertyPriceChangeImpl> get copyWith =>
      __$$PropertyPriceChangeImplCopyWithImpl<_$PropertyPriceChangeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyPriceChangeImplToJson(
      this,
    );
  }
}

abstract class _PropertyPriceChange implements PropertyPriceChange {
  const factory _PropertyPriceChange(
      {required final int id,
      final int? propertyId,
      final double oldPrice,
      final double newPrice,
      final int? changedById,
      final String? changedByName,
      final DateTime? changedAt}) = _$PropertyPriceChangeImpl;

  factory _PropertyPriceChange.fromJson(Map<String, dynamic> json) =
      _$PropertyPriceChangeImpl.fromJson;

  @override
  int get id;
  @override
  int? get propertyId;
  @override
  double get oldPrice;
  @override
  double get newPrice;
  @override
  int? get changedById;
  @override
  String? get changedByName;
  @override
  DateTime? get changedAt;

  /// Create a copy of PropertyPriceChange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyPriceChangeImplCopyWith<_$PropertyPriceChangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceInsightStats _$PriceInsightStatsFromJson(Map<String, dynamic> json) {
  return _PriceInsightStats.fromJson(json);
}

/// @nodoc
mixin _$PriceInsightStats {
  int get count => throw _privateConstructorUsedError;
  double? get medianPerSqm => throw _privateConstructorUsedError;
  double? get p25PerSqm => throw _privateConstructorUsedError;
  double? get p75PerSqm => throw _privateConstructorUsedError;
  int? get medianDaysOnMarket => throw _privateConstructorUsedError;

  /// Serializes this PriceInsightStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInsightStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInsightStatsCopyWith<PriceInsightStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInsightStatsCopyWith<$Res> {
  factory $PriceInsightStatsCopyWith(
          PriceInsightStats value, $Res Function(PriceInsightStats) then) =
      _$PriceInsightStatsCopyWithImpl<$Res, PriceInsightStats>;
  @useResult
  $Res call(
      {int count,
      double? medianPerSqm,
      double? p25PerSqm,
      double? p75PerSqm,
      int? medianDaysOnMarket});
}

/// @nodoc
class _$PriceInsightStatsCopyWithImpl<$Res, $Val extends PriceInsightStats>
    implements $PriceInsightStatsCopyWith<$Res> {
  _$PriceInsightStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInsightStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? medianPerSqm = freezed,
    Object? p25PerSqm = freezed,
    Object? p75PerSqm = freezed,
    Object? medianDaysOnMarket = freezed,
  }) {
    return _then(_value.copyWith(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      medianPerSqm: freezed == medianPerSqm
          ? _value.medianPerSqm
          : medianPerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      p25PerSqm: freezed == p25PerSqm
          ? _value.p25PerSqm
          : p25PerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      p75PerSqm: freezed == p75PerSqm
          ? _value.p75PerSqm
          : p75PerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      medianDaysOnMarket: freezed == medianDaysOnMarket
          ? _value.medianDaysOnMarket
          : medianDaysOnMarket // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceInsightStatsImplCopyWith<$Res>
    implements $PriceInsightStatsCopyWith<$Res> {
  factory _$$PriceInsightStatsImplCopyWith(_$PriceInsightStatsImpl value,
          $Res Function(_$PriceInsightStatsImpl) then) =
      __$$PriceInsightStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int count,
      double? medianPerSqm,
      double? p25PerSqm,
      double? p75PerSqm,
      int? medianDaysOnMarket});
}

/// @nodoc
class __$$PriceInsightStatsImplCopyWithImpl<$Res>
    extends _$PriceInsightStatsCopyWithImpl<$Res, _$PriceInsightStatsImpl>
    implements _$$PriceInsightStatsImplCopyWith<$Res> {
  __$$PriceInsightStatsImplCopyWithImpl(_$PriceInsightStatsImpl _value,
      $Res Function(_$PriceInsightStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceInsightStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? medianPerSqm = freezed,
    Object? p25PerSqm = freezed,
    Object? p75PerSqm = freezed,
    Object? medianDaysOnMarket = freezed,
  }) {
    return _then(_$PriceInsightStatsImpl(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      medianPerSqm: freezed == medianPerSqm
          ? _value.medianPerSqm
          : medianPerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      p25PerSqm: freezed == p25PerSqm
          ? _value.p25PerSqm
          : p25PerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      p75PerSqm: freezed == p75PerSqm
          ? _value.p75PerSqm
          : p75PerSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      medianDaysOnMarket: freezed == medianDaysOnMarket
          ? _value.medianDaysOnMarket
          : medianDaysOnMarket // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInsightStatsImpl implements _PriceInsightStats {
  const _$PriceInsightStatsImpl(
      {this.count = 0,
      this.medianPerSqm,
      this.p25PerSqm,
      this.p75PerSqm,
      this.medianDaysOnMarket});

  factory _$PriceInsightStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInsightStatsImplFromJson(json);

  @override
  @JsonKey()
  final int count;
  @override
  final double? medianPerSqm;
  @override
  final double? p25PerSqm;
  @override
  final double? p75PerSqm;
  @override
  final int? medianDaysOnMarket;

  @override
  String toString() {
    return 'PriceInsightStats(count: $count, medianPerSqm: $medianPerSqm, p25PerSqm: $p25PerSqm, p75PerSqm: $p75PerSqm, medianDaysOnMarket: $medianDaysOnMarket)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInsightStatsImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.medianPerSqm, medianPerSqm) ||
                other.medianPerSqm == medianPerSqm) &&
            (identical(other.p25PerSqm, p25PerSqm) ||
                other.p25PerSqm == p25PerSqm) &&
            (identical(other.p75PerSqm, p75PerSqm) ||
                other.p75PerSqm == p75PerSqm) &&
            (identical(other.medianDaysOnMarket, medianDaysOnMarket) ||
                other.medianDaysOnMarket == medianDaysOnMarket));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, count, medianPerSqm, p25PerSqm,
      p75PerSqm, medianDaysOnMarket);

  /// Create a copy of PriceInsightStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInsightStatsImplCopyWith<_$PriceInsightStatsImpl> get copyWith =>
      __$$PriceInsightStatsImplCopyWithImpl<_$PriceInsightStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInsightStatsImplToJson(
      this,
    );
  }
}

abstract class _PriceInsightStats implements PriceInsightStats {
  const factory _PriceInsightStats(
      {final int count,
      final double? medianPerSqm,
      final double? p25PerSqm,
      final double? p75PerSqm,
      final int? medianDaysOnMarket}) = _$PriceInsightStatsImpl;

  factory _PriceInsightStats.fromJson(Map<String, dynamic> json) =
      _$PriceInsightStatsImpl.fromJson;

  @override
  int get count;
  @override
  double? get medianPerSqm;
  @override
  double? get p25PerSqm;
  @override
  double? get p75PerSqm;
  @override
  int? get medianDaysOnMarket;

  /// Create a copy of PriceInsightStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInsightStatsImplCopyWith<_$PriceInsightStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceInsightRange _$PriceInsightRangeFromJson(Map<String, dynamic> json) {
  return _PriceInsightRange.fromJson(json);
}

/// @nodoc
mixin _$PriceInsightRange {
  double get low => throw _privateConstructorUsedError;
  double get median => throw _privateConstructorUsedError;
  double get high => throw _privateConstructorUsedError;

  /// Serializes this PriceInsightRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInsightRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInsightRangeCopyWith<PriceInsightRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInsightRangeCopyWith<$Res> {
  factory $PriceInsightRangeCopyWith(
          PriceInsightRange value, $Res Function(PriceInsightRange) then) =
      _$PriceInsightRangeCopyWithImpl<$Res, PriceInsightRange>;
  @useResult
  $Res call({double low, double median, double high});
}

/// @nodoc
class _$PriceInsightRangeCopyWithImpl<$Res, $Val extends PriceInsightRange>
    implements $PriceInsightRangeCopyWith<$Res> {
  _$PriceInsightRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInsightRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? low = null,
    Object? median = null,
    Object? high = null,
  }) {
    return _then(_value.copyWith(
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceInsightRangeImplCopyWith<$Res>
    implements $PriceInsightRangeCopyWith<$Res> {
  factory _$$PriceInsightRangeImplCopyWith(_$PriceInsightRangeImpl value,
          $Res Function(_$PriceInsightRangeImpl) then) =
      __$$PriceInsightRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double low, double median, double high});
}

/// @nodoc
class __$$PriceInsightRangeImplCopyWithImpl<$Res>
    extends _$PriceInsightRangeCopyWithImpl<$Res, _$PriceInsightRangeImpl>
    implements _$$PriceInsightRangeImplCopyWith<$Res> {
  __$$PriceInsightRangeImplCopyWithImpl(_$PriceInsightRangeImpl _value,
      $Res Function(_$PriceInsightRangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceInsightRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? low = null,
    Object? median = null,
    Object? high = null,
  }) {
    return _then(_$PriceInsightRangeImpl(
      low: null == low
          ? _value.low
          : low // ignore: cast_nullable_to_non_nullable
              as double,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as double,
      high: null == high
          ? _value.high
          : high // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInsightRangeImpl implements _PriceInsightRange {
  const _$PriceInsightRangeImpl(
      {this.low = 0.0, this.median = 0.0, this.high = 0.0});

  factory _$PriceInsightRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInsightRangeImplFromJson(json);

  @override
  @JsonKey()
  final double low;
  @override
  @JsonKey()
  final double median;
  @override
  @JsonKey()
  final double high;

  @override
  String toString() {
    return 'PriceInsightRange(low: $low, median: $median, high: $high)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInsightRangeImpl &&
            (identical(other.low, low) || other.low == low) &&
            (identical(other.median, median) || other.median == median) &&
            (identical(other.high, high) || other.high == high));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, low, median, high);

  /// Create a copy of PriceInsightRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInsightRangeImplCopyWith<_$PriceInsightRangeImpl> get copyWith =>
      __$$PriceInsightRangeImplCopyWithImpl<_$PriceInsightRangeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInsightRangeImplToJson(
      this,
    );
  }
}

abstract class _PriceInsightRange implements PriceInsightRange {
  const factory _PriceInsightRange(
      {final double low,
      final double median,
      final double high}) = _$PriceInsightRangeImpl;

  factory _PriceInsightRange.fromJson(Map<String, dynamic> json) =
      _$PriceInsightRangeImpl.fromJson;

  @override
  double get low;
  @override
  double get median;
  @override
  double get high;

  /// Create a copy of PriceInsightRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInsightRangeImplCopyWith<_$PriceInsightRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceInsightPosition _$PriceInsightPositionFromJson(Map<String, dynamic> json) {
  return _PriceInsightPosition.fromJson(json);
}

/// @nodoc
mixin _$PriceInsightPosition {
  double get pricePerSqm => throw _privateConstructorUsedError;
  int? get percentile => throw _privateConstructorUsedError;
  double? get vsMedianPercent => throw _privateConstructorUsedError;

  /// Serializes this PriceInsightPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInsightPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInsightPositionCopyWith<PriceInsightPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInsightPositionCopyWith<$Res> {
  factory $PriceInsightPositionCopyWith(PriceInsightPosition value,
          $Res Function(PriceInsightPosition) then) =
      _$PriceInsightPositionCopyWithImpl<$Res, PriceInsightPosition>;
  @useResult
  $Res call({double pricePerSqm, int? percentile, double? vsMedianPercent});
}

/// @nodoc
class _$PriceInsightPositionCopyWithImpl<$Res,
        $Val extends PriceInsightPosition>
    implements $PriceInsightPositionCopyWith<$Res> {
  _$PriceInsightPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInsightPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pricePerSqm = null,
    Object? percentile = freezed,
    Object? vsMedianPercent = freezed,
  }) {
    return _then(_value.copyWith(
      pricePerSqm: null == pricePerSqm
          ? _value.pricePerSqm
          : pricePerSqm // ignore: cast_nullable_to_non_nullable
              as double,
      percentile: freezed == percentile
          ? _value.percentile
          : percentile // ignore: cast_nullable_to_non_nullable
              as int?,
      vsMedianPercent: freezed == vsMedianPercent
          ? _value.vsMedianPercent
          : vsMedianPercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceInsightPositionImplCopyWith<$Res>
    implements $PriceInsightPositionCopyWith<$Res> {
  factory _$$PriceInsightPositionImplCopyWith(_$PriceInsightPositionImpl value,
          $Res Function(_$PriceInsightPositionImpl) then) =
      __$$PriceInsightPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double pricePerSqm, int? percentile, double? vsMedianPercent});
}

/// @nodoc
class __$$PriceInsightPositionImplCopyWithImpl<$Res>
    extends _$PriceInsightPositionCopyWithImpl<$Res, _$PriceInsightPositionImpl>
    implements _$$PriceInsightPositionImplCopyWith<$Res> {
  __$$PriceInsightPositionImplCopyWithImpl(_$PriceInsightPositionImpl _value,
      $Res Function(_$PriceInsightPositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceInsightPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pricePerSqm = null,
    Object? percentile = freezed,
    Object? vsMedianPercent = freezed,
  }) {
    return _then(_$PriceInsightPositionImpl(
      pricePerSqm: null == pricePerSqm
          ? _value.pricePerSqm
          : pricePerSqm // ignore: cast_nullable_to_non_nullable
              as double,
      percentile: freezed == percentile
          ? _value.percentile
          : percentile // ignore: cast_nullable_to_non_nullable
              as int?,
      vsMedianPercent: freezed == vsMedianPercent
          ? _value.vsMedianPercent
          : vsMedianPercent // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInsightPositionImpl implements _PriceInsightPosition {
  const _$PriceInsightPositionImpl(
      {this.pricePerSqm = 0.0, this.percentile, this.vsMedianPercent});

  factory _$PriceInsightPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInsightPositionImplFromJson(json);

  @override
  @JsonKey()
  final double pricePerSqm;
  @override
  final int? percentile;
  @override
  final double? vsMedianPercent;

  @override
  String toString() {
    return 'PriceInsightPosition(pricePerSqm: $pricePerSqm, percentile: $percentile, vsMedianPercent: $vsMedianPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInsightPositionImpl &&
            (identical(other.pricePerSqm, pricePerSqm) ||
                other.pricePerSqm == pricePerSqm) &&
            (identical(other.percentile, percentile) ||
                other.percentile == percentile) &&
            (identical(other.vsMedianPercent, vsMedianPercent) ||
                other.vsMedianPercent == vsMedianPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, pricePerSqm, percentile, vsMedianPercent);

  /// Create a copy of PriceInsightPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInsightPositionImplCopyWith<_$PriceInsightPositionImpl>
      get copyWith =>
          __$$PriceInsightPositionImplCopyWithImpl<_$PriceInsightPositionImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInsightPositionImplToJson(
      this,
    );
  }
}

abstract class _PriceInsightPosition implements PriceInsightPosition {
  const factory _PriceInsightPosition(
      {final double pricePerSqm,
      final int? percentile,
      final double? vsMedianPercent}) = _$PriceInsightPositionImpl;

  factory _PriceInsightPosition.fromJson(Map<String, dynamic> json) =
      _$PriceInsightPositionImpl.fromJson;

  @override
  double get pricePerSqm;
  @override
  int? get percentile;
  @override
  double? get vsMedianPercent;

  /// Create a copy of PriceInsightPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInsightPositionImplCopyWith<_$PriceInsightPositionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PriceInsightCriteria _$PriceInsightCriteriaFromJson(Map<String, dynamic> json) {
  return _PriceInsightCriteria.fromJson(json);
}

/// @nodoc
mixin _$PriceInsightCriteria {
  String? get city => throw _privateConstructorUsedError;
  PropertyType? get type => throw _privateConstructorUsedError;
  int? get rooms => throw _privateConstructorUsedError;
  double? get areaSqm => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
  PriceRoomsRule get roomsRule => throw _privateConstructorUsedError;
  int? get minRooms => throw _privateConstructorUsedError;
  int? get maxRooms => throw _privateConstructorUsedError;

  /// Serializes this PriceInsightCriteria to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInsightCriteria
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInsightCriteriaCopyWith<PriceInsightCriteria> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInsightCriteriaCopyWith<$Res> {
  factory $PriceInsightCriteriaCopyWith(PriceInsightCriteria value,
          $Res Function(PriceInsightCriteria) then) =
      _$PriceInsightCriteriaCopyWithImpl<$Res, PriceInsightCriteria>;
  @useResult
  $Res call(
      {String? city,
      PropertyType? type,
      int? rooms,
      double? areaSqm,
      @JsonKey(unknownEnumValue: PriceRoomsRule.ANY) PriceRoomsRule roomsRule,
      int? minRooms,
      int? maxRooms});
}

/// @nodoc
class _$PriceInsightCriteriaCopyWithImpl<$Res,
        $Val extends PriceInsightCriteria>
    implements $PriceInsightCriteriaCopyWith<$Res> {
  _$PriceInsightCriteriaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInsightCriteria
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? type = freezed,
    Object? rooms = freezed,
    Object? areaSqm = freezed,
    Object? roomsRule = null,
    Object? minRooms = freezed,
    Object? maxRooms = freezed,
  }) {
    return _then(_value.copyWith(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PropertyType?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      roomsRule: null == roomsRule
          ? _value.roomsRule
          : roomsRule // ignore: cast_nullable_to_non_nullable
              as PriceRoomsRule,
      minRooms: freezed == minRooms
          ? _value.minRooms
          : minRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      maxRooms: freezed == maxRooms
          ? _value.maxRooms
          : maxRooms // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceInsightCriteriaImplCopyWith<$Res>
    implements $PriceInsightCriteriaCopyWith<$Res> {
  factory _$$PriceInsightCriteriaImplCopyWith(_$PriceInsightCriteriaImpl value,
          $Res Function(_$PriceInsightCriteriaImpl) then) =
      __$$PriceInsightCriteriaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? city,
      PropertyType? type,
      int? rooms,
      double? areaSqm,
      @JsonKey(unknownEnumValue: PriceRoomsRule.ANY) PriceRoomsRule roomsRule,
      int? minRooms,
      int? maxRooms});
}

/// @nodoc
class __$$PriceInsightCriteriaImplCopyWithImpl<$Res>
    extends _$PriceInsightCriteriaCopyWithImpl<$Res, _$PriceInsightCriteriaImpl>
    implements _$$PriceInsightCriteriaImplCopyWith<$Res> {
  __$$PriceInsightCriteriaImplCopyWithImpl(_$PriceInsightCriteriaImpl _value,
      $Res Function(_$PriceInsightCriteriaImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceInsightCriteria
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? type = freezed,
    Object? rooms = freezed,
    Object? areaSqm = freezed,
    Object? roomsRule = null,
    Object? minRooms = freezed,
    Object? maxRooms = freezed,
  }) {
    return _then(_$PriceInsightCriteriaImpl(
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PropertyType?,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      roomsRule: null == roomsRule
          ? _value.roomsRule
          : roomsRule // ignore: cast_nullable_to_non_nullable
              as PriceRoomsRule,
      minRooms: freezed == minRooms
          ? _value.minRooms
          : minRooms // ignore: cast_nullable_to_non_nullable
              as int?,
      maxRooms: freezed == maxRooms
          ? _value.maxRooms
          : maxRooms // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInsightCriteriaImpl implements _PriceInsightCriteria {
  const _$PriceInsightCriteriaImpl(
      {this.city,
      this.type,
      this.rooms,
      this.areaSqm,
      @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
      this.roomsRule = PriceRoomsRule.ANY,
      this.minRooms,
      this.maxRooms});

  factory _$PriceInsightCriteriaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInsightCriteriaImplFromJson(json);

  @override
  final String? city;
  @override
  final PropertyType? type;
  @override
  final int? rooms;
  @override
  final double? areaSqm;
  @override
  @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
  final PriceRoomsRule roomsRule;
  @override
  final int? minRooms;
  @override
  final int? maxRooms;

  @override
  String toString() {
    return 'PriceInsightCriteria(city: $city, type: $type, rooms: $rooms, areaSqm: $areaSqm, roomsRule: $roomsRule, minRooms: $minRooms, maxRooms: $maxRooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInsightCriteriaImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.rooms, rooms) || other.rooms == rooms) &&
            (identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm) &&
            (identical(other.roomsRule, roomsRule) ||
                other.roomsRule == roomsRule) &&
            (identical(other.minRooms, minRooms) ||
                other.minRooms == minRooms) &&
            (identical(other.maxRooms, maxRooms) ||
                other.maxRooms == maxRooms));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, city, type, rooms, areaSqm, roomsRule, minRooms, maxRooms);

  /// Create a copy of PriceInsightCriteria
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInsightCriteriaImplCopyWith<_$PriceInsightCriteriaImpl>
      get copyWith =>
          __$$PriceInsightCriteriaImplCopyWithImpl<_$PriceInsightCriteriaImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInsightCriteriaImplToJson(
      this,
    );
  }
}

abstract class _PriceInsightCriteria implements PriceInsightCriteria {
  const factory _PriceInsightCriteria(
      {final String? city,
      final PropertyType? type,
      final int? rooms,
      final double? areaSqm,
      @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
      final PriceRoomsRule roomsRule,
      final int? minRooms,
      final int? maxRooms}) = _$PriceInsightCriteriaImpl;

  factory _PriceInsightCriteria.fromJson(Map<String, dynamic> json) =
      _$PriceInsightCriteriaImpl.fromJson;

  @override
  String? get city;
  @override
  PropertyType? get type;
  @override
  int? get rooms;
  @override
  double? get areaSqm;
  @override
  @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
  PriceRoomsRule get roomsRule;
  @override
  int? get minRooms;
  @override
  int? get maxRooms;

  /// Create a copy of PriceInsightCriteria
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInsightCriteriaImplCopyWith<_$PriceInsightCriteriaImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PriceComparable _$PriceComparableFromJson(Map<String, dynamic> json) {
  return _PriceComparable.fromJson(json);
}

/// @nodoc
mixin _$PriceComparable {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get areaSqm => throw _privateConstructorUsedError;
  double get pricePerSqm => throw _privateConstructorUsedError;
  int? get rooms => throw _privateConstructorUsedError;
  PropertyStatus get status => throw _privateConstructorUsedError;
  bool get sold => throw _privateConstructorUsedError;

  /// Serializes this PriceComparable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceComparable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceComparableCopyWith<PriceComparable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceComparableCopyWith<$Res> {
  factory $PriceComparableCopyWith(
          PriceComparable value, $Res Function(PriceComparable) then) =
      _$PriceComparableCopyWithImpl<$Res, PriceComparable>;
  @useResult
  $Res call(
      {int id,
      String title,
      double price,
      double? areaSqm,
      double pricePerSqm,
      int? rooms,
      PropertyStatus status,
      bool sold});
}

/// @nodoc
class _$PriceComparableCopyWithImpl<$Res, $Val extends PriceComparable>
    implements $PriceComparableCopyWith<$Res> {
  _$PriceComparableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceComparable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? areaSqm = freezed,
    Object? pricePerSqm = null,
    Object? rooms = freezed,
    Object? status = null,
    Object? sold = null,
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
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      pricePerSqm: null == pricePerSqm
          ? _value.pricePerSqm
          : pricePerSqm // ignore: cast_nullable_to_non_nullable
              as double,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceComparableImplCopyWith<$Res>
    implements $PriceComparableCopyWith<$Res> {
  factory _$$PriceComparableImplCopyWith(_$PriceComparableImpl value,
          $Res Function(_$PriceComparableImpl) then) =
      __$$PriceComparableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      double price,
      double? areaSqm,
      double pricePerSqm,
      int? rooms,
      PropertyStatus status,
      bool sold});
}

/// @nodoc
class __$$PriceComparableImplCopyWithImpl<$Res>
    extends _$PriceComparableCopyWithImpl<$Res, _$PriceComparableImpl>
    implements _$$PriceComparableImplCopyWith<$Res> {
  __$$PriceComparableImplCopyWithImpl(
      _$PriceComparableImpl _value, $Res Function(_$PriceComparableImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceComparable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? areaSqm = freezed,
    Object? pricePerSqm = null,
    Object? rooms = freezed,
    Object? status = null,
    Object? sold = null,
  }) {
    return _then(_$PriceComparableImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: freezed == areaSqm
          ? _value.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double?,
      pricePerSqm: null == pricePerSqm
          ? _value.pricePerSqm
          : pricePerSqm // ignore: cast_nullable_to_non_nullable
              as double,
      rooms: freezed == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceComparableImpl implements _PriceComparable {
  const _$PriceComparableImpl(
      {required this.id,
      this.title = '',
      this.price = 0.0,
      this.areaSqm,
      this.pricePerSqm = 0.0,
      this.rooms,
      this.status = PropertyStatus.AVAILABLE,
      this.sold = false});

  factory _$PriceComparableImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceComparableImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final double price;
  @override
  final double? areaSqm;
  @override
  @JsonKey()
  final double pricePerSqm;
  @override
  final int? rooms;
  @override
  @JsonKey()
  final PropertyStatus status;
  @override
  @JsonKey()
  final bool sold;

  @override
  String toString() {
    return 'PriceComparable(id: $id, title: $title, price: $price, areaSqm: $areaSqm, pricePerSqm: $pricePerSqm, rooms: $rooms, status: $status, sold: $sold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceComparableImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm) &&
            (identical(other.pricePerSqm, pricePerSqm) ||
                other.pricePerSqm == pricePerSqm) &&
            (identical(other.rooms, rooms) || other.rooms == rooms) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sold, sold) || other.sold == sold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, price, areaSqm, pricePerSqm, rooms, status, sold);

  /// Create a copy of PriceComparable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceComparableImplCopyWith<_$PriceComparableImpl> get copyWith =>
      __$$PriceComparableImplCopyWithImpl<_$PriceComparableImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceComparableImplToJson(
      this,
    );
  }
}

abstract class _PriceComparable implements PriceComparable {
  const factory _PriceComparable(
      {required final int id,
      final String title,
      final double price,
      final double? areaSqm,
      final double pricePerSqm,
      final int? rooms,
      final PropertyStatus status,
      final bool sold}) = _$PriceComparableImpl;

  factory _PriceComparable.fromJson(Map<String, dynamic> json) =
      _$PriceComparableImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  double get price;
  @override
  double? get areaSqm;
  @override
  double get pricePerSqm;
  @override
  int? get rooms;
  @override
  PropertyStatus get status;
  @override
  bool get sold;

  /// Create a copy of PriceComparable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceComparableImplCopyWith<_$PriceComparableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceInsight _$PriceInsightFromJson(Map<String, dynamic> json) {
  return _PriceInsight.fromJson(json);
}

/// @nodoc
mixin _$PriceInsight {
  int get count => throw _privateConstructorUsedError;
  bool get lowConfidence => throw _privateConstructorUsedError;
  PriceInsightCriteria get criteria => throw _privateConstructorUsedError;
  PriceInsightStats get active => throw _privateConstructorUsedError;
  PriceInsightStats get sold => throw _privateConstructorUsedError;
  PriceInsightRange? get suggested => throw _privateConstructorUsedError;
  PriceInsightPosition? get position => throw _privateConstructorUsedError;
  List<PriceComparable> get comparables => throw _privateConstructorUsedError;

  /// Serializes this PriceInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceInsightCopyWith<PriceInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceInsightCopyWith<$Res> {
  factory $PriceInsightCopyWith(
          PriceInsight value, $Res Function(PriceInsight) then) =
      _$PriceInsightCopyWithImpl<$Res, PriceInsight>;
  @useResult
  $Res call(
      {int count,
      bool lowConfidence,
      PriceInsightCriteria criteria,
      PriceInsightStats active,
      PriceInsightStats sold,
      PriceInsightRange? suggested,
      PriceInsightPosition? position,
      List<PriceComparable> comparables});

  $PriceInsightCriteriaCopyWith<$Res> get criteria;
  $PriceInsightStatsCopyWith<$Res> get active;
  $PriceInsightStatsCopyWith<$Res> get sold;
  $PriceInsightRangeCopyWith<$Res>? get suggested;
  $PriceInsightPositionCopyWith<$Res>? get position;
}

/// @nodoc
class _$PriceInsightCopyWithImpl<$Res, $Val extends PriceInsight>
    implements $PriceInsightCopyWith<$Res> {
  _$PriceInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? lowConfidence = null,
    Object? criteria = null,
    Object? active = null,
    Object? sold = null,
    Object? suggested = freezed,
    Object? position = freezed,
    Object? comparables = null,
  }) {
    return _then(_value.copyWith(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      criteria: null == criteria
          ? _value.criteria
          : criteria // ignore: cast_nullable_to_non_nullable
              as PriceInsightCriteria,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as PriceInsightStats,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as PriceInsightStats,
      suggested: freezed == suggested
          ? _value.suggested
          : suggested // ignore: cast_nullable_to_non_nullable
              as PriceInsightRange?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as PriceInsightPosition?,
      comparables: null == comparables
          ? _value.comparables
          : comparables // ignore: cast_nullable_to_non_nullable
              as List<PriceComparable>,
    ) as $Val);
  }

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInsightCriteriaCopyWith<$Res> get criteria {
    return $PriceInsightCriteriaCopyWith<$Res>(_value.criteria, (value) {
      return _then(_value.copyWith(criteria: value) as $Val);
    });
  }

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInsightStatsCopyWith<$Res> get active {
    return $PriceInsightStatsCopyWith<$Res>(_value.active, (value) {
      return _then(_value.copyWith(active: value) as $Val);
    });
  }

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInsightStatsCopyWith<$Res> get sold {
    return $PriceInsightStatsCopyWith<$Res>(_value.sold, (value) {
      return _then(_value.copyWith(sold: value) as $Val);
    });
  }

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInsightRangeCopyWith<$Res>? get suggested {
    if (_value.suggested == null) {
      return null;
    }

    return $PriceInsightRangeCopyWith<$Res>(_value.suggested!, (value) {
      return _then(_value.copyWith(suggested: value) as $Val);
    });
  }

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceInsightPositionCopyWith<$Res>? get position {
    if (_value.position == null) {
      return null;
    }

    return $PriceInsightPositionCopyWith<$Res>(_value.position!, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PriceInsightImplCopyWith<$Res>
    implements $PriceInsightCopyWith<$Res> {
  factory _$$PriceInsightImplCopyWith(
          _$PriceInsightImpl value, $Res Function(_$PriceInsightImpl) then) =
      __$$PriceInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int count,
      bool lowConfidence,
      PriceInsightCriteria criteria,
      PriceInsightStats active,
      PriceInsightStats sold,
      PriceInsightRange? suggested,
      PriceInsightPosition? position,
      List<PriceComparable> comparables});

  @override
  $PriceInsightCriteriaCopyWith<$Res> get criteria;
  @override
  $PriceInsightStatsCopyWith<$Res> get active;
  @override
  $PriceInsightStatsCopyWith<$Res> get sold;
  @override
  $PriceInsightRangeCopyWith<$Res>? get suggested;
  @override
  $PriceInsightPositionCopyWith<$Res>? get position;
}

/// @nodoc
class __$$PriceInsightImplCopyWithImpl<$Res>
    extends _$PriceInsightCopyWithImpl<$Res, _$PriceInsightImpl>
    implements _$$PriceInsightImplCopyWith<$Res> {
  __$$PriceInsightImplCopyWithImpl(
      _$PriceInsightImpl _value, $Res Function(_$PriceInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? lowConfidence = null,
    Object? criteria = null,
    Object? active = null,
    Object? sold = null,
    Object? suggested = freezed,
    Object? position = freezed,
    Object? comparables = null,
  }) {
    return _then(_$PriceInsightImpl(
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      criteria: null == criteria
          ? _value.criteria
          : criteria // ignore: cast_nullable_to_non_nullable
              as PriceInsightCriteria,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as PriceInsightStats,
      sold: null == sold
          ? _value.sold
          : sold // ignore: cast_nullable_to_non_nullable
              as PriceInsightStats,
      suggested: freezed == suggested
          ? _value.suggested
          : suggested // ignore: cast_nullable_to_non_nullable
              as PriceInsightRange?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as PriceInsightPosition?,
      comparables: null == comparables
          ? _value._comparables
          : comparables // ignore: cast_nullable_to_non_nullable
              as List<PriceComparable>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceInsightImpl implements _PriceInsight {
  const _$PriceInsightImpl(
      {this.count = 0,
      this.lowConfidence = true,
      this.criteria = const PriceInsightCriteria(),
      this.active = const PriceInsightStats(),
      this.sold = const PriceInsightStats(),
      this.suggested,
      this.position,
      final List<PriceComparable> comparables = const <PriceComparable>[]})
      : _comparables = comparables;

  factory _$PriceInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceInsightImplFromJson(json);

  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final bool lowConfidence;
  @override
  @JsonKey()
  final PriceInsightCriteria criteria;
  @override
  @JsonKey()
  final PriceInsightStats active;
  @override
  @JsonKey()
  final PriceInsightStats sold;
  @override
  final PriceInsightRange? suggested;
  @override
  final PriceInsightPosition? position;
  final List<PriceComparable> _comparables;
  @override
  @JsonKey()
  List<PriceComparable> get comparables {
    if (_comparables is EqualUnmodifiableListView) return _comparables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comparables);
  }

  @override
  String toString() {
    return 'PriceInsight(count: $count, lowConfidence: $lowConfidence, criteria: $criteria, active: $active, sold: $sold, suggested: $suggested, position: $position, comparables: $comparables)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceInsightImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.lowConfidence, lowConfidence) ||
                other.lowConfidence == lowConfidence) &&
            (identical(other.criteria, criteria) ||
                other.criteria == criteria) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.sold, sold) || other.sold == sold) &&
            (identical(other.suggested, suggested) ||
                other.suggested == suggested) &&
            (identical(other.position, position) ||
                other.position == position) &&
            const DeepCollectionEquality()
                .equals(other._comparables, _comparables));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      count,
      lowConfidence,
      criteria,
      active,
      sold,
      suggested,
      position,
      const DeepCollectionEquality().hash(_comparables));

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceInsightImplCopyWith<_$PriceInsightImpl> get copyWith =>
      __$$PriceInsightImplCopyWithImpl<_$PriceInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceInsightImplToJson(
      this,
    );
  }
}

abstract class _PriceInsight implements PriceInsight {
  const factory _PriceInsight(
      {final int count,
      final bool lowConfidence,
      final PriceInsightCriteria criteria,
      final PriceInsightStats active,
      final PriceInsightStats sold,
      final PriceInsightRange? suggested,
      final PriceInsightPosition? position,
      final List<PriceComparable> comparables}) = _$PriceInsightImpl;

  factory _PriceInsight.fromJson(Map<String, dynamic> json) =
      _$PriceInsightImpl.fromJson;

  @override
  int get count;
  @override
  bool get lowConfidence;
  @override
  PriceInsightCriteria get criteria;
  @override
  PriceInsightStats get active;
  @override
  PriceInsightStats get sold;
  @override
  PriceInsightRange? get suggested;
  @override
  PriceInsightPosition? get position;
  @override
  List<PriceComparable> get comparables;

  /// Create a copy of PriceInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceInsightImplCopyWith<_$PriceInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyShareLink _$PropertyShareLinkFromJson(Map<String, dynamic> json) {
  return _PropertyShareLink.fromJson(json);
}

/// @nodoc
mixin _$PropertyShareLink {
  String? get url => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  DateTime? get lastViewedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// How many buyers left their details on the page through this link.
  int get leadCount => throw _privateConstructorUsedError;

  /// Serializes this PropertyShareLink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyShareLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyShareLinkCopyWith<PropertyShareLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyShareLinkCopyWith<$Res> {
  factory $PropertyShareLinkCopyWith(
          PropertyShareLink value, $Res Function(PropertyShareLink) then) =
      _$PropertyShareLinkCopyWithImpl<$Res, PropertyShareLink>;
  @useResult
  $Res call(
      {String? url,
      int viewCount,
      DateTime? lastViewedAt,
      DateTime? createdAt,
      int leadCount});
}

/// @nodoc
class _$PropertyShareLinkCopyWithImpl<$Res, $Val extends PropertyShareLink>
    implements $PropertyShareLinkCopyWith<$Res> {
  _$PropertyShareLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyShareLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? viewCount = null,
    Object? lastViewedAt = freezed,
    Object? createdAt = freezed,
    Object? leadCount = null,
  }) {
    return _then(_value.copyWith(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastViewedAt: freezed == lastViewedAt
          ? _value.lastViewedAt
          : lastViewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leadCount: null == leadCount
          ? _value.leadCount
          : leadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyShareLinkImplCopyWith<$Res>
    implements $PropertyShareLinkCopyWith<$Res> {
  factory _$$PropertyShareLinkImplCopyWith(_$PropertyShareLinkImpl value,
          $Res Function(_$PropertyShareLinkImpl) then) =
      __$$PropertyShareLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? url,
      int viewCount,
      DateTime? lastViewedAt,
      DateTime? createdAt,
      int leadCount});
}

/// @nodoc
class __$$PropertyShareLinkImplCopyWithImpl<$Res>
    extends _$PropertyShareLinkCopyWithImpl<$Res, _$PropertyShareLinkImpl>
    implements _$$PropertyShareLinkImplCopyWith<$Res> {
  __$$PropertyShareLinkImplCopyWithImpl(_$PropertyShareLinkImpl _value,
      $Res Function(_$PropertyShareLinkImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyShareLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? viewCount = null,
    Object? lastViewedAt = freezed,
    Object? createdAt = freezed,
    Object? leadCount = null,
  }) {
    return _then(_$PropertyShareLinkImpl(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastViewedAt: freezed == lastViewedAt
          ? _value.lastViewedAt
          : lastViewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leadCount: null == leadCount
          ? _value.leadCount
          : leadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyShareLinkImpl implements _PropertyShareLink {
  const _$PropertyShareLinkImpl(
      {this.url,
      this.viewCount = 0,
      this.lastViewedAt,
      this.createdAt,
      this.leadCount = 0});

  factory _$PropertyShareLinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyShareLinkImplFromJson(json);

  @override
  final String? url;
  @override
  @JsonKey()
  final int viewCount;
  @override
  final DateTime? lastViewedAt;
  @override
  final DateTime? createdAt;

  /// How many buyers left their details on the page through this link.
  @override
  @JsonKey()
  final int leadCount;

  @override
  String toString() {
    return 'PropertyShareLink(url: $url, viewCount: $viewCount, lastViewedAt: $lastViewedAt, createdAt: $createdAt, leadCount: $leadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyShareLinkImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.lastViewedAt, lastViewedAt) ||
                other.lastViewedAt == lastViewedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.leadCount, leadCount) ||
                other.leadCount == leadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, url, viewCount, lastViewedAt, createdAt, leadCount);

  /// Create a copy of PropertyShareLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyShareLinkImplCopyWith<_$PropertyShareLinkImpl> get copyWith =>
      __$$PropertyShareLinkImplCopyWithImpl<_$PropertyShareLinkImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyShareLinkImplToJson(
      this,
    );
  }
}

abstract class _PropertyShareLink implements PropertyShareLink {
  const factory _PropertyShareLink(
      {final String? url,
      final int viewCount,
      final DateTime? lastViewedAt,
      final DateTime? createdAt,
      final int leadCount}) = _$PropertyShareLinkImpl;

  factory _PropertyShareLink.fromJson(Map<String, dynamic> json) =
      _$PropertyShareLinkImpl.fromJson;

  @override
  String? get url;
  @override
  int get viewCount;
  @override
  DateTime? get lastViewedAt;
  @override
  DateTime? get createdAt;

  /// How many buyers left their details on the page through this link.
  @override
  int get leadCount;

  /// Create a copy of PropertyShareLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyShareLinkImplCopyWith<_$PropertyShareLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SellerReportViewings _$SellerReportViewingsFromJson(Map<String, dynamic> json) {
  return _SellerReportViewings.fromJson(json);
}

/// @nodoc
mixin _$SellerReportViewings {
  int get total => throw _privateConstructorUsedError;
  int get held => throw _privateConstructorUsedError;
  int get upcoming => throw _privateConstructorUsedError;
  Map<String, int> get outcomes => throw _privateConstructorUsedError;
  int get awaitingOutcome => throw _privateConstructorUsedError;
  DateTime? get lastHeldAt => throw _privateConstructorUsedError;
  DateTime? get nextAt => throw _privateConstructorUsedError;

  /// Serializes this SellerReportViewings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SellerReportViewings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SellerReportViewingsCopyWith<SellerReportViewings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerReportViewingsCopyWith<$Res> {
  factory $SellerReportViewingsCopyWith(SellerReportViewings value,
          $Res Function(SellerReportViewings) then) =
      _$SellerReportViewingsCopyWithImpl<$Res, SellerReportViewings>;
  @useResult
  $Res call(
      {int total,
      int held,
      int upcoming,
      Map<String, int> outcomes,
      int awaitingOutcome,
      DateTime? lastHeldAt,
      DateTime? nextAt});
}

/// @nodoc
class _$SellerReportViewingsCopyWithImpl<$Res,
        $Val extends SellerReportViewings>
    implements $SellerReportViewingsCopyWith<$Res> {
  _$SellerReportViewingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SellerReportViewings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? held = null,
    Object? upcoming = null,
    Object? outcomes = null,
    Object? awaitingOutcome = null,
    Object? lastHeldAt = freezed,
    Object? nextAt = freezed,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      held: null == held
          ? _value.held
          : held // ignore: cast_nullable_to_non_nullable
              as int,
      upcoming: null == upcoming
          ? _value.upcoming
          : upcoming // ignore: cast_nullable_to_non_nullable
              as int,
      outcomes: null == outcomes
          ? _value.outcomes
          : outcomes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      awaitingOutcome: null == awaitingOutcome
          ? _value.awaitingOutcome
          : awaitingOutcome // ignore: cast_nullable_to_non_nullable
              as int,
      lastHeldAt: freezed == lastHeldAt
          ? _value.lastHeldAt
          : lastHeldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextAt: freezed == nextAt
          ? _value.nextAt
          : nextAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SellerReportViewingsImplCopyWith<$Res>
    implements $SellerReportViewingsCopyWith<$Res> {
  factory _$$SellerReportViewingsImplCopyWith(_$SellerReportViewingsImpl value,
          $Res Function(_$SellerReportViewingsImpl) then) =
      __$$SellerReportViewingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      int held,
      int upcoming,
      Map<String, int> outcomes,
      int awaitingOutcome,
      DateTime? lastHeldAt,
      DateTime? nextAt});
}

/// @nodoc
class __$$SellerReportViewingsImplCopyWithImpl<$Res>
    extends _$SellerReportViewingsCopyWithImpl<$Res, _$SellerReportViewingsImpl>
    implements _$$SellerReportViewingsImplCopyWith<$Res> {
  __$$SellerReportViewingsImplCopyWithImpl(_$SellerReportViewingsImpl _value,
      $Res Function(_$SellerReportViewingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SellerReportViewings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? held = null,
    Object? upcoming = null,
    Object? outcomes = null,
    Object? awaitingOutcome = null,
    Object? lastHeldAt = freezed,
    Object? nextAt = freezed,
  }) {
    return _then(_$SellerReportViewingsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      held: null == held
          ? _value.held
          : held // ignore: cast_nullable_to_non_nullable
              as int,
      upcoming: null == upcoming
          ? _value.upcoming
          : upcoming // ignore: cast_nullable_to_non_nullable
              as int,
      outcomes: null == outcomes
          ? _value._outcomes
          : outcomes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      awaitingOutcome: null == awaitingOutcome
          ? _value.awaitingOutcome
          : awaitingOutcome // ignore: cast_nullable_to_non_nullable
              as int,
      lastHeldAt: freezed == lastHeldAt
          ? _value.lastHeldAt
          : lastHeldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextAt: freezed == nextAt
          ? _value.nextAt
          : nextAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SellerReportViewingsImpl extends _SellerReportViewings {
  const _$SellerReportViewingsImpl(
      {this.total = 0,
      this.held = 0,
      this.upcoming = 0,
      final Map<String, int> outcomes = const <String, int>{},
      this.awaitingOutcome = 0,
      this.lastHeldAt,
      this.nextAt})
      : _outcomes = outcomes,
        super._();

  factory _$SellerReportViewingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SellerReportViewingsImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int held;
  @override
  @JsonKey()
  final int upcoming;
  final Map<String, int> _outcomes;
  @override
  @JsonKey()
  Map<String, int> get outcomes {
    if (_outcomes is EqualUnmodifiableMapView) return _outcomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_outcomes);
  }

  @override
  @JsonKey()
  final int awaitingOutcome;
  @override
  final DateTime? lastHeldAt;
  @override
  final DateTime? nextAt;

  @override
  String toString() {
    return 'SellerReportViewings(total: $total, held: $held, upcoming: $upcoming, outcomes: $outcomes, awaitingOutcome: $awaitingOutcome, lastHeldAt: $lastHeldAt, nextAt: $nextAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerReportViewingsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.held, held) || other.held == held) &&
            (identical(other.upcoming, upcoming) ||
                other.upcoming == upcoming) &&
            const DeepCollectionEquality().equals(other._outcomes, _outcomes) &&
            (identical(other.awaitingOutcome, awaitingOutcome) ||
                other.awaitingOutcome == awaitingOutcome) &&
            (identical(other.lastHeldAt, lastHeldAt) ||
                other.lastHeldAt == lastHeldAt) &&
            (identical(other.nextAt, nextAt) || other.nextAt == nextAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total,
      held,
      upcoming,
      const DeepCollectionEquality().hash(_outcomes),
      awaitingOutcome,
      lastHeldAt,
      nextAt);

  /// Create a copy of SellerReportViewings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerReportViewingsImplCopyWith<_$SellerReportViewingsImpl>
      get copyWith =>
          __$$SellerReportViewingsImplCopyWithImpl<_$SellerReportViewingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SellerReportViewingsImplToJson(
      this,
    );
  }
}

abstract class _SellerReportViewings extends SellerReportViewings {
  const factory _SellerReportViewings(
      {final int total,
      final int held,
      final int upcoming,
      final Map<String, int> outcomes,
      final int awaitingOutcome,
      final DateTime? lastHeldAt,
      final DateTime? nextAt}) = _$SellerReportViewingsImpl;
  const _SellerReportViewings._() : super._();

  factory _SellerReportViewings.fromJson(Map<String, dynamic> json) =
      _$SellerReportViewingsImpl.fromJson;

  @override
  int get total;
  @override
  int get held;
  @override
  int get upcoming;
  @override
  Map<String, int> get outcomes;
  @override
  int get awaitingOutcome;
  @override
  DateTime? get lastHeldAt;
  @override
  DateTime? get nextAt;

  /// Create a copy of SellerReportViewings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SellerReportViewingsImplCopyWith<_$SellerReportViewingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SellerReportLink _$SellerReportLinkFromJson(Map<String, dynamic> json) {
  return _SellerReportLink.fromJson(json);
}

/// @nodoc
mixin _$SellerReportLink {
  bool get active => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  int get leads => throw _privateConstructorUsedError;

  /// Serializes this SellerReportLink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SellerReportLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SellerReportLinkCopyWith<SellerReportLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerReportLinkCopyWith<$Res> {
  factory $SellerReportLinkCopyWith(
          SellerReportLink value, $Res Function(SellerReportLink) then) =
      _$SellerReportLinkCopyWithImpl<$Res, SellerReportLink>;
  @useResult
  $Res call({bool active, int views, int leads});
}

/// @nodoc
class _$SellerReportLinkCopyWithImpl<$Res, $Val extends SellerReportLink>
    implements $SellerReportLinkCopyWith<$Res> {
  _$SellerReportLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SellerReportLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? views = null,
    Object? leads = null,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      leads: null == leads
          ? _value.leads
          : leads // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SellerReportLinkImplCopyWith<$Res>
    implements $SellerReportLinkCopyWith<$Res> {
  factory _$$SellerReportLinkImplCopyWith(_$SellerReportLinkImpl value,
          $Res Function(_$SellerReportLinkImpl) then) =
      __$$SellerReportLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool active, int views, int leads});
}

/// @nodoc
class __$$SellerReportLinkImplCopyWithImpl<$Res>
    extends _$SellerReportLinkCopyWithImpl<$Res, _$SellerReportLinkImpl>
    implements _$$SellerReportLinkImplCopyWith<$Res> {
  __$$SellerReportLinkImplCopyWithImpl(_$SellerReportLinkImpl _value,
      $Res Function(_$SellerReportLinkImpl) _then)
      : super(_value, _then);

  /// Create a copy of SellerReportLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? views = null,
    Object? leads = null,
  }) {
    return _then(_$SellerReportLinkImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      leads: null == leads
          ? _value.leads
          : leads // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SellerReportLinkImpl implements _SellerReportLink {
  const _$SellerReportLinkImpl(
      {this.active = false, this.views = 0, this.leads = 0});

  factory _$SellerReportLinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$SellerReportLinkImplFromJson(json);

  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final int leads;

  @override
  String toString() {
    return 'SellerReportLink(active: $active, views: $views, leads: $leads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerReportLinkImpl &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.leads, leads) || other.leads == leads));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, active, views, leads);

  /// Create a copy of SellerReportLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerReportLinkImplCopyWith<_$SellerReportLinkImpl> get copyWith =>
      __$$SellerReportLinkImplCopyWithImpl<_$SellerReportLinkImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SellerReportLinkImplToJson(
      this,
    );
  }
}

abstract class _SellerReportLink implements SellerReportLink {
  const factory _SellerReportLink(
      {final bool active,
      final int views,
      final int leads}) = _$SellerReportLinkImpl;

  factory _SellerReportLink.fromJson(Map<String, dynamic> json) =
      _$SellerReportLinkImpl.fromJson;

  @override
  bool get active;
  @override
  int get views;
  @override
  int get leads;

  /// Create a copy of SellerReportLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SellerReportLinkImplCopyWith<_$SellerReportLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SellerReportPrice _$SellerReportPriceFromJson(Map<String, dynamic> json) {
  return _SellerReportPrice.fromJson(json);
}

/// @nodoc
mixin _$SellerReportPrice {
  double get current => throw _privateConstructorUsedError;
  double get original => throw _privateConstructorUsedError;
  double get change => throw _privateConstructorUsedError;
  double? get changePercent => throw _privateConstructorUsedError;

  /// Oldest first.
  List<PropertyPriceChange> get changes => throw _privateConstructorUsedError;

  /// Serializes this SellerReportPrice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SellerReportPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SellerReportPriceCopyWith<SellerReportPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerReportPriceCopyWith<$Res> {
  factory $SellerReportPriceCopyWith(
          SellerReportPrice value, $Res Function(SellerReportPrice) then) =
      _$SellerReportPriceCopyWithImpl<$Res, SellerReportPrice>;
  @useResult
  $Res call(
      {double current,
      double original,
      double change,
      double? changePercent,
      List<PropertyPriceChange> changes});
}

/// @nodoc
class _$SellerReportPriceCopyWithImpl<$Res, $Val extends SellerReportPrice>
    implements $SellerReportPriceCopyWith<$Res> {
  _$SellerReportPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SellerReportPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? original = null,
    Object? change = null,
    Object? changePercent = freezed,
    Object? changes = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as double,
      change: null == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
      changes: null == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as List<PropertyPriceChange>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SellerReportPriceImplCopyWith<$Res>
    implements $SellerReportPriceCopyWith<$Res> {
  factory _$$SellerReportPriceImplCopyWith(_$SellerReportPriceImpl value,
          $Res Function(_$SellerReportPriceImpl) then) =
      __$$SellerReportPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double current,
      double original,
      double change,
      double? changePercent,
      List<PropertyPriceChange> changes});
}

/// @nodoc
class __$$SellerReportPriceImplCopyWithImpl<$Res>
    extends _$SellerReportPriceCopyWithImpl<$Res, _$SellerReportPriceImpl>
    implements _$$SellerReportPriceImplCopyWith<$Res> {
  __$$SellerReportPriceImplCopyWithImpl(_$SellerReportPriceImpl _value,
      $Res Function(_$SellerReportPriceImpl) _then)
      : super(_value, _then);

  /// Create a copy of SellerReportPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? original = null,
    Object? change = null,
    Object? changePercent = freezed,
    Object? changes = null,
  }) {
    return _then(_$SellerReportPriceImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      original: null == original
          ? _value.original
          : original // ignore: cast_nullable_to_non_nullable
              as double,
      change: null == change
          ? _value.change
          : change // ignore: cast_nullable_to_non_nullable
              as double,
      changePercent: freezed == changePercent
          ? _value.changePercent
          : changePercent // ignore: cast_nullable_to_non_nullable
              as double?,
      changes: null == changes
          ? _value._changes
          : changes // ignore: cast_nullable_to_non_nullable
              as List<PropertyPriceChange>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SellerReportPriceImpl implements _SellerReportPrice {
  const _$SellerReportPriceImpl(
      {this.current = 0.0,
      this.original = 0.0,
      this.change = 0.0,
      this.changePercent,
      final List<PropertyPriceChange> changes = const <PropertyPriceChange>[]})
      : _changes = changes;

  factory _$SellerReportPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SellerReportPriceImplFromJson(json);

  @override
  @JsonKey()
  final double current;
  @override
  @JsonKey()
  final double original;
  @override
  @JsonKey()
  final double change;
  @override
  final double? changePercent;

  /// Oldest first.
  final List<PropertyPriceChange> _changes;

  /// Oldest first.
  @override
  @JsonKey()
  List<PropertyPriceChange> get changes {
    if (_changes is EqualUnmodifiableListView) return _changes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_changes);
  }

  @override
  String toString() {
    return 'SellerReportPrice(current: $current, original: $original, change: $change, changePercent: $changePercent, changes: $changes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerReportPriceImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.change, change) || other.change == change) &&
            (identical(other.changePercent, changePercent) ||
                other.changePercent == changePercent) &&
            const DeepCollectionEquality().equals(other._changes, _changes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, current, original, change,
      changePercent, const DeepCollectionEquality().hash(_changes));

  /// Create a copy of SellerReportPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerReportPriceImplCopyWith<_$SellerReportPriceImpl> get copyWith =>
      __$$SellerReportPriceImplCopyWithImpl<_$SellerReportPriceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SellerReportPriceImplToJson(
      this,
    );
  }
}

abstract class _SellerReportPrice implements SellerReportPrice {
  const factory _SellerReportPrice(
      {final double current,
      final double original,
      final double change,
      final double? changePercent,
      final List<PropertyPriceChange> changes}) = _$SellerReportPriceImpl;

  factory _SellerReportPrice.fromJson(Map<String, dynamic> json) =
      _$SellerReportPriceImpl.fromJson;

  @override
  double get current;
  @override
  double get original;
  @override
  double get change;
  @override
  double? get changePercent;

  /// Oldest first.
  @override
  List<PropertyPriceChange> get changes;

  /// Create a copy of SellerReportPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SellerReportPriceImplCopyWith<_$SellerReportPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SellerReport _$SellerReportFromJson(Map<String, dynamic> json) {
  return _SellerReport.fromJson(json);
}

/// @nodoc
mixin _$SellerReport {
  int get propertyId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  PropertyStatus get status => throw _privateConstructorUsedError;
  DateTime? get listedAt => throw _privateConstructorUsedError;
  int get daysOnMarket => throw _privateConstructorUsedError;
  DateTime? get soldAt => throw _privateConstructorUsedError;
  DateTime? get generatedOn => throw _privateConstructorUsedError;
  SellerReportViewings get viewings => throw _privateConstructorUsedError;
  SellerReportLink get publicLink => throw _privateConstructorUsedError;
  SellerReportPrice get price => throw _privateConstructorUsedError;
  int get matchingBuyers => throw _privateConstructorUsedError;

  /// Serializes this SellerReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SellerReportCopyWith<SellerReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SellerReportCopyWith<$Res> {
  factory $SellerReportCopyWith(
          SellerReport value, $Res Function(SellerReport) then) =
      _$SellerReportCopyWithImpl<$Res, SellerReport>;
  @useResult
  $Res call(
      {int propertyId,
      String title,
      String address,
      String? city,
      PropertyStatus status,
      DateTime? listedAt,
      int daysOnMarket,
      DateTime? soldAt,
      DateTime? generatedOn,
      SellerReportViewings viewings,
      SellerReportLink publicLink,
      SellerReportPrice price,
      int matchingBuyers});

  $SellerReportViewingsCopyWith<$Res> get viewings;
  $SellerReportLinkCopyWith<$Res> get publicLink;
  $SellerReportPriceCopyWith<$Res> get price;
}

/// @nodoc
class _$SellerReportCopyWithImpl<$Res, $Val extends SellerReport>
    implements $SellerReportCopyWith<$Res> {
  _$SellerReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyId = null,
    Object? title = null,
    Object? address = null,
    Object? city = freezed,
    Object? status = null,
    Object? listedAt = freezed,
    Object? daysOnMarket = null,
    Object? soldAt = freezed,
    Object? generatedOn = freezed,
    Object? viewings = null,
    Object? publicLink = null,
    Object? price = null,
    Object? matchingBuyers = null,
  }) {
    return _then(_value.copyWith(
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      listedAt: freezed == listedAt
          ? _value.listedAt
          : listedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      daysOnMarket: null == daysOnMarket
          ? _value.daysOnMarket
          : daysOnMarket // ignore: cast_nullable_to_non_nullable
              as int,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      generatedOn: freezed == generatedOn
          ? _value.generatedOn
          : generatedOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      viewings: null == viewings
          ? _value.viewings
          : viewings // ignore: cast_nullable_to_non_nullable
              as SellerReportViewings,
      publicLink: null == publicLink
          ? _value.publicLink
          : publicLink // ignore: cast_nullable_to_non_nullable
              as SellerReportLink,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as SellerReportPrice,
      matchingBuyers: null == matchingBuyers
          ? _value.matchingBuyers
          : matchingBuyers // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SellerReportViewingsCopyWith<$Res> get viewings {
    return $SellerReportViewingsCopyWith<$Res>(_value.viewings, (value) {
      return _then(_value.copyWith(viewings: value) as $Val);
    });
  }

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SellerReportLinkCopyWith<$Res> get publicLink {
    return $SellerReportLinkCopyWith<$Res>(_value.publicLink, (value) {
      return _then(_value.copyWith(publicLink: value) as $Val);
    });
  }

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SellerReportPriceCopyWith<$Res> get price {
    return $SellerReportPriceCopyWith<$Res>(_value.price, (value) {
      return _then(_value.copyWith(price: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SellerReportImplCopyWith<$Res>
    implements $SellerReportCopyWith<$Res> {
  factory _$$SellerReportImplCopyWith(
          _$SellerReportImpl value, $Res Function(_$SellerReportImpl) then) =
      __$$SellerReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int propertyId,
      String title,
      String address,
      String? city,
      PropertyStatus status,
      DateTime? listedAt,
      int daysOnMarket,
      DateTime? soldAt,
      DateTime? generatedOn,
      SellerReportViewings viewings,
      SellerReportLink publicLink,
      SellerReportPrice price,
      int matchingBuyers});

  @override
  $SellerReportViewingsCopyWith<$Res> get viewings;
  @override
  $SellerReportLinkCopyWith<$Res> get publicLink;
  @override
  $SellerReportPriceCopyWith<$Res> get price;
}

/// @nodoc
class __$$SellerReportImplCopyWithImpl<$Res>
    extends _$SellerReportCopyWithImpl<$Res, _$SellerReportImpl>
    implements _$$SellerReportImplCopyWith<$Res> {
  __$$SellerReportImplCopyWithImpl(
      _$SellerReportImpl _value, $Res Function(_$SellerReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyId = null,
    Object? title = null,
    Object? address = null,
    Object? city = freezed,
    Object? status = null,
    Object? listedAt = freezed,
    Object? daysOnMarket = null,
    Object? soldAt = freezed,
    Object? generatedOn = freezed,
    Object? viewings = null,
    Object? publicLink = null,
    Object? price = null,
    Object? matchingBuyers = null,
  }) {
    return _then(_$SellerReportImpl(
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PropertyStatus,
      listedAt: freezed == listedAt
          ? _value.listedAt
          : listedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      daysOnMarket: null == daysOnMarket
          ? _value.daysOnMarket
          : daysOnMarket // ignore: cast_nullable_to_non_nullable
              as int,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      generatedOn: freezed == generatedOn
          ? _value.generatedOn
          : generatedOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      viewings: null == viewings
          ? _value.viewings
          : viewings // ignore: cast_nullable_to_non_nullable
              as SellerReportViewings,
      publicLink: null == publicLink
          ? _value.publicLink
          : publicLink // ignore: cast_nullable_to_non_nullable
              as SellerReportLink,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as SellerReportPrice,
      matchingBuyers: null == matchingBuyers
          ? _value.matchingBuyers
          : matchingBuyers // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SellerReportImpl implements _SellerReport {
  const _$SellerReportImpl(
      {required this.propertyId,
      this.title = '',
      this.address = '',
      this.city,
      this.status = PropertyStatus.AVAILABLE,
      this.listedAt,
      this.daysOnMarket = 0,
      this.soldAt,
      this.generatedOn,
      this.viewings = const SellerReportViewings(),
      this.publicLink = const SellerReportLink(),
      this.price = const SellerReportPrice(),
      this.matchingBuyers = 0});

  factory _$SellerReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$SellerReportImplFromJson(json);

  @override
  final int propertyId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String address;
  @override
  final String? city;
  @override
  @JsonKey()
  final PropertyStatus status;
  @override
  final DateTime? listedAt;
  @override
  @JsonKey()
  final int daysOnMarket;
  @override
  final DateTime? soldAt;
  @override
  final DateTime? generatedOn;
  @override
  @JsonKey()
  final SellerReportViewings viewings;
  @override
  @JsonKey()
  final SellerReportLink publicLink;
  @override
  @JsonKey()
  final SellerReportPrice price;
  @override
  @JsonKey()
  final int matchingBuyers;

  @override
  String toString() {
    return 'SellerReport(propertyId: $propertyId, title: $title, address: $address, city: $city, status: $status, listedAt: $listedAt, daysOnMarket: $daysOnMarket, soldAt: $soldAt, generatedOn: $generatedOn, viewings: $viewings, publicLink: $publicLink, price: $price, matchingBuyers: $matchingBuyers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SellerReportImpl &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.listedAt, listedAt) ||
                other.listedAt == listedAt) &&
            (identical(other.daysOnMarket, daysOnMarket) ||
                other.daysOnMarket == daysOnMarket) &&
            (identical(other.soldAt, soldAt) || other.soldAt == soldAt) &&
            (identical(other.generatedOn, generatedOn) ||
                other.generatedOn == generatedOn) &&
            (identical(other.viewings, viewings) ||
                other.viewings == viewings) &&
            (identical(other.publicLink, publicLink) ||
                other.publicLink == publicLink) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.matchingBuyers, matchingBuyers) ||
                other.matchingBuyers == matchingBuyers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      propertyId,
      title,
      address,
      city,
      status,
      listedAt,
      daysOnMarket,
      soldAt,
      generatedOn,
      viewings,
      publicLink,
      price,
      matchingBuyers);

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SellerReportImplCopyWith<_$SellerReportImpl> get copyWith =>
      __$$SellerReportImplCopyWithImpl<_$SellerReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SellerReportImplToJson(
      this,
    );
  }
}

abstract class _SellerReport implements SellerReport {
  const factory _SellerReport(
      {required final int propertyId,
      final String title,
      final String address,
      final String? city,
      final PropertyStatus status,
      final DateTime? listedAt,
      final int daysOnMarket,
      final DateTime? soldAt,
      final DateTime? generatedOn,
      final SellerReportViewings viewings,
      final SellerReportLink publicLink,
      final SellerReportPrice price,
      final int matchingBuyers}) = _$SellerReportImpl;

  factory _SellerReport.fromJson(Map<String, dynamic> json) =
      _$SellerReportImpl.fromJson;

  @override
  int get propertyId;
  @override
  String get title;
  @override
  String get address;
  @override
  String? get city;
  @override
  PropertyStatus get status;
  @override
  DateTime? get listedAt;
  @override
  int get daysOnMarket;
  @override
  DateTime? get soldAt;
  @override
  DateTime? get generatedOn;
  @override
  SellerReportViewings get viewings;
  @override
  SellerReportLink get publicLink;
  @override
  SellerReportPrice get price;
  @override
  int get matchingBuyers;

  /// Create a copy of SellerReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SellerReportImplCopyWith<_$SellerReportImpl> get copyWith =>
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

  /// When it last went out to this buyer in a logged message.
  DateTime? get lastSentAt => throw _privateConstructorUsedError;

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
      {PropertyResponse property,
      bool overBudget,
      DateTime? lastShownAt,
      DateTime? lastSentAt});

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
    Object? lastSentAt = freezed,
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
      lastSentAt: freezed == lastSentAt
          ? _value.lastSentAt
          : lastSentAt // ignore: cast_nullable_to_non_nullable
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
      {PropertyResponse property,
      bool overBudget,
      DateTime? lastShownAt,
      DateTime? lastSentAt});

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
    Object? lastSentAt = freezed,
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
      lastSentAt: freezed == lastSentAt
          ? _value.lastSentAt
          : lastSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyMatchImpl implements _PropertyMatch {
  const _$PropertyMatchImpl(
      {required this.property,
      this.overBudget = false,
      this.lastShownAt,
      this.lastSentAt});

  factory _$PropertyMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyMatchImplFromJson(json);

  @override
  final PropertyResponse property;
  @override
  @JsonKey()
  final bool overBudget;
  @override
  final DateTime? lastShownAt;

  /// When it last went out to this buyer in a logged message.
  @override
  final DateTime? lastSentAt;

  @override
  String toString() {
    return 'PropertyMatch(property: $property, overBudget: $overBudget, lastShownAt: $lastShownAt, lastSentAt: $lastSentAt)';
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
                other.lastShownAt == lastShownAt) &&
            (identical(other.lastSentAt, lastSentAt) ||
                other.lastSentAt == lastSentAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, property, overBudget, lastShownAt, lastSentAt);

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
      final DateTime? lastShownAt,
      final DateTime? lastSentAt}) = _$PropertyMatchImpl;

  factory _PropertyMatch.fromJson(Map<String, dynamic> json) =
      _$PropertyMatchImpl.fromJson;

  @override
  PropertyResponse get property;
  @override
  bool get overBudget;
  @override
  DateTime? get lastShownAt;

  /// When it last went out to this buyer in a logged message.
  @override
  DateTime? get lastSentAt;

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
  double? get commissionPercent => throw _privateConstructorUsedError;
  double? get commission => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DealLostReason? get lostReason => throw _privateConstructorUsedError;
  String? get lostNote => throw _privateConstructorUsedError;
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
  int get commentCount => throw _privateConstructorUsedError;
  int get checklistDone => throw _privateConstructorUsedError;
  int get checklistTotal => throw _privateConstructorUsedError;
  int get openRequired => throw _privateConstructorUsedError;
  Map<String, int> get openRequiredByStage =>
      throw _privateConstructorUsedError;

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
      double? commissionPercent,
      double? commission,
      String? notes,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DealLostReason? lostReason,
      String? lostNote,
      int clientId,
      String clientName,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      int agentId,
      String agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? closedAt,
      int commentCount,
      int checklistDone,
      int checklistTotal,
      int openRequired,
      Map<String, int> openRequiredByStage});
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
    Object? commissionPercent = freezed,
    Object? commission = freezed,
    Object? notes = freezed,
    Object? lostReason = freezed,
    Object? lostNote = freezed,
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
    Object? commentCount = null,
    Object? checklistDone = null,
    Object? checklistTotal = null,
    Object? openRequired = null,
    Object? openRequiredByStage = null,
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
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      commission: freezed == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lostReason: freezed == lostReason
          ? _value.lostReason
          : lostReason // ignore: cast_nullable_to_non_nullable
              as DealLostReason?,
      lostNote: freezed == lostNote
          ? _value.lostNote
          : lostNote // ignore: cast_nullable_to_non_nullable
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
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      checklistDone: null == checklistDone
          ? _value.checklistDone
          : checklistDone // ignore: cast_nullable_to_non_nullable
              as int,
      checklistTotal: null == checklistTotal
          ? _value.checklistTotal
          : checklistTotal // ignore: cast_nullable_to_non_nullable
              as int,
      openRequired: null == openRequired
          ? _value.openRequired
          : openRequired // ignore: cast_nullable_to_non_nullable
              as int,
      openRequiredByStage: null == openRequiredByStage
          ? _value.openRequiredByStage
          : openRequiredByStage // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
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
      double? commissionPercent,
      double? commission,
      String? notes,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DealLostReason? lostReason,
      String? lostNote,
      int clientId,
      String clientName,
      int? propertyId,
      String? propertyTitle,
      String? propertyAddress,
      int agentId,
      String agentName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? closedAt,
      int commentCount,
      int checklistDone,
      int checklistTotal,
      int openRequired,
      Map<String, int> openRequiredByStage});
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
    Object? commissionPercent = freezed,
    Object? commission = freezed,
    Object? notes = freezed,
    Object? lostReason = freezed,
    Object? lostNote = freezed,
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
    Object? commentCount = null,
    Object? checklistDone = null,
    Object? checklistTotal = null,
    Object? openRequired = null,
    Object? openRequiredByStage = null,
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
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      commission: freezed == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lostReason: freezed == lostReason
          ? _value.lostReason
          : lostReason // ignore: cast_nullable_to_non_nullable
              as DealLostReason?,
      lostNote: freezed == lostNote
          ? _value.lostNote
          : lostNote // ignore: cast_nullable_to_non_nullable
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
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      checklistDone: null == checklistDone
          ? _value.checklistDone
          : checklistDone // ignore: cast_nullable_to_non_nullable
              as int,
      checklistTotal: null == checklistTotal
          ? _value.checklistTotal
          : checklistTotal // ignore: cast_nullable_to_non_nullable
              as int,
      openRequired: null == openRequired
          ? _value.openRequired
          : openRequired // ignore: cast_nullable_to_non_nullable
              as int,
      openRequiredByStage: null == openRequiredByStage
          ? _value._openRequiredByStage
          : openRequiredByStage // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
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
      this.commissionPercent,
      this.commission,
      this.notes,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.lostReason,
      this.lostNote,
      required this.clientId,
      this.clientName = '',
      this.propertyId,
      this.propertyTitle,
      this.propertyAddress,
      required this.agentId,
      this.agentName = '',
      this.createdAt,
      this.updatedAt,
      this.closedAt,
      this.commentCount = 0,
      this.checklistDone = 0,
      this.checklistTotal = 0,
      this.openRequired = 0,
      final Map<String, int> openRequiredByStage = const <String, int>{}})
      : _openRequiredByStage = openRequiredByStage;

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
  final double? commissionPercent;
  @override
  final double? commission;
  @override
  final String? notes;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final DealLostReason? lostReason;
  @override
  final String? lostNote;
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
  @JsonKey()
  final int commentCount;
  @override
  @JsonKey()
  final int checklistDone;
  @override
  @JsonKey()
  final int checklistTotal;
  @override
  @JsonKey()
  final int openRequired;
  final Map<String, int> _openRequiredByStage;
  @override
  @JsonKey()
  Map<String, int> get openRequiredByStage {
    if (_openRequiredByStage is EqualUnmodifiableMapView)
      return _openRequiredByStage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_openRequiredByStage);
  }

  @override
  String toString() {
    return 'DealResponse(id: $id, title: $title, status: $status, dealPrice: $dealPrice, budget: $budget, commissionPercent: $commissionPercent, commission: $commission, notes: $notes, lostReason: $lostReason, lostNote: $lostNote, clientId: $clientId, clientName: $clientName, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, agentId: $agentId, agentName: $agentName, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt, commentCount: $commentCount, checklistDone: $checklistDone, checklistTotal: $checklistTotal, openRequired: $openRequired, openRequiredByStage: $openRequiredByStage)';
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
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent) &&
            (identical(other.commission, commission) ||
                other.commission == commission) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lostReason, lostReason) ||
                other.lostReason == lostReason) &&
            (identical(other.lostNote, lostNote) ||
                other.lostNote == lostNote) &&
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
                other.closedAt == closedAt) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.checklistDone, checklistDone) ||
                other.checklistDone == checklistDone) &&
            (identical(other.checklistTotal, checklistTotal) ||
                other.checklistTotal == checklistTotal) &&
            (identical(other.openRequired, openRequired) ||
                other.openRequired == openRequired) &&
            const DeepCollectionEquality()
                .equals(other._openRequiredByStage, _openRequiredByStage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        status,
        dealPrice,
        budget,
        commissionPercent,
        commission,
        notes,
        lostReason,
        lostNote,
        clientId,
        clientName,
        propertyId,
        propertyTitle,
        propertyAddress,
        agentId,
        agentName,
        createdAt,
        updatedAt,
        closedAt,
        commentCount,
        checklistDone,
        checklistTotal,
        openRequired,
        const DeepCollectionEquality().hash(_openRequiredByStage)
      ]);

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
      final double? commissionPercent,
      final double? commission,
      final String? notes,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final DealLostReason? lostReason,
      final String? lostNote,
      required final int clientId,
      final String clientName,
      final int? propertyId,
      final String? propertyTitle,
      final String? propertyAddress,
      required final int agentId,
      final String agentName,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? closedAt,
      final int commentCount,
      final int checklistDone,
      final int checklistTotal,
      final int openRequired,
      final Map<String, int> openRequiredByStage}) = _$DealResponseImpl;

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
  double? get commissionPercent;
  @override
  double? get commission;
  @override
  String? get notes;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DealLostReason? get lostReason;
  @override
  String? get lostNote;
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
  @override
  int get commentCount;
  @override
  int get checklistDone;
  @override
  int get checklistTotal;
  @override
  int get openRequired;
  @override
  Map<String, int> get openRequiredByStage;

  /// Create a copy of DealResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealResponseImplCopyWith<_$DealResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) {
  return _ChecklistItem.fromJson(json);
}

/// @nodoc
mixin _$ChecklistItem {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
  ChecklistStage get stage => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  bool get required => throw _privateConstructorUsedError;
  bool get custom => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  DateTime? get doneAt => throw _privateConstructorUsedError;
  int? get doneById => throw _privateConstructorUsedError;
  String? get doneByName => throw _privateConstructorUsedError;
  int? get documentId => throw _privateConstructorUsedError;
  String? get documentName => throw _privateConstructorUsedError;

  /// Serializes this ChecklistItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChecklistItemCopyWith<ChecklistItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistItemCopyWith<$Res> {
  factory $ChecklistItemCopyWith(
          ChecklistItem value, $Res Function(ChecklistItem) then) =
      _$ChecklistItemCopyWithImpl<$Res, ChecklistItem>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: ChecklistStage.LEAD) ChecklistStage stage,
      String title,
      int position,
      bool required,
      bool custom,
      bool done,
      DateTime? doneAt,
      int? doneById,
      String? doneByName,
      int? documentId,
      String? documentName});
}

/// @nodoc
class _$ChecklistItemCopyWithImpl<$Res, $Val extends ChecklistItem>
    implements $ChecklistItemCopyWith<$Res> {
  _$ChecklistItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stage = null,
    Object? title = null,
    Object? position = null,
    Object? required = null,
    Object? custom = null,
    Object? done = null,
    Object? doneAt = freezed,
    Object? doneById = freezed,
    Object? doneByName = freezed,
    Object? documentId = freezed,
    Object? documentName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as ChecklistStage,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      required: null == required
          ? _value.required
          : required // ignore: cast_nullable_to_non_nullable
              as bool,
      custom: null == custom
          ? _value.custom
          : custom // ignore: cast_nullable_to_non_nullable
              as bool,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      doneAt: freezed == doneAt
          ? _value.doneAt
          : doneAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doneById: freezed == doneById
          ? _value.doneById
          : doneById // ignore: cast_nullable_to_non_nullable
              as int?,
      doneByName: freezed == doneByName
          ? _value.doneByName
          : doneByName // ignore: cast_nullable_to_non_nullable
              as String?,
      documentId: freezed == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as int?,
      documentName: freezed == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChecklistItemImplCopyWith<$Res>
    implements $ChecklistItemCopyWith<$Res> {
  factory _$$ChecklistItemImplCopyWith(
          _$ChecklistItemImpl value, $Res Function(_$ChecklistItemImpl) then) =
      __$$ChecklistItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: ChecklistStage.LEAD) ChecklistStage stage,
      String title,
      int position,
      bool required,
      bool custom,
      bool done,
      DateTime? doneAt,
      int? doneById,
      String? doneByName,
      int? documentId,
      String? documentName});
}

/// @nodoc
class __$$ChecklistItemImplCopyWithImpl<$Res>
    extends _$ChecklistItemCopyWithImpl<$Res, _$ChecklistItemImpl>
    implements _$$ChecklistItemImplCopyWith<$Res> {
  __$$ChecklistItemImplCopyWithImpl(
      _$ChecklistItemImpl _value, $Res Function(_$ChecklistItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stage = null,
    Object? title = null,
    Object? position = null,
    Object? required = null,
    Object? custom = null,
    Object? done = null,
    Object? doneAt = freezed,
    Object? doneById = freezed,
    Object? doneByName = freezed,
    Object? documentId = freezed,
    Object? documentName = freezed,
  }) {
    return _then(_$ChecklistItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as ChecklistStage,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      required: null == required
          ? _value.required
          : required // ignore: cast_nullable_to_non_nullable
              as bool,
      custom: null == custom
          ? _value.custom
          : custom // ignore: cast_nullable_to_non_nullable
              as bool,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      doneAt: freezed == doneAt
          ? _value.doneAt
          : doneAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doneById: freezed == doneById
          ? _value.doneById
          : doneById // ignore: cast_nullable_to_non_nullable
              as int?,
      doneByName: freezed == doneByName
          ? _value.doneByName
          : doneByName // ignore: cast_nullable_to_non_nullable
              as String?,
      documentId: freezed == documentId
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as int?,
      documentName: freezed == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChecklistItemImpl implements _ChecklistItem {
  const _$ChecklistItemImpl(
      {required this.id,
      @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
      this.stage = ChecklistStage.LEAD,
      this.title = '',
      this.position = 0,
      this.required = false,
      this.custom = false,
      this.done = false,
      this.doneAt,
      this.doneById,
      this.doneByName,
      this.documentId,
      this.documentName});

  factory _$ChecklistItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChecklistItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
  final ChecklistStage stage;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey()
  final bool required;
  @override
  @JsonKey()
  final bool custom;
  @override
  @JsonKey()
  final bool done;
  @override
  final DateTime? doneAt;
  @override
  final int? doneById;
  @override
  final String? doneByName;
  @override
  final int? documentId;
  @override
  final String? documentName;

  @override
  String toString() {
    return 'ChecklistItem(id: $id, stage: $stage, title: $title, position: $position, required: $required, custom: $custom, done: $done, doneAt: $doneAt, doneById: $doneById, doneByName: $doneByName, documentId: $documentId, documentName: $documentName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.custom, custom) || other.custom == custom) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.doneAt, doneAt) || other.doneAt == doneAt) &&
            (identical(other.doneById, doneById) ||
                other.doneById == doneById) &&
            (identical(other.doneByName, doneByName) ||
                other.doneByName == doneByName) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.documentName, documentName) ||
                other.documentName == documentName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      stage,
      title,
      position,
      required,
      custom,
      done,
      doneAt,
      doneById,
      doneByName,
      documentId,
      documentName);

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      __$$ChecklistItemImplCopyWithImpl<_$ChecklistItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistItemImplToJson(
      this,
    );
  }
}

abstract class _ChecklistItem implements ChecklistItem {
  const factory _ChecklistItem(
      {required final int id,
      @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
      final ChecklistStage stage,
      final String title,
      final int position,
      final bool required,
      final bool custom,
      final bool done,
      final DateTime? doneAt,
      final int? doneById,
      final String? doneByName,
      final int? documentId,
      final String? documentName}) = _$ChecklistItemImpl;

  factory _ChecklistItem.fromJson(Map<String, dynamic> json) =
      _$ChecklistItemImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
  ChecklistStage get stage;
  @override
  String get title;
  @override
  int get position;
  @override
  bool get required;
  @override
  bool get custom;
  @override
  bool get done;
  @override
  DateTime? get doneAt;
  @override
  int? get doneById;
  @override
  String? get doneByName;
  @override
  int? get documentId;
  @override
  String? get documentName;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageTemplate _$MessageTemplateFromJson(Map<String, dynamic> json) {
  return _MessageTemplate.fromJson(json);
}

/// @nodoc
mixin _$MessageTemplate {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MessageTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageTemplateCopyWith<MessageTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageTemplateCopyWith<$Res> {
  factory $MessageTemplateCopyWith(
          MessageTemplate value, $Res Function(MessageTemplate) then) =
      _$MessageTemplateCopyWithImpl<$Res, MessageTemplate>;
  @useResult
  $Res call({int id, String title, String body, DateTime? updatedAt});
}

/// @nodoc
class _$MessageTemplateCopyWithImpl<$Res, $Val extends MessageTemplate>
    implements $MessageTemplateCopyWith<$Res> {
  _$MessageTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
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
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageTemplateImplCopyWith<$Res>
    implements $MessageTemplateCopyWith<$Res> {
  factory _$$MessageTemplateImplCopyWith(_$MessageTemplateImpl value,
          $Res Function(_$MessageTemplateImpl) then) =
      __$$MessageTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, String body, DateTime? updatedAt});
}

/// @nodoc
class __$$MessageTemplateImplCopyWithImpl<$Res>
    extends _$MessageTemplateCopyWithImpl<$Res, _$MessageTemplateImpl>
    implements _$$MessageTemplateImplCopyWith<$Res> {
  __$$MessageTemplateImplCopyWithImpl(
      _$MessageTemplateImpl _value, $Res Function(_$MessageTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MessageTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageTemplateImpl implements _MessageTemplate {
  const _$MessageTemplateImpl(
      {required this.id, this.title = '', this.body = '', this.updatedAt});

  factory _$MessageTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageTemplateImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String body;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MessageTemplate(id: $id, title: $title, body: $body, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, body, updatedAt);

  /// Create a copy of MessageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageTemplateImplCopyWith<_$MessageTemplateImpl> get copyWith =>
      __$$MessageTemplateImplCopyWithImpl<_$MessageTemplateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageTemplateImplToJson(
      this,
    );
  }
}

abstract class _MessageTemplate implements MessageTemplate {
  const factory _MessageTemplate(
      {required final int id,
      final String title,
      final String body,
      final DateTime? updatedAt}) = _$MessageTemplateImpl;

  factory _MessageTemplate.fromJson(Map<String, dynamic> json) =
      _$MessageTemplateImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MessageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageTemplateImplCopyWith<_$MessageTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DealComment _$DealCommentFromJson(Map<String, dynamic> json) {
  return _DealComment.fromJson(json);
}

/// @nodoc
mixin _$DealComment {
  int get id => throw _privateConstructorUsedError;
  int get dealId => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int? get authorId => throw _privateConstructorUsedError;
  String? get authorName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  List<CommentMention> get mentions => throw _privateConstructorUsedError;

  /// Serializes this DealComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DealComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealCommentCopyWith<DealComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealCommentCopyWith<$Res> {
  factory $DealCommentCopyWith(
          DealComment value, $Res Function(DealComment) then) =
      _$DealCommentCopyWithImpl<$Res, DealComment>;
  @useResult
  $Res call(
      {int id,
      int dealId,
      String body,
      int? authorId,
      String? authorName,
      DateTime createdAt,
      DateTime? editedAt,
      List<CommentMention> mentions});
}

/// @nodoc
class _$DealCommentCopyWithImpl<$Res, $Val extends DealComment>
    implements $DealCommentCopyWith<$Res> {
  _$DealCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? body = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? mentions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mentions: null == mentions
          ? _value.mentions
          : mentions // ignore: cast_nullable_to_non_nullable
              as List<CommentMention>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealCommentImplCopyWith<$Res>
    implements $DealCommentCopyWith<$Res> {
  factory _$$DealCommentImplCopyWith(
          _$DealCommentImpl value, $Res Function(_$DealCommentImpl) then) =
      __$$DealCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int dealId,
      String body,
      int? authorId,
      String? authorName,
      DateTime createdAt,
      DateTime? editedAt,
      List<CommentMention> mentions});
}

/// @nodoc
class __$$DealCommentImplCopyWithImpl<$Res>
    extends _$DealCommentCopyWithImpl<$Res, _$DealCommentImpl>
    implements _$$DealCommentImplCopyWith<$Res> {
  __$$DealCommentImplCopyWithImpl(
      _$DealCommentImpl _value, $Res Function(_$DealCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? body = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? mentions = null,
  }) {
    return _then(_$DealCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as int?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mentions: null == mentions
          ? _value._mentions
          : mentions // ignore: cast_nullable_to_non_nullable
              as List<CommentMention>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealCommentImpl implements _DealComment {
  const _$DealCommentImpl(
      {required this.id,
      required this.dealId,
      this.body = '',
      this.authorId,
      this.authorName,
      required this.createdAt,
      this.editedAt,
      final List<CommentMention> mentions = const <CommentMention>[]})
      : _mentions = mentions;

  factory _$DealCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealCommentImplFromJson(json);

  @override
  final int id;
  @override
  final int dealId;
  @override
  @JsonKey()
  final String body;
  @override
  final int? authorId;
  @override
  final String? authorName;
  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;
  final List<CommentMention> _mentions;
  @override
  @JsonKey()
  List<CommentMention> get mentions {
    if (_mentions is EqualUnmodifiableListView) return _mentions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mentions);
  }

  @override
  String toString() {
    return 'DealComment(id: $id, dealId: $dealId, body: $body, authorId: $authorId, authorName: $authorName, createdAt: $createdAt, editedAt: $editedAt, mentions: $mentions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            const DeepCollectionEquality().equals(other._mentions, _mentions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      dealId,
      body,
      authorId,
      authorName,
      createdAt,
      editedAt,
      const DeepCollectionEquality().hash(_mentions));

  /// Create a copy of DealComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealCommentImplCopyWith<_$DealCommentImpl> get copyWith =>
      __$$DealCommentImplCopyWithImpl<_$DealCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealCommentImplToJson(
      this,
    );
  }
}

abstract class _DealComment implements DealComment {
  const factory _DealComment(
      {required final int id,
      required final int dealId,
      final String body,
      final int? authorId,
      final String? authorName,
      required final DateTime createdAt,
      final DateTime? editedAt,
      final List<CommentMention> mentions}) = _$DealCommentImpl;

  factory _DealComment.fromJson(Map<String, dynamic> json) =
      _$DealCommentImpl.fromJson;

  @override
  int get id;
  @override
  int get dealId;
  @override
  String get body;
  @override
  int? get authorId;
  @override
  String? get authorName;
  @override
  DateTime get createdAt;
  @override
  DateTime? get editedAt;
  @override
  List<CommentMention> get mentions;

  /// Create a copy of DealComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealCommentImplCopyWith<_$DealCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentMention _$CommentMentionFromJson(Map<String, dynamic> json) {
  return _CommentMention.fromJson(json);
}

/// @nodoc
mixin _$CommentMention {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;

  /// Serializes this CommentMention to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentMention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentMentionCopyWith<CommentMention> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentMentionCopyWith<$Res> {
  factory $CommentMentionCopyWith(
          CommentMention value, $Res Function(CommentMention) then) =
      _$CommentMentionCopyWithImpl<$Res, CommentMention>;
  @useResult
  $Res call({int id, String fullName});
}

/// @nodoc
class _$CommentMentionCopyWithImpl<$Res, $Val extends CommentMention>
    implements $CommentMentionCopyWith<$Res> {
  _$CommentMentionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentMention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentMentionImplCopyWith<$Res>
    implements $CommentMentionCopyWith<$Res> {
  factory _$$CommentMentionImplCopyWith(_$CommentMentionImpl value,
          $Res Function(_$CommentMentionImpl) then) =
      __$$CommentMentionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String fullName});
}

/// @nodoc
class __$$CommentMentionImplCopyWithImpl<$Res>
    extends _$CommentMentionCopyWithImpl<$Res, _$CommentMentionImpl>
    implements _$$CommentMentionImplCopyWith<$Res> {
  __$$CommentMentionImplCopyWithImpl(
      _$CommentMentionImpl _value, $Res Function(_$CommentMentionImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentMention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
  }) {
    return _then(_$CommentMentionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentMentionImpl implements _CommentMention {
  const _$CommentMentionImpl({required this.id, this.fullName = ''});

  factory _$CommentMentionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentMentionImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String fullName;

  @override
  String toString() {
    return 'CommentMention(id: $id, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentMentionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName);

  /// Create a copy of CommentMention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentMentionImplCopyWith<_$CommentMentionImpl> get copyWith =>
      __$$CommentMentionImplCopyWithImpl<_$CommentMentionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentMentionImplToJson(
      this,
    );
  }
}

abstract class _CommentMention implements CommentMention {
  const factory _CommentMention(
      {required final int id, final String fullName}) = _$CommentMentionImpl;

  factory _CommentMention.fromJson(Map<String, dynamic> json) =
      _$CommentMentionImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;

  /// Create a copy of CommentMention
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentMentionImplCopyWith<_$CommentMentionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DealCommentPage _$DealCommentPageFromJson(Map<String, dynamic> json) {
  return _DealCommentPage.fromJson(json);
}

/// @nodoc
mixin _$DealCommentPage {
  List<DealComment> get comments => throw _privateConstructorUsedError;
  bool get hasEarlier => throw _privateConstructorUsedError;

  /// Serializes this DealCommentPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DealCommentPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealCommentPageCopyWith<DealCommentPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealCommentPageCopyWith<$Res> {
  factory $DealCommentPageCopyWith(
          DealCommentPage value, $Res Function(DealCommentPage) then) =
      _$DealCommentPageCopyWithImpl<$Res, DealCommentPage>;
  @useResult
  $Res call({List<DealComment> comments, bool hasEarlier});
}

/// @nodoc
class _$DealCommentPageCopyWithImpl<$Res, $Val extends DealCommentPage>
    implements $DealCommentPageCopyWith<$Res> {
  _$DealCommentPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealCommentPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? hasEarlier = null,
  }) {
    return _then(_value.copyWith(
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<DealComment>,
      hasEarlier: null == hasEarlier
          ? _value.hasEarlier
          : hasEarlier // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealCommentPageImplCopyWith<$Res>
    implements $DealCommentPageCopyWith<$Res> {
  factory _$$DealCommentPageImplCopyWith(_$DealCommentPageImpl value,
          $Res Function(_$DealCommentPageImpl) then) =
      __$$DealCommentPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DealComment> comments, bool hasEarlier});
}

/// @nodoc
class __$$DealCommentPageImplCopyWithImpl<$Res>
    extends _$DealCommentPageCopyWithImpl<$Res, _$DealCommentPageImpl>
    implements _$$DealCommentPageImplCopyWith<$Res> {
  __$$DealCommentPageImplCopyWithImpl(
      _$DealCommentPageImpl _value, $Res Function(_$DealCommentPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealCommentPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? hasEarlier = null,
  }) {
    return _then(_$DealCommentPageImpl(
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<DealComment>,
      hasEarlier: null == hasEarlier
          ? _value.hasEarlier
          : hasEarlier // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealCommentPageImpl implements _DealCommentPage {
  const _$DealCommentPageImpl(
      {final List<DealComment> comments = const <DealComment>[],
      this.hasEarlier = false})
      : _comments = comments;

  factory _$DealCommentPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealCommentPageImplFromJson(json);

  final List<DealComment> _comments;
  @override
  @JsonKey()
  List<DealComment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  @JsonKey()
  final bool hasEarlier;

  @override
  String toString() {
    return 'DealCommentPage(comments: $comments, hasEarlier: $hasEarlier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealCommentPageImpl &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.hasEarlier, hasEarlier) ||
                other.hasEarlier == hasEarlier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_comments), hasEarlier);

  /// Create a copy of DealCommentPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealCommentPageImplCopyWith<_$DealCommentPageImpl> get copyWith =>
      __$$DealCommentPageImplCopyWithImpl<_$DealCommentPageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealCommentPageImplToJson(
      this,
    );
  }
}

abstract class _DealCommentPage implements DealCommentPage {
  const factory _DealCommentPage(
      {final List<DealComment> comments,
      final bool hasEarlier}) = _$DealCommentPageImpl;

  factory _DealCommentPage.fromJson(Map<String, dynamic> json) =
      _$DealCommentPageImpl.fromJson;

  @override
  List<DealComment> get comments;
  @override
  bool get hasEarlier;

  /// Create a copy of DealCommentPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealCommentPageImplCopyWith<_$DealCommentPageImpl> get copyWith =>
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

  /// The listing's pin, when it has one; what a day's route is drawn from.
  double? get propertyLatitude => throw _privateConstructorUsedError;
  double? get propertyLongitude => throw _privateConstructorUsedError;
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
      double? propertyLatitude,
      double? propertyLongitude,
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
    Object? propertyLatitude = freezed,
    Object? propertyLongitude = freezed,
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
      propertyLatitude: freezed == propertyLatitude
          ? _value.propertyLatitude
          : propertyLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      propertyLongitude: freezed == propertyLongitude
          ? _value.propertyLongitude
          : propertyLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
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
      double? propertyLatitude,
      double? propertyLongitude,
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
    Object? propertyLatitude = freezed,
    Object? propertyLongitude = freezed,
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
      propertyLatitude: freezed == propertyLatitude
          ? _value.propertyLatitude
          : propertyLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      propertyLongitude: freezed == propertyLongitude
          ? _value.propertyLongitude
          : propertyLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
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
      this.propertyLatitude,
      this.propertyLongitude,
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

  /// The listing's pin, when it has one; what a day's route is drawn from.
  @override
  final double? propertyLatitude;
  @override
  final double? propertyLongitude;
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
    return 'MeetingResponse(id: $id, title: $title, description: $description, scheduledAt: $scheduledAt, location: $location, completed: $completed, dealId: $dealId, dealTitle: $dealTitle, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, propertyLatitude: $propertyLatitude, propertyLongitude: $propertyLongitude, outcome: $outcome, outcomeNote: $outcomeNote, agentId: $agentId, agentName: $agentName, clientId: $clientId, clientName: $clientName, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.propertyLatitude, propertyLatitude) ||
                other.propertyLatitude == propertyLatitude) &&
            (identical(other.propertyLongitude, propertyLongitude) ||
                other.propertyLongitude == propertyLongitude) &&
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
        propertyLatitude,
        propertyLongitude,
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
      final double? propertyLatitude,
      final double? propertyLongitude,
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

  /// The listing's pin, when it has one; what a day's route is drawn from.
  @override
  double? get propertyLatitude;
  @override
  double? get propertyLongitude;
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

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) {
  return _TaskResponse.fromJson(json);
}

/// @nodoc
mixin _$TaskResponse {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get dueAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int? get assigneeId => throw _privateConstructorUsedError;
  String? get assigneeName => throw _privateConstructorUsedError;
  int? get createdById => throw _privateConstructorUsedError;
  String? get createdByName => throw _privateConstructorUsedError;
  int? get clientId => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  int? get dealId => throw _privateConstructorUsedError;
  String? get dealTitle => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TaskResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskResponseCopyWith<TaskResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskResponseCopyWith<$Res> {
  factory $TaskResponseCopyWith(
          TaskResponse value, $Res Function(TaskResponse) then) =
      _$TaskResponseCopyWithImpl<$Res, TaskResponse>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? note,
      DateTime dueAt,
      DateTime? completedAt,
      int? assigneeId,
      String? assigneeName,
      int? createdById,
      String? createdByName,
      int? clientId,
      String? clientName,
      int? dealId,
      String? dealTitle,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TaskResponseCopyWithImpl<$Res, $Val extends TaskResponse>
    implements $TaskResponseCopyWith<$Res> {
  _$TaskResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? note = freezed,
    Object? dueAt = null,
    Object? completedAt = freezed,
    Object? assigneeId = freezed,
    Object? assigneeName = freezed,
    Object? createdById = freezed,
    Object? createdByName = freezed,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
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
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      dueAt: null == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as int?,
      assigneeName: freezed == assigneeName
          ? _value.assigneeName
          : assigneeName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdById: freezed == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as int?,
      createdByName: freezed == createdByName
          ? _value.createdByName
          : createdByName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TaskResponseImplCopyWith<$Res>
    implements $TaskResponseCopyWith<$Res> {
  factory _$$TaskResponseImplCopyWith(
          _$TaskResponseImpl value, $Res Function(_$TaskResponseImpl) then) =
      __$$TaskResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? note,
      DateTime dueAt,
      DateTime? completedAt,
      int? assigneeId,
      String? assigneeName,
      int? createdById,
      String? createdByName,
      int? clientId,
      String? clientName,
      int? dealId,
      String? dealTitle,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TaskResponseImplCopyWithImpl<$Res>
    extends _$TaskResponseCopyWithImpl<$Res, _$TaskResponseImpl>
    implements _$$TaskResponseImplCopyWith<$Res> {
  __$$TaskResponseImplCopyWithImpl(
      _$TaskResponseImpl _value, $Res Function(_$TaskResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? note = freezed,
    Object? dueAt = null,
    Object? completedAt = freezed,
    Object? assigneeId = freezed,
    Object? assigneeName = freezed,
    Object? createdById = freezed,
    Object? createdByName = freezed,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TaskResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      dueAt: null == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as int?,
      assigneeName: freezed == assigneeName
          ? _value.assigneeName
          : assigneeName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdById: freezed == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as int?,
      createdByName: freezed == createdByName
          ? _value.createdByName
          : createdByName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
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
class _$TaskResponseImpl extends _TaskResponse {
  const _$TaskResponseImpl(
      {required this.id,
      this.title = '',
      this.note,
      required this.dueAt,
      this.completedAt,
      this.assigneeId,
      this.assigneeName,
      this.createdById,
      this.createdByName,
      this.clientId,
      this.clientName,
      this.dealId,
      this.dealTitle,
      this.createdAt,
      this.updatedAt})
      : super._();

  factory _$TaskResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskResponseImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String title;
  @override
  final String? note;
  @override
  final DateTime dueAt;
  @override
  final DateTime? completedAt;
  @override
  final int? assigneeId;
  @override
  final String? assigneeName;
  @override
  final int? createdById;
  @override
  final String? createdByName;
  @override
  final int? clientId;
  @override
  final String? clientName;
  @override
  final int? dealId;
  @override
  final String? dealTitle;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TaskResponse(id: $id, title: $title, note: $note, dueAt: $dueAt, completedAt: $completedAt, assigneeId: $assigneeId, assigneeName: $assigneeName, createdById: $createdById, createdByName: $createdByName, clientId: $clientId, clientName: $clientName, dealId: $dealId, dealTitle: $dealTitle, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.assigneeId, assigneeId) ||
                other.assigneeId == assigneeId) &&
            (identical(other.assigneeName, assigneeName) ||
                other.assigneeName == assigneeName) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
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
      note,
      dueAt,
      completedAt,
      assigneeId,
      assigneeName,
      createdById,
      createdByName,
      clientId,
      clientName,
      dealId,
      dealTitle,
      createdAt,
      updatedAt);

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      __$$TaskResponseImplCopyWithImpl<_$TaskResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskResponseImplToJson(
      this,
    );
  }
}

abstract class _TaskResponse extends TaskResponse {
  const factory _TaskResponse(
      {required final int id,
      final String title,
      final String? note,
      required final DateTime dueAt,
      final DateTime? completedAt,
      final int? assigneeId,
      final String? assigneeName,
      final int? createdById,
      final String? createdByName,
      final int? clientId,
      final String? clientName,
      final int? dealId,
      final String? dealTitle,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TaskResponseImpl;
  const _TaskResponse._() : super._();

  factory _TaskResponse.fromJson(Map<String, dynamic> json) =
      _$TaskResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get note;
  @override
  DateTime get dueAt;
  @override
  DateTime? get completedAt;
  @override
  int? get assigneeId;
  @override
  String? get assigneeName;
  @override
  int? get createdById;
  @override
  String? get createdByName;
  @override
  int? get clientId;
  @override
  String? get clientName;
  @override
  int? get dealId;
  @override
  String? get dealTitle;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TaskResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskResponseImplCopyWith<_$TaskResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
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
  double get commissionThisMonth => throw _privateConstructorUsedError;
  int get tasksDueToday => throw _privateConstructorUsedError;
  int get tasksOverdue => throw _privateConstructorUsedError;
  int get coldCount => throw _privateConstructorUsedError;

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
      int upcomingMeetings,
      double commissionThisMonth,
      int tasksDueToday,
      int tasksOverdue,
      int coldCount});
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
    Object? commissionThisMonth = null,
    Object? tasksDueToday = null,
    Object? tasksOverdue = null,
    Object? coldCount = null,
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
      commissionThisMonth: null == commissionThisMonth
          ? _value.commissionThisMonth
          : commissionThisMonth // ignore: cast_nullable_to_non_nullable
              as double,
      tasksDueToday: null == tasksDueToday
          ? _value.tasksDueToday
          : tasksDueToday // ignore: cast_nullable_to_non_nullable
              as int,
      tasksOverdue: null == tasksOverdue
          ? _value.tasksOverdue
          : tasksOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      coldCount: null == coldCount
          ? _value.coldCount
          : coldCount // ignore: cast_nullable_to_non_nullable
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
      int upcomingMeetings,
      double commissionThisMonth,
      int tasksDueToday,
      int tasksOverdue,
      int coldCount});
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
    Object? commissionThisMonth = null,
    Object? tasksDueToday = null,
    Object? tasksOverdue = null,
    Object? coldCount = null,
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
      commissionThisMonth: null == commissionThisMonth
          ? _value.commissionThisMonth
          : commissionThisMonth // ignore: cast_nullable_to_non_nullable
              as double,
      tasksDueToday: null == tasksDueToday
          ? _value.tasksDueToday
          : tasksDueToday // ignore: cast_nullable_to_non_nullable
              as int,
      tasksOverdue: null == tasksOverdue
          ? _value.tasksOverdue
          : tasksOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      coldCount: null == coldCount
          ? _value.coldCount
          : coldCount // ignore: cast_nullable_to_non_nullable
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
      this.upcomingMeetings = 0,
      this.commissionThisMonth = 0,
      this.tasksDueToday = 0,
      this.tasksOverdue = 0,
      this.coldCount = 0});

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
  @JsonKey()
  final double commissionThisMonth;
  @override
  @JsonKey()
  final int tasksDueToday;
  @override
  @JsonKey()
  final int tasksOverdue;
  @override
  @JsonKey()
  final int coldCount;

  @override
  String toString() {
    return 'DashboardSummary(totalDeals: $totalDeals, activeDeals: $activeDeals, closedDeals: $closedDeals, totalClients: $totalClients, upcomingMeetings: $upcomingMeetings, commissionThisMonth: $commissionThisMonth, tasksDueToday: $tasksDueToday, tasksOverdue: $tasksOverdue, coldCount: $coldCount)';
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
                other.upcomingMeetings == upcomingMeetings) &&
            (identical(other.commissionThisMonth, commissionThisMonth) ||
                other.commissionThisMonth == commissionThisMonth) &&
            (identical(other.tasksDueToday, tasksDueToday) ||
                other.tasksDueToday == tasksDueToday) &&
            (identical(other.tasksOverdue, tasksOverdue) ||
                other.tasksOverdue == tasksOverdue) &&
            (identical(other.coldCount, coldCount) ||
                other.coldCount == coldCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalDeals,
      activeDeals,
      closedDeals,
      totalClients,
      upcomingMeetings,
      commissionThisMonth,
      tasksDueToday,
      tasksOverdue,
      coldCount);

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
      final int upcomingMeetings,
      final double commissionThisMonth,
      final int tasksDueToday,
      final int tasksOverdue,
      final int coldCount}) = _$DashboardSummaryImpl;

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
  @override
  double get commissionThisMonth;
  @override
  int get tasksDueToday;
  @override
  int get tasksOverdue;
  @override
  int get coldCount;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalProgress _$GoalProgressFromJson(Map<String, dynamic> json) {
  return _GoalProgress.fromJson(json);
}

/// @nodoc
mixin _$GoalProgress {
  /// "2026-10".
  String get month => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;

  /// MANAGER or PERSONAL; null while there is no target.
  String? get source => throw _privateConstructorUsedError;
  double? get commissionTarget => throw _privateConstructorUsedError;
  int? get dealsTarget => throw _privateConstructorUsedError;

  /// The person's own target while the manager's overrides it.
  double? get personalCommissionTarget => throw _privateConstructorUsedError;
  int? get personalDealsTarget => throw _privateConstructorUsedError;
  double get commissionAchieved => throw _privateConstructorUsedError;
  int get dealsWon => throw _privateConstructorUsedError;
  int? get commissionPercent => throw _privateConstructorUsedError;
  int? get dealsPercent => throw _privateConstructorUsedError;
  int get daysLeft => throw _privateConstructorUsedError;
  double? get commissionPerDay => throw _privateConstructorUsedError;
  double? get dealsPerDay => throw _privateConstructorUsedError;

  /// Whether the person may set their own: not while the manager's counts.
  bool get personalEditable => throw _privateConstructorUsedError;

  /// Serializes this GoalProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalProgressCopyWith<GoalProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressCopyWith<$Res> {
  factory $GoalProgressCopyWith(
          GoalProgress value, $Res Function(GoalProgress) then) =
      _$GoalProgressCopyWithImpl<$Res, GoalProgress>;
  @useResult
  $Res call(
      {String month,
      String? currency,
      int? agentId,
      String? agentName,
      String? source,
      double? commissionTarget,
      int? dealsTarget,
      double? personalCommissionTarget,
      int? personalDealsTarget,
      double commissionAchieved,
      int dealsWon,
      int? commissionPercent,
      int? dealsPercent,
      int daysLeft,
      double? commissionPerDay,
      double? dealsPerDay,
      bool personalEditable});
}

/// @nodoc
class _$GoalProgressCopyWithImpl<$Res, $Val extends GoalProgress>
    implements $GoalProgressCopyWith<$Res> {
  _$GoalProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? currency = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? source = freezed,
    Object? commissionTarget = freezed,
    Object? dealsTarget = freezed,
    Object? personalCommissionTarget = freezed,
    Object? personalDealsTarget = freezed,
    Object? commissionAchieved = null,
    Object? dealsWon = null,
    Object? commissionPercent = freezed,
    Object? dealsPercent = freezed,
    Object? daysLeft = null,
    Object? commissionPerDay = freezed,
    Object? dealsPerDay = freezed,
    Object? personalEditable = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionTarget: freezed == commissionTarget
          ? _value.commissionTarget
          : commissionTarget // ignore: cast_nullable_to_non_nullable
              as double?,
      dealsTarget: freezed == dealsTarget
          ? _value.dealsTarget
          : dealsTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      personalCommissionTarget: freezed == personalCommissionTarget
          ? _value.personalCommissionTarget
          : personalCommissionTarget // ignore: cast_nullable_to_non_nullable
              as double?,
      personalDealsTarget: freezed == personalDealsTarget
          ? _value.personalDealsTarget
          : personalDealsTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      commissionAchieved: null == commissionAchieved
          ? _value.commissionAchieved
          : commissionAchieved // ignore: cast_nullable_to_non_nullable
              as double,
      dealsWon: null == dealsWon
          ? _value.dealsWon
          : dealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      dealsPercent: freezed == dealsPercent
          ? _value.dealsPercent
          : dealsPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      daysLeft: null == daysLeft
          ? _value.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      commissionPerDay: freezed == commissionPerDay
          ? _value.commissionPerDay
          : commissionPerDay // ignore: cast_nullable_to_non_nullable
              as double?,
      dealsPerDay: freezed == dealsPerDay
          ? _value.dealsPerDay
          : dealsPerDay // ignore: cast_nullable_to_non_nullable
              as double?,
      personalEditable: null == personalEditable
          ? _value.personalEditable
          : personalEditable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalProgressImplCopyWith<$Res>
    implements $GoalProgressCopyWith<$Res> {
  factory _$$GoalProgressImplCopyWith(
          _$GoalProgressImpl value, $Res Function(_$GoalProgressImpl) then) =
      __$$GoalProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String month,
      String? currency,
      int? agentId,
      String? agentName,
      String? source,
      double? commissionTarget,
      int? dealsTarget,
      double? personalCommissionTarget,
      int? personalDealsTarget,
      double commissionAchieved,
      int dealsWon,
      int? commissionPercent,
      int? dealsPercent,
      int daysLeft,
      double? commissionPerDay,
      double? dealsPerDay,
      bool personalEditable});
}

/// @nodoc
class __$$GoalProgressImplCopyWithImpl<$Res>
    extends _$GoalProgressCopyWithImpl<$Res, _$GoalProgressImpl>
    implements _$$GoalProgressImplCopyWith<$Res> {
  __$$GoalProgressImplCopyWithImpl(
      _$GoalProgressImpl _value, $Res Function(_$GoalProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? currency = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? source = freezed,
    Object? commissionTarget = freezed,
    Object? dealsTarget = freezed,
    Object? personalCommissionTarget = freezed,
    Object? personalDealsTarget = freezed,
    Object? commissionAchieved = null,
    Object? dealsWon = null,
    Object? commissionPercent = freezed,
    Object? dealsPercent = freezed,
    Object? daysLeft = null,
    Object? commissionPerDay = freezed,
    Object? dealsPerDay = freezed,
    Object? personalEditable = null,
  }) {
    return _then(_$GoalProgressImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionTarget: freezed == commissionTarget
          ? _value.commissionTarget
          : commissionTarget // ignore: cast_nullable_to_non_nullable
              as double?,
      dealsTarget: freezed == dealsTarget
          ? _value.dealsTarget
          : dealsTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      personalCommissionTarget: freezed == personalCommissionTarget
          ? _value.personalCommissionTarget
          : personalCommissionTarget // ignore: cast_nullable_to_non_nullable
              as double?,
      personalDealsTarget: freezed == personalDealsTarget
          ? _value.personalDealsTarget
          : personalDealsTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      commissionAchieved: null == commissionAchieved
          ? _value.commissionAchieved
          : commissionAchieved // ignore: cast_nullable_to_non_nullable
              as double,
      dealsWon: null == dealsWon
          ? _value.dealsWon
          : dealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      dealsPercent: freezed == dealsPercent
          ? _value.dealsPercent
          : dealsPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      daysLeft: null == daysLeft
          ? _value.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      commissionPerDay: freezed == commissionPerDay
          ? _value.commissionPerDay
          : commissionPerDay // ignore: cast_nullable_to_non_nullable
              as double?,
      dealsPerDay: freezed == dealsPerDay
          ? _value.dealsPerDay
          : dealsPerDay // ignore: cast_nullable_to_non_nullable
              as double?,
      personalEditable: null == personalEditable
          ? _value.personalEditable
          : personalEditable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalProgressImpl extends _GoalProgress {
  const _$GoalProgressImpl(
      {this.month = '',
      this.currency,
      this.agentId,
      this.agentName,
      this.source,
      this.commissionTarget,
      this.dealsTarget,
      this.personalCommissionTarget,
      this.personalDealsTarget,
      this.commissionAchieved = 0,
      this.dealsWon = 0,
      this.commissionPercent,
      this.dealsPercent,
      this.daysLeft = 0,
      this.commissionPerDay,
      this.dealsPerDay,
      this.personalEditable = false})
      : super._();

  factory _$GoalProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalProgressImplFromJson(json);

  /// "2026-10".
  @override
  @JsonKey()
  final String month;
  @override
  final String? currency;
  @override
  final int? agentId;
  @override
  final String? agentName;

  /// MANAGER or PERSONAL; null while there is no target.
  @override
  final String? source;
  @override
  final double? commissionTarget;
  @override
  final int? dealsTarget;

  /// The person's own target while the manager's overrides it.
  @override
  final double? personalCommissionTarget;
  @override
  final int? personalDealsTarget;
  @override
  @JsonKey()
  final double commissionAchieved;
  @override
  @JsonKey()
  final int dealsWon;
  @override
  final int? commissionPercent;
  @override
  final int? dealsPercent;
  @override
  @JsonKey()
  final int daysLeft;
  @override
  final double? commissionPerDay;
  @override
  final double? dealsPerDay;

  /// Whether the person may set their own: not while the manager's counts.
  @override
  @JsonKey()
  final bool personalEditable;

  @override
  String toString() {
    return 'GoalProgress(month: $month, currency: $currency, agentId: $agentId, agentName: $agentName, source: $source, commissionTarget: $commissionTarget, dealsTarget: $dealsTarget, personalCommissionTarget: $personalCommissionTarget, personalDealsTarget: $personalDealsTarget, commissionAchieved: $commissionAchieved, dealsWon: $dealsWon, commissionPercent: $commissionPercent, dealsPercent: $dealsPercent, daysLeft: $daysLeft, commissionPerDay: $commissionPerDay, dealsPerDay: $dealsPerDay, personalEditable: $personalEditable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.commissionTarget, commissionTarget) ||
                other.commissionTarget == commissionTarget) &&
            (identical(other.dealsTarget, dealsTarget) ||
                other.dealsTarget == dealsTarget) &&
            (identical(
                    other.personalCommissionTarget, personalCommissionTarget) ||
                other.personalCommissionTarget == personalCommissionTarget) &&
            (identical(other.personalDealsTarget, personalDealsTarget) ||
                other.personalDealsTarget == personalDealsTarget) &&
            (identical(other.commissionAchieved, commissionAchieved) ||
                other.commissionAchieved == commissionAchieved) &&
            (identical(other.dealsWon, dealsWon) ||
                other.dealsWon == dealsWon) &&
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent) &&
            (identical(other.dealsPercent, dealsPercent) ||
                other.dealsPercent == dealsPercent) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.commissionPerDay, commissionPerDay) ||
                other.commissionPerDay == commissionPerDay) &&
            (identical(other.dealsPerDay, dealsPerDay) ||
                other.dealsPerDay == dealsPerDay) &&
            (identical(other.personalEditable, personalEditable) ||
                other.personalEditable == personalEditable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      month,
      currency,
      agentId,
      agentName,
      source,
      commissionTarget,
      dealsTarget,
      personalCommissionTarget,
      personalDealsTarget,
      commissionAchieved,
      dealsWon,
      commissionPercent,
      dealsPercent,
      daysLeft,
      commissionPerDay,
      dealsPerDay,
      personalEditable);

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      __$$GoalProgressImplCopyWithImpl<_$GoalProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalProgressImplToJson(
      this,
    );
  }
}

abstract class _GoalProgress extends GoalProgress {
  const factory _GoalProgress(
      {final String month,
      final String? currency,
      final int? agentId,
      final String? agentName,
      final String? source,
      final double? commissionTarget,
      final int? dealsTarget,
      final double? personalCommissionTarget,
      final int? personalDealsTarget,
      final double commissionAchieved,
      final int dealsWon,
      final int? commissionPercent,
      final int? dealsPercent,
      final int daysLeft,
      final double? commissionPerDay,
      final double? dealsPerDay,
      final bool personalEditable}) = _$GoalProgressImpl;
  const _GoalProgress._() : super._();

  factory _GoalProgress.fromJson(Map<String, dynamic> json) =
      _$GoalProgressImpl.fromJson;

  /// "2026-10".
  @override
  String get month;
  @override
  String? get currency;
  @override
  int? get agentId;
  @override
  String? get agentName;

  /// MANAGER or PERSONAL; null while there is no target.
  @override
  String? get source;
  @override
  double? get commissionTarget;
  @override
  int? get dealsTarget;

  /// The person's own target while the manager's overrides it.
  @override
  double? get personalCommissionTarget;
  @override
  int? get personalDealsTarget;
  @override
  double get commissionAchieved;
  @override
  int get dealsWon;
  @override
  int? get commissionPercent;
  @override
  int? get dealsPercent;
  @override
  int get daysLeft;
  @override
  double? get commissionPerDay;
  @override
  double? get dealsPerDay;

  /// Whether the person may set their own: not while the manager's counts.
  @override
  bool get personalEditable;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamGoals _$TeamGoalsFromJson(Map<String, dynamic> json) {
  return _TeamGoals.fromJson(json);
}

/// @nodoc
mixin _$TeamGoals {
  String get month => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  int get daysLeft => throw _privateConstructorUsedError;
  GoalProgress get agency => throw _privateConstructorUsedError;
  List<GoalProgress> get agents => throw _privateConstructorUsedError;

  /// How many targets a copy from last month brought; null otherwise.
  int? get copied => throw _privateConstructorUsedError;

  /// Serializes this TeamGoals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamGoalsCopyWith<TeamGoals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamGoalsCopyWith<$Res> {
  factory $TeamGoalsCopyWith(TeamGoals value, $Res Function(TeamGoals) then) =
      _$TeamGoalsCopyWithImpl<$Res, TeamGoals>;
  @useResult
  $Res call(
      {String month,
      String? currency,
      int daysLeft,
      GoalProgress agency,
      List<GoalProgress> agents,
      int? copied});

  $GoalProgressCopyWith<$Res> get agency;
}

/// @nodoc
class _$TeamGoalsCopyWithImpl<$Res, $Val extends TeamGoals>
    implements $TeamGoalsCopyWith<$Res> {
  _$TeamGoalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? currency = freezed,
    Object? daysLeft = null,
    Object? agency = null,
    Object? agents = null,
    Object? copied = freezed,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      daysLeft: null == daysLeft
          ? _value.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      agency: null == agency
          ? _value.agency
          : agency // ignore: cast_nullable_to_non_nullable
              as GoalProgress,
      agents: null == agents
          ? _value.agents
          : agents // ignore: cast_nullable_to_non_nullable
              as List<GoalProgress>,
      copied: freezed == copied
          ? _value.copied
          : copied // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoalProgressCopyWith<$Res> get agency {
    return $GoalProgressCopyWith<$Res>(_value.agency, (value) {
      return _then(_value.copyWith(agency: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeamGoalsImplCopyWith<$Res>
    implements $TeamGoalsCopyWith<$Res> {
  factory _$$TeamGoalsImplCopyWith(
          _$TeamGoalsImpl value, $Res Function(_$TeamGoalsImpl) then) =
      __$$TeamGoalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String month,
      String? currency,
      int daysLeft,
      GoalProgress agency,
      List<GoalProgress> agents,
      int? copied});

  @override
  $GoalProgressCopyWith<$Res> get agency;
}

/// @nodoc
class __$$TeamGoalsImplCopyWithImpl<$Res>
    extends _$TeamGoalsCopyWithImpl<$Res, _$TeamGoalsImpl>
    implements _$$TeamGoalsImplCopyWith<$Res> {
  __$$TeamGoalsImplCopyWithImpl(
      _$TeamGoalsImpl _value, $Res Function(_$TeamGoalsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? currency = freezed,
    Object? daysLeft = null,
    Object? agency = null,
    Object? agents = null,
    Object? copied = freezed,
  }) {
    return _then(_$TeamGoalsImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      daysLeft: null == daysLeft
          ? _value.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      agency: null == agency
          ? _value.agency
          : agency // ignore: cast_nullable_to_non_nullable
              as GoalProgress,
      agents: null == agents
          ? _value._agents
          : agents // ignore: cast_nullable_to_non_nullable
              as List<GoalProgress>,
      copied: freezed == copied
          ? _value.copied
          : copied // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamGoalsImpl implements _TeamGoals {
  const _$TeamGoalsImpl(
      {this.month = '',
      this.currency,
      this.daysLeft = 0,
      required this.agency,
      final List<GoalProgress> agents = const <GoalProgress>[],
      this.copied})
      : _agents = agents;

  factory _$TeamGoalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamGoalsImplFromJson(json);

  @override
  @JsonKey()
  final String month;
  @override
  final String? currency;
  @override
  @JsonKey()
  final int daysLeft;
  @override
  final GoalProgress agency;
  final List<GoalProgress> _agents;
  @override
  @JsonKey()
  List<GoalProgress> get agents {
    if (_agents is EqualUnmodifiableListView) return _agents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_agents);
  }

  /// How many targets a copy from last month brought; null otherwise.
  @override
  final int? copied;

  @override
  String toString() {
    return 'TeamGoals(month: $month, currency: $currency, daysLeft: $daysLeft, agency: $agency, agents: $agents, copied: $copied)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamGoalsImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.agency, agency) || other.agency == agency) &&
            const DeepCollectionEquality().equals(other._agents, _agents) &&
            (identical(other.copied, copied) || other.copied == copied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, currency, daysLeft,
      agency, const DeepCollectionEquality().hash(_agents), copied);

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamGoalsImplCopyWith<_$TeamGoalsImpl> get copyWith =>
      __$$TeamGoalsImplCopyWithImpl<_$TeamGoalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamGoalsImplToJson(
      this,
    );
  }
}

abstract class _TeamGoals implements TeamGoals {
  const factory _TeamGoals(
      {final String month,
      final String? currency,
      final int daysLeft,
      required final GoalProgress agency,
      final List<GoalProgress> agents,
      final int? copied}) = _$TeamGoalsImpl;

  factory _TeamGoals.fromJson(Map<String, dynamic> json) =
      _$TeamGoalsImpl.fromJson;

  @override
  String get month;
  @override
  String? get currency;
  @override
  int get daysLeft;
  @override
  GoalProgress get agency;
  @override
  List<GoalProgress> get agents;

  /// How many targets a copy from last month brought; null otherwise.
  @override
  int? get copied;

  /// Create a copy of TeamGoals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamGoalsImplCopyWith<_$TeamGoalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ColdReason _$ColdReasonFromJson(Map<String, dynamic> json) {
  return _ColdReason.fromJson(json);
}

/// @nodoc
mixin _$ColdReason {
  @JsonKey(unknownEnumValue: ColdReasonCode.unknown)
  ColdReasonCode get code => throw _privateConstructorUsedError;
  String? get dealTitle => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DealStatus? get dealStatus => throw _privateConstructorUsedError;
  int? get matchCount => throw _privateConstructorUsedError;

  /// Serializes this ColdReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColdReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColdReasonCopyWith<ColdReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColdReasonCopyWith<$Res> {
  factory $ColdReasonCopyWith(
          ColdReason value, $Res Function(ColdReason) then) =
      _$ColdReasonCopyWithImpl<$Res, ColdReason>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: ColdReasonCode.unknown) ColdReasonCode code,
      String? dealTitle,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DealStatus? dealStatus,
      int? matchCount});
}

/// @nodoc
class _$ColdReasonCopyWithImpl<$Res, $Val extends ColdReason>
    implements $ColdReasonCopyWith<$Res> {
  _$ColdReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColdReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? dealTitle = freezed,
    Object? dealStatus = freezed,
    Object? matchCount = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ColdReasonCode,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      dealStatus: freezed == dealStatus
          ? _value.dealStatus
          : dealStatus // ignore: cast_nullable_to_non_nullable
              as DealStatus?,
      matchCount: freezed == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColdReasonImplCopyWith<$Res>
    implements $ColdReasonCopyWith<$Res> {
  factory _$$ColdReasonImplCopyWith(
          _$ColdReasonImpl value, $Res Function(_$ColdReasonImpl) then) =
      __$$ColdReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: ColdReasonCode.unknown) ColdReasonCode code,
      String? dealTitle,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DealStatus? dealStatus,
      int? matchCount});
}

/// @nodoc
class __$$ColdReasonImplCopyWithImpl<$Res>
    extends _$ColdReasonCopyWithImpl<$Res, _$ColdReasonImpl>
    implements _$$ColdReasonImplCopyWith<$Res> {
  __$$ColdReasonImplCopyWithImpl(
      _$ColdReasonImpl _value, $Res Function(_$ColdReasonImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColdReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? dealTitle = freezed,
    Object? dealStatus = freezed,
    Object? matchCount = freezed,
  }) {
    return _then(_$ColdReasonImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ColdReasonCode,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      dealStatus: freezed == dealStatus
          ? _value.dealStatus
          : dealStatus // ignore: cast_nullable_to_non_nullable
              as DealStatus?,
      matchCount: freezed == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColdReasonImpl implements _ColdReason {
  const _$ColdReasonImpl(
      {@JsonKey(unknownEnumValue: ColdReasonCode.unknown)
      this.code = ColdReasonCode.unknown,
      this.dealTitle,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.dealStatus,
      this.matchCount});

  factory _$ColdReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColdReasonImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: ColdReasonCode.unknown)
  final ColdReasonCode code;
  @override
  final String? dealTitle;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final DealStatus? dealStatus;
  @override
  final int? matchCount;

  @override
  String toString() {
    return 'ColdReason(code: $code, dealTitle: $dealTitle, dealStatus: $dealStatus, matchCount: $matchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColdReasonImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
            (identical(other.dealStatus, dealStatus) ||
                other.dealStatus == dealStatus) &&
            (identical(other.matchCount, matchCount) ||
                other.matchCount == matchCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, dealTitle, dealStatus, matchCount);

  /// Create a copy of ColdReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColdReasonImplCopyWith<_$ColdReasonImpl> get copyWith =>
      __$$ColdReasonImplCopyWithImpl<_$ColdReasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColdReasonImplToJson(
      this,
    );
  }
}

abstract class _ColdReason implements ColdReason {
  const factory _ColdReason(
      {@JsonKey(unknownEnumValue: ColdReasonCode.unknown)
      final ColdReasonCode code,
      final String? dealTitle,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final DealStatus? dealStatus,
      final int? matchCount}) = _$ColdReasonImpl;

  factory _ColdReason.fromJson(Map<String, dynamic> json) =
      _$ColdReasonImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: ColdReasonCode.unknown)
  ColdReasonCode get code;
  @override
  String? get dealTitle;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DealStatus? get dealStatus;
  @override
  int? get matchCount;

  /// Create a copy of ColdReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColdReasonImplCopyWith<_$ColdReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ColdClient _$ColdClientFromJson(Map<String, dynamic> json) {
  return _ColdClient.fromJson(json);
}

/// @nodoc
mixin _$ColdClient {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ClientType? get type => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  DateTime? get lastContactAt => throw _privateConstructorUsedError;
  int get silentDays => throw _privateConstructorUsedError;
  List<ColdReason> get reasons => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ColdNextStep? get nextStep => throw _privateConstructorUsedError;

  /// Serializes this ColdClient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColdClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColdClientCopyWith<ColdClient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColdClientCopyWith<$Res> {
  factory $ColdClientCopyWith(
          ColdClient value, $Res Function(ColdClient) then) =
      _$ColdClientCopyWithImpl<$Res, ColdClient>;
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ClientType? type,
      int? agentId,
      String? agentName,
      DateTime? lastContactAt,
      int silentDays,
      List<ColdReason> reasons,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ColdNextStep? nextStep});
}

/// @nodoc
class _$ColdClientCopyWithImpl<$Res, $Val extends ColdClient>
    implements $ColdClientCopyWith<$Res> {
  _$ColdClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColdClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = freezed,
    Object? type = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? lastContactAt = freezed,
    Object? silentDays = null,
    Object? reasons = null,
    Object? nextStep = freezed,
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
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastContactAt: freezed == lastContactAt
          ? _value.lastContactAt
          : lastContactAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      silentDays: null == silentDays
          ? _value.silentDays
          : silentDays // ignore: cast_nullable_to_non_nullable
              as int,
      reasons: null == reasons
          ? _value.reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<ColdReason>,
      nextStep: freezed == nextStep
          ? _value.nextStep
          : nextStep // ignore: cast_nullable_to_non_nullable
              as ColdNextStep?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColdClientImplCopyWith<$Res>
    implements $ColdClientCopyWith<$Res> {
  factory _$$ColdClientImplCopyWith(
          _$ColdClientImpl value, $Res Function(_$ColdClientImpl) then) =
      __$$ColdClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String fullName,
      String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ClientType? type,
      int? agentId,
      String? agentName,
      DateTime? lastContactAt,
      int silentDays,
      List<ColdReason> reasons,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ColdNextStep? nextStep});
}

/// @nodoc
class __$$ColdClientImplCopyWithImpl<$Res>
    extends _$ColdClientCopyWithImpl<$Res, _$ColdClientImpl>
    implements _$$ColdClientImplCopyWith<$Res> {
  __$$ColdClientImplCopyWithImpl(
      _$ColdClientImpl _value, $Res Function(_$ColdClientImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColdClient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = freezed,
    Object? type = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? lastContactAt = freezed,
    Object? silentDays = null,
    Object? reasons = null,
    Object? nextStep = freezed,
  }) {
    return _then(_$ColdClientImpl(
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
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastContactAt: freezed == lastContactAt
          ? _value.lastContactAt
          : lastContactAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      silentDays: null == silentDays
          ? _value.silentDays
          : silentDays // ignore: cast_nullable_to_non_nullable
              as int,
      reasons: null == reasons
          ? _value._reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<ColdReason>,
      nextStep: freezed == nextStep
          ? _value.nextStep
          : nextStep // ignore: cast_nullable_to_non_nullable
              as ColdNextStep?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColdClientImpl extends _ColdClient {
  const _$ColdClientImpl(
      {required this.id,
      this.fullName = '',
      this.phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.type,
      this.agentId,
      this.agentName,
      this.lastContactAt,
      this.silentDays = 0,
      final List<ColdReason> reasons = const <ColdReason>[],
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.nextStep})
      : _reasons = reasons,
        super._();

  factory _$ColdClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColdClientImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String fullName;
  @override
  final String? phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ClientType? type;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final DateTime? lastContactAt;
  @override
  @JsonKey()
  final int silentDays;
  final List<ColdReason> _reasons;
  @override
  @JsonKey()
  List<ColdReason> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ColdNextStep? nextStep;

  @override
  String toString() {
    return 'ColdClient(id: $id, fullName: $fullName, phone: $phone, type: $type, agentId: $agentId, agentName: $agentName, lastContactAt: $lastContactAt, silentDays: $silentDays, reasons: $reasons, nextStep: $nextStep)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColdClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.lastContactAt, lastContactAt) ||
                other.lastContactAt == lastContactAt) &&
            (identical(other.silentDays, silentDays) ||
                other.silentDays == silentDays) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            (identical(other.nextStep, nextStep) ||
                other.nextStep == nextStep));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fullName,
      phone,
      type,
      agentId,
      agentName,
      lastContactAt,
      silentDays,
      const DeepCollectionEquality().hash(_reasons),
      nextStep);

  /// Create a copy of ColdClient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColdClientImplCopyWith<_$ColdClientImpl> get copyWith =>
      __$$ColdClientImplCopyWithImpl<_$ColdClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColdClientImplToJson(
      this,
    );
  }
}

abstract class _ColdClient extends ColdClient {
  const factory _ColdClient(
      {required final int id,
      final String fullName,
      final String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final ClientType? type,
      final int? agentId,
      final String? agentName,
      final DateTime? lastContactAt,
      final int silentDays,
      final List<ColdReason> reasons,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final ColdNextStep? nextStep}) = _$ColdClientImpl;
  const _ColdClient._() : super._();

  factory _ColdClient.fromJson(Map<String, dynamic> json) =
      _$ColdClientImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  String? get phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ClientType? get type;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  DateTime? get lastContactAt;
  @override
  int get silentDays;
  @override
  List<ColdReason> get reasons;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ColdNextStep? get nextStep;

  /// Create a copy of ColdClient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColdClientImplCopyWith<_$ColdClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpcomingClientDate _$UpcomingClientDateFromJson(Map<String, dynamic> json) {
  return _UpcomingClientDate.fromJson(json);
}

/// @nodoc
mixin _$UpcomingClientDate {
  @JsonKey(unknownEnumValue: ClientDateKind.unknown)
  ClientDateKind get kind => throw _privateConstructorUsedError;

  /// The day it falls on this time; 29 February is the 28th in a common
  /// year.
  DateTime get date => throw _privateConstructorUsedError;

  /// 0 today, 1 tomorrow.
  int get daysAway => throw _privateConstructorUsedError;

  /// The age the client turns, or the years since the deal was won. Null
  /// for a birthday whose year is not known.
  int? get years => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;
  String get clientName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ClientType? get clientType => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  int? get dealId => throw _privateConstructorUsedError;
  String? get dealTitle => throw _privateConstructorUsedError;
  String? get propertyTitle => throw _privateConstructorUsedError;

  /// Serializes this UpcomingClientDate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingClientDate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingClientDateCopyWith<UpcomingClientDate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingClientDateCopyWith<$Res> {
  factory $UpcomingClientDateCopyWith(
          UpcomingClientDate value, $Res Function(UpcomingClientDate) then) =
      _$UpcomingClientDateCopyWithImpl<$Res, UpcomingClientDate>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: ClientDateKind.unknown) ClientDateKind kind,
      DateTime date,
      int daysAway,
      int? years,
      int clientId,
      String clientName,
      String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ClientType? clientType,
      int? agentId,
      String? agentName,
      int? dealId,
      String? dealTitle,
      String? propertyTitle});
}

/// @nodoc
class _$UpcomingClientDateCopyWithImpl<$Res, $Val extends UpcomingClientDate>
    implements $UpcomingClientDateCopyWith<$Res> {
  _$UpcomingClientDateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingClientDate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? date = null,
    Object? daysAway = null,
    Object? years = freezed,
    Object? clientId = null,
    Object? clientName = null,
    Object? phone = freezed,
    Object? clientType = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
    Object? propertyTitle = freezed,
  }) {
    return _then(_value.copyWith(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as ClientDateKind,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysAway: null == daysAway
          ? _value.daysAway
          : daysAway // ignore: cast_nullable_to_non_nullable
              as int,
      years: freezed == years
          ? _value.years
          : years // ignore: cast_nullable_to_non_nullable
              as int?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      clientType: freezed == clientType
          ? _value.clientType
          : clientType // ignore: cast_nullable_to_non_nullable
              as ClientType?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpcomingClientDateImplCopyWith<$Res>
    implements $UpcomingClientDateCopyWith<$Res> {
  factory _$$UpcomingClientDateImplCopyWith(_$UpcomingClientDateImpl value,
          $Res Function(_$UpcomingClientDateImpl) then) =
      __$$UpcomingClientDateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: ClientDateKind.unknown) ClientDateKind kind,
      DateTime date,
      int daysAway,
      int? years,
      int clientId,
      String clientName,
      String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      ClientType? clientType,
      int? agentId,
      String? agentName,
      int? dealId,
      String? dealTitle,
      String? propertyTitle});
}

/// @nodoc
class __$$UpcomingClientDateImplCopyWithImpl<$Res>
    extends _$UpcomingClientDateCopyWithImpl<$Res, _$UpcomingClientDateImpl>
    implements _$$UpcomingClientDateImplCopyWith<$Res> {
  __$$UpcomingClientDateImplCopyWithImpl(_$UpcomingClientDateImpl _value,
      $Res Function(_$UpcomingClientDateImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpcomingClientDate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? date = null,
    Object? daysAway = null,
    Object? years = freezed,
    Object? clientId = null,
    Object? clientName = null,
    Object? phone = freezed,
    Object? clientType = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? dealId = freezed,
    Object? dealTitle = freezed,
    Object? propertyTitle = freezed,
  }) {
    return _then(_$UpcomingClientDateImpl(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as ClientDateKind,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysAway: null == daysAway
          ? _value.daysAway
          : daysAway // ignore: cast_nullable_to_non_nullable
              as int,
      years: freezed == years
          ? _value.years
          : years // ignore: cast_nullable_to_non_nullable
              as int?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      clientType: freezed == clientType
          ? _value.clientType
          : clientType // ignore: cast_nullable_to_non_nullable
              as ClientType?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int?,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingClientDateImpl implements _UpcomingClientDate {
  const _$UpcomingClientDateImpl(
      {@JsonKey(unknownEnumValue: ClientDateKind.unknown)
      this.kind = ClientDateKind.unknown,
      required this.date,
      this.daysAway = 0,
      this.years,
      required this.clientId,
      this.clientName = '',
      this.phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.clientType,
      this.agentId,
      this.agentName,
      this.dealId,
      this.dealTitle,
      this.propertyTitle});

  factory _$UpcomingClientDateImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingClientDateImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: ClientDateKind.unknown)
  final ClientDateKind kind;

  /// The day it falls on this time; 29 February is the 28th in a common
  /// year.
  @override
  final DateTime date;

  /// 0 today, 1 tomorrow.
  @override
  @JsonKey()
  final int daysAway;

  /// The age the client turns, or the years since the deal was won. Null
  /// for a birthday whose year is not known.
  @override
  final int? years;
  @override
  final int clientId;
  @override
  @JsonKey()
  final String clientName;
  @override
  final String? phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ClientType? clientType;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final int? dealId;
  @override
  final String? dealTitle;
  @override
  final String? propertyTitle;

  @override
  String toString() {
    return 'UpcomingClientDate(kind: $kind, date: $date, daysAway: $daysAway, years: $years, clientId: $clientId, clientName: $clientName, phone: $phone, clientType: $clientType, agentId: $agentId, agentName: $agentName, dealId: $dealId, dealTitle: $dealTitle, propertyTitle: $propertyTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingClientDateImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.daysAway, daysAway) ||
                other.daysAway == daysAway) &&
            (identical(other.years, years) || other.years == years) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.clientType, clientType) ||
                other.clientType == clientType) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      kind,
      date,
      daysAway,
      years,
      clientId,
      clientName,
      phone,
      clientType,
      agentId,
      agentName,
      dealId,
      dealTitle,
      propertyTitle);

  /// Create a copy of UpcomingClientDate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingClientDateImplCopyWith<_$UpcomingClientDateImpl> get copyWith =>
      __$$UpcomingClientDateImplCopyWithImpl<_$UpcomingClientDateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingClientDateImplToJson(
      this,
    );
  }
}

abstract class _UpcomingClientDate implements UpcomingClientDate {
  const factory _UpcomingClientDate(
      {@JsonKey(unknownEnumValue: ClientDateKind.unknown)
      final ClientDateKind kind,
      required final DateTime date,
      final int daysAway,
      final int? years,
      required final int clientId,
      final String clientName,
      final String? phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final ClientType? clientType,
      final int? agentId,
      final String? agentName,
      final int? dealId,
      final String? dealTitle,
      final String? propertyTitle}) = _$UpcomingClientDateImpl;

  factory _UpcomingClientDate.fromJson(Map<String, dynamic> json) =
      _$UpcomingClientDateImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: ClientDateKind.unknown)
  ClientDateKind get kind;

  /// The day it falls on this time; 29 February is the 28th in a common
  /// year.
  @override
  DateTime get date;

  /// 0 today, 1 tomorrow.
  @override
  int get daysAway;

  /// The age the client turns, or the years since the deal was won. Null
  /// for a birthday whose year is not known.
  @override
  int? get years;
  @override
  int get clientId;
  @override
  String get clientName;
  @override
  String? get phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  ClientType? get clientType;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  int? get dealId;
  @override
  String? get dealTitle;
  @override
  String? get propertyTitle;

  /// Create a copy of UpcomingClientDate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingClientDateImplCopyWith<_$UpcomingClientDateImpl> get copyWith =>
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

DealFunnel _$DealFunnelFromJson(Map<String, dynamic> json) {
  return _DealFunnel.fromJson(json);
}

/// @nodoc
mixin _$DealFunnel {
  DateTime? get from => throw _privateConstructorUsedError;
  DateTime? get to => throw _privateConstructorUsedError;
  int get created => throw _privateConstructorUsedError;
  int get reachedNegotiation => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  int get lost => throw _privateConstructorUsedError;
  double? get leadToNegotiationRate => throw _privateConstructorUsedError;
  double? get negotiationToWonRate => throw _privateConstructorUsedError;
  double? get leadToWonRate => throw _privateConstructorUsedError;
  double get wonValue => throw _privateConstructorUsedError;
  double? get avgDaysToWin => throw _privateConstructorUsedError;
  List<FunnelLostReason> get lostReasons => throw _privateConstructorUsedError;
  List<FunnelMonth> get monthly => throw _privateConstructorUsedError;

  /// Serializes this DealFunnel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DealFunnel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealFunnelCopyWith<DealFunnel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealFunnelCopyWith<$Res> {
  factory $DealFunnelCopyWith(
          DealFunnel value, $Res Function(DealFunnel) then) =
      _$DealFunnelCopyWithImpl<$Res, DealFunnel>;
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      int created,
      int reachedNegotiation,
      int won,
      int lost,
      double? leadToNegotiationRate,
      double? negotiationToWonRate,
      double? leadToWonRate,
      double wonValue,
      double? avgDaysToWin,
      List<FunnelLostReason> lostReasons,
      List<FunnelMonth> monthly});
}

/// @nodoc
class _$DealFunnelCopyWithImpl<$Res, $Val extends DealFunnel>
    implements $DealFunnelCopyWith<$Res> {
  _$DealFunnelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealFunnel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? created = null,
    Object? reachedNegotiation = null,
    Object? won = null,
    Object? lost = null,
    Object? leadToNegotiationRate = freezed,
    Object? negotiationToWonRate = freezed,
    Object? leadToWonRate = freezed,
    Object? wonValue = null,
    Object? avgDaysToWin = freezed,
    Object? lostReasons = null,
    Object? monthly = null,
  }) {
    return _then(_value.copyWith(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as int,
      reachedNegotiation: null == reachedNegotiation
          ? _value.reachedNegotiation
          : reachedNegotiation // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
      leadToNegotiationRate: freezed == leadToNegotiationRate
          ? _value.leadToNegotiationRate
          : leadToNegotiationRate // ignore: cast_nullable_to_non_nullable
              as double?,
      negotiationToWonRate: freezed == negotiationToWonRate
          ? _value.negotiationToWonRate
          : negotiationToWonRate // ignore: cast_nullable_to_non_nullable
              as double?,
      leadToWonRate: freezed == leadToWonRate
          ? _value.leadToWonRate
          : leadToWonRate // ignore: cast_nullable_to_non_nullable
              as double?,
      wonValue: null == wonValue
          ? _value.wonValue
          : wonValue // ignore: cast_nullable_to_non_nullable
              as double,
      avgDaysToWin: freezed == avgDaysToWin
          ? _value.avgDaysToWin
          : avgDaysToWin // ignore: cast_nullable_to_non_nullable
              as double?,
      lostReasons: null == lostReasons
          ? _value.lostReasons
          : lostReasons // ignore: cast_nullable_to_non_nullable
              as List<FunnelLostReason>,
      monthly: null == monthly
          ? _value.monthly
          : monthly // ignore: cast_nullable_to_non_nullable
              as List<FunnelMonth>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealFunnelImplCopyWith<$Res>
    implements $DealFunnelCopyWith<$Res> {
  factory _$$DealFunnelImplCopyWith(
          _$DealFunnelImpl value, $Res Function(_$DealFunnelImpl) then) =
      __$$DealFunnelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      int created,
      int reachedNegotiation,
      int won,
      int lost,
      double? leadToNegotiationRate,
      double? negotiationToWonRate,
      double? leadToWonRate,
      double wonValue,
      double? avgDaysToWin,
      List<FunnelLostReason> lostReasons,
      List<FunnelMonth> monthly});
}

/// @nodoc
class __$$DealFunnelImplCopyWithImpl<$Res>
    extends _$DealFunnelCopyWithImpl<$Res, _$DealFunnelImpl>
    implements _$$DealFunnelImplCopyWith<$Res> {
  __$$DealFunnelImplCopyWithImpl(
      _$DealFunnelImpl _value, $Res Function(_$DealFunnelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealFunnel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? created = null,
    Object? reachedNegotiation = null,
    Object? won = null,
    Object? lost = null,
    Object? leadToNegotiationRate = freezed,
    Object? negotiationToWonRate = freezed,
    Object? leadToWonRate = freezed,
    Object? wonValue = null,
    Object? avgDaysToWin = freezed,
    Object? lostReasons = null,
    Object? monthly = null,
  }) {
    return _then(_$DealFunnelImpl(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as int,
      reachedNegotiation: null == reachedNegotiation
          ? _value.reachedNegotiation
          : reachedNegotiation // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
      leadToNegotiationRate: freezed == leadToNegotiationRate
          ? _value.leadToNegotiationRate
          : leadToNegotiationRate // ignore: cast_nullable_to_non_nullable
              as double?,
      negotiationToWonRate: freezed == negotiationToWonRate
          ? _value.negotiationToWonRate
          : negotiationToWonRate // ignore: cast_nullable_to_non_nullable
              as double?,
      leadToWonRate: freezed == leadToWonRate
          ? _value.leadToWonRate
          : leadToWonRate // ignore: cast_nullable_to_non_nullable
              as double?,
      wonValue: null == wonValue
          ? _value.wonValue
          : wonValue // ignore: cast_nullable_to_non_nullable
              as double,
      avgDaysToWin: freezed == avgDaysToWin
          ? _value.avgDaysToWin
          : avgDaysToWin // ignore: cast_nullable_to_non_nullable
              as double?,
      lostReasons: null == lostReasons
          ? _value._lostReasons
          : lostReasons // ignore: cast_nullable_to_non_nullable
              as List<FunnelLostReason>,
      monthly: null == monthly
          ? _value._monthly
          : monthly // ignore: cast_nullable_to_non_nullable
              as List<FunnelMonth>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealFunnelImpl implements _DealFunnel {
  const _$DealFunnelImpl(
      {this.from,
      this.to,
      this.created = 0,
      this.reachedNegotiation = 0,
      this.won = 0,
      this.lost = 0,
      this.leadToNegotiationRate,
      this.negotiationToWonRate,
      this.leadToWonRate,
      this.wonValue = 0,
      this.avgDaysToWin,
      final List<FunnelLostReason> lostReasons = const <FunnelLostReason>[],
      final List<FunnelMonth> monthly = const <FunnelMonth>[]})
      : _lostReasons = lostReasons,
        _monthly = monthly;

  factory _$DealFunnelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealFunnelImplFromJson(json);

  @override
  final DateTime? from;
  @override
  final DateTime? to;
  @override
  @JsonKey()
  final int created;
  @override
  @JsonKey()
  final int reachedNegotiation;
  @override
  @JsonKey()
  final int won;
  @override
  @JsonKey()
  final int lost;
  @override
  final double? leadToNegotiationRate;
  @override
  final double? negotiationToWonRate;
  @override
  final double? leadToWonRate;
  @override
  @JsonKey()
  final double wonValue;
  @override
  final double? avgDaysToWin;
  final List<FunnelLostReason> _lostReasons;
  @override
  @JsonKey()
  List<FunnelLostReason> get lostReasons {
    if (_lostReasons is EqualUnmodifiableListView) return _lostReasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lostReasons);
  }

  final List<FunnelMonth> _monthly;
  @override
  @JsonKey()
  List<FunnelMonth> get monthly {
    if (_monthly is EqualUnmodifiableListView) return _monthly;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthly);
  }

  @override
  String toString() {
    return 'DealFunnel(from: $from, to: $to, created: $created, reachedNegotiation: $reachedNegotiation, won: $won, lost: $lost, leadToNegotiationRate: $leadToNegotiationRate, negotiationToWonRate: $negotiationToWonRate, leadToWonRate: $leadToWonRate, wonValue: $wonValue, avgDaysToWin: $avgDaysToWin, lostReasons: $lostReasons, monthly: $monthly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealFunnelImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.reachedNegotiation, reachedNegotiation) ||
                other.reachedNegotiation == reachedNegotiation) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.leadToNegotiationRate, leadToNegotiationRate) ||
                other.leadToNegotiationRate == leadToNegotiationRate) &&
            (identical(other.negotiationToWonRate, negotiationToWonRate) ||
                other.negotiationToWonRate == negotiationToWonRate) &&
            (identical(other.leadToWonRate, leadToWonRate) ||
                other.leadToWonRate == leadToWonRate) &&
            (identical(other.wonValue, wonValue) ||
                other.wonValue == wonValue) &&
            (identical(other.avgDaysToWin, avgDaysToWin) ||
                other.avgDaysToWin == avgDaysToWin) &&
            const DeepCollectionEquality()
                .equals(other._lostReasons, _lostReasons) &&
            const DeepCollectionEquality().equals(other._monthly, _monthly));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      from,
      to,
      created,
      reachedNegotiation,
      won,
      lost,
      leadToNegotiationRate,
      negotiationToWonRate,
      leadToWonRate,
      wonValue,
      avgDaysToWin,
      const DeepCollectionEquality().hash(_lostReasons),
      const DeepCollectionEquality().hash(_monthly));

  /// Create a copy of DealFunnel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealFunnelImplCopyWith<_$DealFunnelImpl> get copyWith =>
      __$$DealFunnelImplCopyWithImpl<_$DealFunnelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealFunnelImplToJson(
      this,
    );
  }
}

abstract class _DealFunnel implements DealFunnel {
  const factory _DealFunnel(
      {final DateTime? from,
      final DateTime? to,
      final int created,
      final int reachedNegotiation,
      final int won,
      final int lost,
      final double? leadToNegotiationRate,
      final double? negotiationToWonRate,
      final double? leadToWonRate,
      final double wonValue,
      final double? avgDaysToWin,
      final List<FunnelLostReason> lostReasons,
      final List<FunnelMonth> monthly}) = _$DealFunnelImpl;

  factory _DealFunnel.fromJson(Map<String, dynamic> json) =
      _$DealFunnelImpl.fromJson;

  @override
  DateTime? get from;
  @override
  DateTime? get to;
  @override
  int get created;
  @override
  int get reachedNegotiation;
  @override
  int get won;
  @override
  int get lost;
  @override
  double? get leadToNegotiationRate;
  @override
  double? get negotiationToWonRate;
  @override
  double? get leadToWonRate;
  @override
  double get wonValue;
  @override
  double? get avgDaysToWin;
  @override
  List<FunnelLostReason> get lostReasons;
  @override
  List<FunnelMonth> get monthly;

  /// Create a copy of DealFunnel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealFunnelImplCopyWith<_$DealFunnelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadSourceBreakdown _$LeadSourceBreakdownFromJson(Map<String, dynamic> json) {
  return _LeadSourceBreakdown.fromJson(json);
}

/// @nodoc
mixin _$LeadSourceBreakdown {
  DateTime? get from => throw _privateConstructorUsedError;
  DateTime? get to => throw _privateConstructorUsedError;
  int get clients => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  List<LeadSourceRow> get sources => throw _privateConstructorUsedError;

  /// Serializes this LeadSourceBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadSourceBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadSourceBreakdownCopyWith<LeadSourceBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadSourceBreakdownCopyWith<$Res> {
  factory $LeadSourceBreakdownCopyWith(
          LeadSourceBreakdown value, $Res Function(LeadSourceBreakdown) then) =
      _$LeadSourceBreakdownCopyWithImpl<$Res, LeadSourceBreakdown>;
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      int clients,
      int won,
      List<LeadSourceRow> sources});
}

/// @nodoc
class _$LeadSourceBreakdownCopyWithImpl<$Res, $Val extends LeadSourceBreakdown>
    implements $LeadSourceBreakdownCopyWith<$Res> {
  _$LeadSourceBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadSourceBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? clients = null,
    Object? won = null,
    Object? sources = null,
  }) {
    return _then(_value.copyWith(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clients: null == clients
          ? _value.clients
          : clients // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<LeadSourceRow>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeadSourceBreakdownImplCopyWith<$Res>
    implements $LeadSourceBreakdownCopyWith<$Res> {
  factory _$$LeadSourceBreakdownImplCopyWith(_$LeadSourceBreakdownImpl value,
          $Res Function(_$LeadSourceBreakdownImpl) then) =
      __$$LeadSourceBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      int clients,
      int won,
      List<LeadSourceRow> sources});
}

/// @nodoc
class __$$LeadSourceBreakdownImplCopyWithImpl<$Res>
    extends _$LeadSourceBreakdownCopyWithImpl<$Res, _$LeadSourceBreakdownImpl>
    implements _$$LeadSourceBreakdownImplCopyWith<$Res> {
  __$$LeadSourceBreakdownImplCopyWithImpl(_$LeadSourceBreakdownImpl _value,
      $Res Function(_$LeadSourceBreakdownImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeadSourceBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? clients = null,
    Object? won = null,
    Object? sources = null,
  }) {
    return _then(_$LeadSourceBreakdownImpl(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clients: null == clients
          ? _value.clients
          : clients // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<LeadSourceRow>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadSourceBreakdownImpl implements _LeadSourceBreakdown {
  const _$LeadSourceBreakdownImpl(
      {this.from,
      this.to,
      this.clients = 0,
      this.won = 0,
      final List<LeadSourceRow> sources = const <LeadSourceRow>[]})
      : _sources = sources;

  factory _$LeadSourceBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadSourceBreakdownImplFromJson(json);

  @override
  final DateTime? from;
  @override
  final DateTime? to;
  @override
  @JsonKey()
  final int clients;
  @override
  @JsonKey()
  final int won;
  final List<LeadSourceRow> _sources;
  @override
  @JsonKey()
  List<LeadSourceRow> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'LeadSourceBreakdown(from: $from, to: $to, clients: $clients, won: $won, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadSourceBreakdownImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.clients, clients) || other.clients == clients) &&
            (identical(other.won, won) || other.won == won) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to, clients, won,
      const DeepCollectionEquality().hash(_sources));

  /// Create a copy of LeadSourceBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadSourceBreakdownImplCopyWith<_$LeadSourceBreakdownImpl> get copyWith =>
      __$$LeadSourceBreakdownImplCopyWithImpl<_$LeadSourceBreakdownImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadSourceBreakdownImplToJson(
      this,
    );
  }
}

abstract class _LeadSourceBreakdown implements LeadSourceBreakdown {
  const factory _LeadSourceBreakdown(
      {final DateTime? from,
      final DateTime? to,
      final int clients,
      final int won,
      final List<LeadSourceRow> sources}) = _$LeadSourceBreakdownImpl;

  factory _LeadSourceBreakdown.fromJson(Map<String, dynamic> json) =
      _$LeadSourceBreakdownImpl.fromJson;

  @override
  DateTime? get from;
  @override
  DateTime? get to;
  @override
  int get clients;
  @override
  int get won;
  @override
  List<LeadSourceRow> get sources;

  /// Create a copy of LeadSourceBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadSourceBreakdownImplCopyWith<_$LeadSourceBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadSourceRow _$LeadSourceRowFromJson(Map<String, dynamic> json) {
  return _LeadSourceRow.fromJson(json);
}

/// @nodoc
mixin _$LeadSourceRow {
  String get source => throw _privateConstructorUsedError;
  int get clients => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  double get conversionRate => throw _privateConstructorUsedError;

  /// Serializes this LeadSourceRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadSourceRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadSourceRowCopyWith<LeadSourceRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadSourceRowCopyWith<$Res> {
  factory $LeadSourceRowCopyWith(
          LeadSourceRow value, $Res Function(LeadSourceRow) then) =
      _$LeadSourceRowCopyWithImpl<$Res, LeadSourceRow>;
  @useResult
  $Res call({String source, int clients, int won, double conversionRate});
}

/// @nodoc
class _$LeadSourceRowCopyWithImpl<$Res, $Val extends LeadSourceRow>
    implements $LeadSourceRowCopyWith<$Res> {
  _$LeadSourceRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadSourceRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? clients = null,
    Object? won = null,
    Object? conversionRate = null,
  }) {
    return _then(_value.copyWith(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      clients: null == clients
          ? _value.clients
          : clients // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeadSourceRowImplCopyWith<$Res>
    implements $LeadSourceRowCopyWith<$Res> {
  factory _$$LeadSourceRowImplCopyWith(
          _$LeadSourceRowImpl value, $Res Function(_$LeadSourceRowImpl) then) =
      __$$LeadSourceRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String source, int clients, int won, double conversionRate});
}

/// @nodoc
class __$$LeadSourceRowImplCopyWithImpl<$Res>
    extends _$LeadSourceRowCopyWithImpl<$Res, _$LeadSourceRowImpl>
    implements _$$LeadSourceRowImplCopyWith<$Res> {
  __$$LeadSourceRowImplCopyWithImpl(
      _$LeadSourceRowImpl _value, $Res Function(_$LeadSourceRowImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeadSourceRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? clients = null,
    Object? won = null,
    Object? conversionRate = null,
  }) {
    return _then(_$LeadSourceRowImpl(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      clients: null == clients
          ? _value.clients
          : clients // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadSourceRowImpl implements _LeadSourceRow {
  const _$LeadSourceRowImpl(
      {this.source = 'UNKNOWN',
      this.clients = 0,
      this.won = 0,
      this.conversionRate = 0});

  factory _$LeadSourceRowImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadSourceRowImplFromJson(json);

  @override
  @JsonKey()
  final String source;
  @override
  @JsonKey()
  final int clients;
  @override
  @JsonKey()
  final int won;
  @override
  @JsonKey()
  final double conversionRate;

  @override
  String toString() {
    return 'LeadSourceRow(source: $source, clients: $clients, won: $won, conversionRate: $conversionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadSourceRowImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.clients, clients) || other.clients == clients) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, source, clients, won, conversionRate);

  /// Create a copy of LeadSourceRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadSourceRowImplCopyWith<_$LeadSourceRowImpl> get copyWith =>
      __$$LeadSourceRowImplCopyWithImpl<_$LeadSourceRowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadSourceRowImplToJson(
      this,
    );
  }
}

abstract class _LeadSourceRow implements LeadSourceRow {
  const factory _LeadSourceRow(
      {final String source,
      final int clients,
      final int won,
      final double conversionRate}) = _$LeadSourceRowImpl;

  factory _LeadSourceRow.fromJson(Map<String, dynamic> json) =
      _$LeadSourceRowImpl.fromJson;

  @override
  String get source;
  @override
  int get clients;
  @override
  int get won;
  @override
  double get conversionRate;

  /// Create a copy of LeadSourceRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadSourceRowImplCopyWith<_$LeadSourceRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FunnelLostReason _$FunnelLostReasonFromJson(Map<String, dynamic> json) {
  return _FunnelLostReason.fromJson(json);
}

/// @nodoc
mixin _$FunnelLostReason {
  String get reason => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get share => throw _privateConstructorUsedError;

  /// Serializes this FunnelLostReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FunnelLostReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FunnelLostReasonCopyWith<FunnelLostReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FunnelLostReasonCopyWith<$Res> {
  factory $FunnelLostReasonCopyWith(
          FunnelLostReason value, $Res Function(FunnelLostReason) then) =
      _$FunnelLostReasonCopyWithImpl<$Res, FunnelLostReason>;
  @useResult
  $Res call({String reason, int count, double share});
}

/// @nodoc
class _$FunnelLostReasonCopyWithImpl<$Res, $Val extends FunnelLostReason>
    implements $FunnelLostReasonCopyWith<$Res> {
  _$FunnelLostReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FunnelLostReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
    Object? count = null,
    Object? share = null,
  }) {
    return _then(_value.copyWith(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      share: null == share
          ? _value.share
          : share // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FunnelLostReasonImplCopyWith<$Res>
    implements $FunnelLostReasonCopyWith<$Res> {
  factory _$$FunnelLostReasonImplCopyWith(_$FunnelLostReasonImpl value,
          $Res Function(_$FunnelLostReasonImpl) then) =
      __$$FunnelLostReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason, int count, double share});
}

/// @nodoc
class __$$FunnelLostReasonImplCopyWithImpl<$Res>
    extends _$FunnelLostReasonCopyWithImpl<$Res, _$FunnelLostReasonImpl>
    implements _$$FunnelLostReasonImplCopyWith<$Res> {
  __$$FunnelLostReasonImplCopyWithImpl(_$FunnelLostReasonImpl _value,
      $Res Function(_$FunnelLostReasonImpl) _then)
      : super(_value, _then);

  /// Create a copy of FunnelLostReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
    Object? count = null,
    Object? share = null,
  }) {
    return _then(_$FunnelLostReasonImpl(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      share: null == share
          ? _value.share
          : share // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FunnelLostReasonImpl implements _FunnelLostReason {
  const _$FunnelLostReasonImpl(
      {this.reason = 'UNSPECIFIED', this.count = 0, this.share = 0});

  factory _$FunnelLostReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$FunnelLostReasonImplFromJson(json);

  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final double share;

  @override
  String toString() {
    return 'FunnelLostReason(reason: $reason, count: $count, share: $share)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FunnelLostReasonImpl &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.share, share) || other.share == share));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason, count, share);

  /// Create a copy of FunnelLostReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FunnelLostReasonImplCopyWith<_$FunnelLostReasonImpl> get copyWith =>
      __$$FunnelLostReasonImplCopyWithImpl<_$FunnelLostReasonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FunnelLostReasonImplToJson(
      this,
    );
  }
}

abstract class _FunnelLostReason implements FunnelLostReason {
  const factory _FunnelLostReason(
      {final String reason,
      final int count,
      final double share}) = _$FunnelLostReasonImpl;

  factory _FunnelLostReason.fromJson(Map<String, dynamic> json) =
      _$FunnelLostReasonImpl.fromJson;

  @override
  String get reason;
  @override
  int get count;
  @override
  double get share;

  /// Create a copy of FunnelLostReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FunnelLostReasonImplCopyWith<_$FunnelLostReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FunnelMonth _$FunnelMonthFromJson(Map<String, dynamic> json) {
  return _FunnelMonth.fromJson(json);
}

/// @nodoc
mixin _$FunnelMonth {
  DateTime get month => throw _privateConstructorUsedError;
  int get created => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  int get lost => throw _privateConstructorUsedError;

  /// Serializes this FunnelMonth to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FunnelMonth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FunnelMonthCopyWith<FunnelMonth> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FunnelMonthCopyWith<$Res> {
  factory $FunnelMonthCopyWith(
          FunnelMonth value, $Res Function(FunnelMonth) then) =
      _$FunnelMonthCopyWithImpl<$Res, FunnelMonth>;
  @useResult
  $Res call({DateTime month, int created, int won, int lost});
}

/// @nodoc
class _$FunnelMonthCopyWithImpl<$Res, $Val extends FunnelMonth>
    implements $FunnelMonthCopyWith<$Res> {
  _$FunnelMonthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FunnelMonth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? created = null,
    Object? won = null,
    Object? lost = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FunnelMonthImplCopyWith<$Res>
    implements $FunnelMonthCopyWith<$Res> {
  factory _$$FunnelMonthImplCopyWith(
          _$FunnelMonthImpl value, $Res Function(_$FunnelMonthImpl) then) =
      __$$FunnelMonthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime month, int created, int won, int lost});
}

/// @nodoc
class __$$FunnelMonthImplCopyWithImpl<$Res>
    extends _$FunnelMonthCopyWithImpl<$Res, _$FunnelMonthImpl>
    implements _$$FunnelMonthImplCopyWith<$Res> {
  __$$FunnelMonthImplCopyWithImpl(
      _$FunnelMonthImpl _value, $Res Function(_$FunnelMonthImpl) _then)
      : super(_value, _then);

  /// Create a copy of FunnelMonth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? created = null,
    Object? won = null,
    Object? lost = null,
  }) {
    return _then(_$FunnelMonthImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FunnelMonthImpl implements _FunnelMonth {
  const _$FunnelMonthImpl(
      {required this.month, this.created = 0, this.won = 0, this.lost = 0});

  factory _$FunnelMonthImpl.fromJson(Map<String, dynamic> json) =>
      _$$FunnelMonthImplFromJson(json);

  @override
  final DateTime month;
  @override
  @JsonKey()
  final int created;
  @override
  @JsonKey()
  final int won;
  @override
  @JsonKey()
  final int lost;

  @override
  String toString() {
    return 'FunnelMonth(month: $month, created: $created, won: $won, lost: $lost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FunnelMonthImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.lost, lost) || other.lost == lost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, created, won, lost);

  /// Create a copy of FunnelMonth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FunnelMonthImplCopyWith<_$FunnelMonthImpl> get copyWith =>
      __$$FunnelMonthImplCopyWithImpl<_$FunnelMonthImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FunnelMonthImplToJson(
      this,
    );
  }
}

abstract class _FunnelMonth implements FunnelMonth {
  const factory _FunnelMonth(
      {required final DateTime month,
      final int created,
      final int won,
      final int lost}) = _$FunnelMonthImpl;

  factory _FunnelMonth.fromJson(Map<String, dynamic> json) =
      _$FunnelMonthImpl.fromJson;

  @override
  DateTime get month;
  @override
  int get created;
  @override
  int get won;
  @override
  int get lost;

  /// Create a copy of FunnelMonth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FunnelMonthImplCopyWith<_$FunnelMonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentLeaderboard _$AgentLeaderboardFromJson(Map<String, dynamic> json) {
  return _AgentLeaderboard.fromJson(json);
}

/// @nodoc
mixin _$AgentLeaderboard {
  DateTime? get from => throw _privateConstructorUsedError;
  DateTime? get to => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  List<LeaderboardRow> get agents => throw _privateConstructorUsedError;
  List<LeaderboardRow> get inactive => throw _privateConstructorUsedError;
  LeaderboardRow? get totals => throw _privateConstructorUsedError;

  /// Serializes this AgentLeaderboard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentLeaderboardCopyWith<AgentLeaderboard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentLeaderboardCopyWith<$Res> {
  factory $AgentLeaderboardCopyWith(
          AgentLeaderboard value, $Res Function(AgentLeaderboard) then) =
      _$AgentLeaderboardCopyWithImpl<$Res, AgentLeaderboard>;
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      String? currency,
      List<LeaderboardRow> agents,
      List<LeaderboardRow> inactive,
      LeaderboardRow? totals});

  $LeaderboardRowCopyWith<$Res>? get totals;
}

/// @nodoc
class _$AgentLeaderboardCopyWithImpl<$Res, $Val extends AgentLeaderboard>
    implements $AgentLeaderboardCopyWith<$Res> {
  _$AgentLeaderboardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? currency = freezed,
    Object? agents = null,
    Object? inactive = null,
    Object? totals = freezed,
  }) {
    return _then(_value.copyWith(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      agents: null == agents
          ? _value.agents
          : agents // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardRow>,
      inactive: null == inactive
          ? _value.inactive
          : inactive // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardRow>,
      totals: freezed == totals
          ? _value.totals
          : totals // ignore: cast_nullable_to_non_nullable
              as LeaderboardRow?,
    ) as $Val);
  }

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaderboardRowCopyWith<$Res>? get totals {
    if (_value.totals == null) {
      return null;
    }

    return $LeaderboardRowCopyWith<$Res>(_value.totals!, (value) {
      return _then(_value.copyWith(totals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AgentLeaderboardImplCopyWith<$Res>
    implements $AgentLeaderboardCopyWith<$Res> {
  factory _$$AgentLeaderboardImplCopyWith(_$AgentLeaderboardImpl value,
          $Res Function(_$AgentLeaderboardImpl) then) =
      __$$AgentLeaderboardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? from,
      DateTime? to,
      String? currency,
      List<LeaderboardRow> agents,
      List<LeaderboardRow> inactive,
      LeaderboardRow? totals});

  @override
  $LeaderboardRowCopyWith<$Res>? get totals;
}

/// @nodoc
class __$$AgentLeaderboardImplCopyWithImpl<$Res>
    extends _$AgentLeaderboardCopyWithImpl<$Res, _$AgentLeaderboardImpl>
    implements _$$AgentLeaderboardImplCopyWith<$Res> {
  __$$AgentLeaderboardImplCopyWithImpl(_$AgentLeaderboardImpl _value,
      $Res Function(_$AgentLeaderboardImpl) _then)
      : super(_value, _then);

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? currency = freezed,
    Object? agents = null,
    Object? inactive = null,
    Object? totals = freezed,
  }) {
    return _then(_$AgentLeaderboardImpl(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      agents: null == agents
          ? _value._agents
          : agents // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardRow>,
      inactive: null == inactive
          ? _value._inactive
          : inactive // ignore: cast_nullable_to_non_nullable
              as List<LeaderboardRow>,
      totals: freezed == totals
          ? _value.totals
          : totals // ignore: cast_nullable_to_non_nullable
              as LeaderboardRow?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentLeaderboardImpl implements _AgentLeaderboard {
  const _$AgentLeaderboardImpl(
      {this.from,
      this.to,
      this.currency,
      final List<LeaderboardRow> agents = const <LeaderboardRow>[],
      final List<LeaderboardRow> inactive = const <LeaderboardRow>[],
      this.totals})
      : _agents = agents,
        _inactive = inactive;

  factory _$AgentLeaderboardImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentLeaderboardImplFromJson(json);

  @override
  final DateTime? from;
  @override
  final DateTime? to;
  @override
  final String? currency;
  final List<LeaderboardRow> _agents;
  @override
  @JsonKey()
  List<LeaderboardRow> get agents {
    if (_agents is EqualUnmodifiableListView) return _agents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_agents);
  }

  final List<LeaderboardRow> _inactive;
  @override
  @JsonKey()
  List<LeaderboardRow> get inactive {
    if (_inactive is EqualUnmodifiableListView) return _inactive;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inactive);
  }

  @override
  final LeaderboardRow? totals;

  @override
  String toString() {
    return 'AgentLeaderboard(from: $from, to: $to, currency: $currency, agents: $agents, inactive: $inactive, totals: $totals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentLeaderboardImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other._agents, _agents) &&
            const DeepCollectionEquality().equals(other._inactive, _inactive) &&
            (identical(other.totals, totals) || other.totals == totals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      from,
      to,
      currency,
      const DeepCollectionEquality().hash(_agents),
      const DeepCollectionEquality().hash(_inactive),
      totals);

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentLeaderboardImplCopyWith<_$AgentLeaderboardImpl> get copyWith =>
      __$$AgentLeaderboardImplCopyWithImpl<_$AgentLeaderboardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentLeaderboardImplToJson(
      this,
    );
  }
}

abstract class _AgentLeaderboard implements AgentLeaderboard {
  const factory _AgentLeaderboard(
      {final DateTime? from,
      final DateTime? to,
      final String? currency,
      final List<LeaderboardRow> agents,
      final List<LeaderboardRow> inactive,
      final LeaderboardRow? totals}) = _$AgentLeaderboardImpl;

  factory _AgentLeaderboard.fromJson(Map<String, dynamic> json) =
      _$AgentLeaderboardImpl.fromJson;

  @override
  DateTime? get from;
  @override
  DateTime? get to;
  @override
  String? get currency;
  @override
  List<LeaderboardRow> get agents;
  @override
  List<LeaderboardRow> get inactive;
  @override
  LeaderboardRow? get totals;

  /// Create a copy of AgentLeaderboard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentLeaderboardImplCopyWith<_$AgentLeaderboardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardRow _$LeaderboardRowFromJson(Map<String, dynamic> json) {
  return _LeaderboardRow.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardRow {
  int? get rank => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  int get dealsWon => throw _privateConstructorUsedError;
  int get dealsLost => throw _privateConstructorUsedError;
  double get wonValue => throw _privateConstructorUsedError;
  double get commission => throw _privateConstructorUsedError;
  int get viewingsHeld => throw _privateConstructorUsedError;
  int get newClients => throw _privateConstructorUsedError;
  double? get winRate => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardRowCopyWith<LeaderboardRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardRowCopyWith<$Res> {
  factory $LeaderboardRowCopyWith(
          LeaderboardRow value, $Res Function(LeaderboardRow) then) =
      _$LeaderboardRowCopyWithImpl<$Res, LeaderboardRow>;
  @useResult
  $Res call(
      {int? rank,
      int? agentId,
      String fullName,
      String? role,
      int dealsWon,
      int dealsLost,
      double wonValue,
      double commission,
      int viewingsHeld,
      int newClients,
      double? winRate});
}

/// @nodoc
class _$LeaderboardRowCopyWithImpl<$Res, $Val extends LeaderboardRow>
    implements $LeaderboardRowCopyWith<$Res> {
  _$LeaderboardRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = freezed,
    Object? agentId = freezed,
    Object? fullName = null,
    Object? role = freezed,
    Object? dealsWon = null,
    Object? dealsLost = null,
    Object? wonValue = null,
    Object? commission = null,
    Object? viewingsHeld = null,
    Object? newClients = null,
    Object? winRate = freezed,
  }) {
    return _then(_value.copyWith(
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      dealsWon: null == dealsWon
          ? _value.dealsWon
          : dealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      dealsLost: null == dealsLost
          ? _value.dealsLost
          : dealsLost // ignore: cast_nullable_to_non_nullable
              as int,
      wonValue: null == wonValue
          ? _value.wonValue
          : wonValue // ignore: cast_nullable_to_non_nullable
              as double,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      viewingsHeld: null == viewingsHeld
          ? _value.viewingsHeld
          : viewingsHeld // ignore: cast_nullable_to_non_nullable
              as int,
      newClients: null == newClients
          ? _value.newClients
          : newClients // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: freezed == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaderboardRowImplCopyWith<$Res>
    implements $LeaderboardRowCopyWith<$Res> {
  factory _$$LeaderboardRowImplCopyWith(_$LeaderboardRowImpl value,
          $Res Function(_$LeaderboardRowImpl) then) =
      __$$LeaderboardRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? rank,
      int? agentId,
      String fullName,
      String? role,
      int dealsWon,
      int dealsLost,
      double wonValue,
      double commission,
      int viewingsHeld,
      int newClients,
      double? winRate});
}

/// @nodoc
class __$$LeaderboardRowImplCopyWithImpl<$Res>
    extends _$LeaderboardRowCopyWithImpl<$Res, _$LeaderboardRowImpl>
    implements _$$LeaderboardRowImplCopyWith<$Res> {
  __$$LeaderboardRowImplCopyWithImpl(
      _$LeaderboardRowImpl _value, $Res Function(_$LeaderboardRowImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaderboardRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = freezed,
    Object? agentId = freezed,
    Object? fullName = null,
    Object? role = freezed,
    Object? dealsWon = null,
    Object? dealsLost = null,
    Object? wonValue = null,
    Object? commission = null,
    Object? viewingsHeld = null,
    Object? newClients = null,
    Object? winRate = freezed,
  }) {
    return _then(_$LeaderboardRowImpl(
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      dealsWon: null == dealsWon
          ? _value.dealsWon
          : dealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      dealsLost: null == dealsLost
          ? _value.dealsLost
          : dealsLost // ignore: cast_nullable_to_non_nullable
              as int,
      wonValue: null == wonValue
          ? _value.wonValue
          : wonValue // ignore: cast_nullable_to_non_nullable
              as double,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      viewingsHeld: null == viewingsHeld
          ? _value.viewingsHeld
          : viewingsHeld // ignore: cast_nullable_to_non_nullable
              as int,
      newClients: null == newClients
          ? _value.newClients
          : newClients // ignore: cast_nullable_to_non_nullable
              as int,
      winRate: freezed == winRate
          ? _value.winRate
          : winRate // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardRowImpl implements _LeaderboardRow {
  const _$LeaderboardRowImpl(
      {this.rank,
      this.agentId,
      this.fullName = '',
      this.role,
      this.dealsWon = 0,
      this.dealsLost = 0,
      this.wonValue = 0,
      this.commission = 0,
      this.viewingsHeld = 0,
      this.newClients = 0,
      this.winRate});

  factory _$LeaderboardRowImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardRowImplFromJson(json);

  @override
  final int? rank;
  @override
  final int? agentId;
  @override
  @JsonKey()
  final String fullName;
  @override
  final String? role;
  @override
  @JsonKey()
  final int dealsWon;
  @override
  @JsonKey()
  final int dealsLost;
  @override
  @JsonKey()
  final double wonValue;
  @override
  @JsonKey()
  final double commission;
  @override
  @JsonKey()
  final int viewingsHeld;
  @override
  @JsonKey()
  final int newClients;
  @override
  final double? winRate;

  @override
  String toString() {
    return 'LeaderboardRow(rank: $rank, agentId: $agentId, fullName: $fullName, role: $role, dealsWon: $dealsWon, dealsLost: $dealsLost, wonValue: $wonValue, commission: $commission, viewingsHeld: $viewingsHeld, newClients: $newClients, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardRowImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.dealsWon, dealsWon) ||
                other.dealsWon == dealsWon) &&
            (identical(other.dealsLost, dealsLost) ||
                other.dealsLost == dealsLost) &&
            (identical(other.wonValue, wonValue) ||
                other.wonValue == wonValue) &&
            (identical(other.commission, commission) ||
                other.commission == commission) &&
            (identical(other.viewingsHeld, viewingsHeld) ||
                other.viewingsHeld == viewingsHeld) &&
            (identical(other.newClients, newClients) ||
                other.newClients == newClients) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      rank,
      agentId,
      fullName,
      role,
      dealsWon,
      dealsLost,
      wonValue,
      commission,
      viewingsHeld,
      newClients,
      winRate);

  /// Create a copy of LeaderboardRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardRowImplCopyWith<_$LeaderboardRowImpl> get copyWith =>
      __$$LeaderboardRowImplCopyWithImpl<_$LeaderboardRowImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardRowImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardRow implements LeaderboardRow {
  const factory _LeaderboardRow(
      {final int? rank,
      final int? agentId,
      final String fullName,
      final String? role,
      final int dealsWon,
      final int dealsLost,
      final double wonValue,
      final double commission,
      final int viewingsHeld,
      final int newClients,
      final double? winRate}) = _$LeaderboardRowImpl;

  factory _LeaderboardRow.fromJson(Map<String, dynamic> json) =
      _$LeaderboardRowImpl.fromJson;

  @override
  int? get rank;
  @override
  int? get agentId;
  @override
  String get fullName;
  @override
  String? get role;
  @override
  int get dealsWon;
  @override
  int get dealsLost;
  @override
  double get wonValue;
  @override
  double get commission;
  @override
  int get viewingsHeld;
  @override
  int get newClients;
  @override
  double? get winRate;

  /// Create a copy of LeaderboardRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardRowImplCopyWith<_$LeaderboardRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) {
  return _AppNotification.fromJson(json);
}

/// @nodoc
mixin _$AppNotification {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  NotificationType get type => throw _privateConstructorUsedError;
  int? get targetId => throw _privateConstructorUsedError;
  Map<String, dynamic> get params => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNotificationCopyWith<AppNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotificationCopyWith<$Res> {
  factory $AppNotificationCopyWith(
          AppNotification value, $Res Function(AppNotification) then) =
      _$AppNotificationCopyWithImpl<$Res, AppNotification>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: NotificationType.unknown)
      NotificationType type,
      int? targetId,
      Map<String, dynamic> params,
      DateTime? readAt,
      DateTime createdAt});
}

/// @nodoc
class _$AppNotificationCopyWithImpl<$Res, $Val extends AppNotification>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? targetId = freezed,
    Object? params = null,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as int?,
      params: null == params
          ? _value.params
          : params // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppNotificationImplCopyWith<$Res>
    implements $AppNotificationCopyWith<$Res> {
  factory _$$AppNotificationImplCopyWith(_$AppNotificationImpl value,
          $Res Function(_$AppNotificationImpl) then) =
      __$$AppNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: NotificationType.unknown)
      NotificationType type,
      int? targetId,
      Map<String, dynamic> params,
      DateTime? readAt,
      DateTime createdAt});
}

/// @nodoc
class __$$AppNotificationImplCopyWithImpl<$Res>
    extends _$AppNotificationCopyWithImpl<$Res, _$AppNotificationImpl>
    implements _$$AppNotificationImplCopyWith<$Res> {
  __$$AppNotificationImplCopyWithImpl(
      _$AppNotificationImpl _value, $Res Function(_$AppNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? targetId = freezed,
    Object? params = null,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AppNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      targetId: freezed == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as int?,
      params: null == params
          ? _value._params
          : params // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppNotificationImpl extends _AppNotification {
  const _$AppNotificationImpl(
      {required this.id,
      @JsonKey(unknownEnumValue: NotificationType.unknown)
      this.type = NotificationType.unknown,
      this.targetId,
      final Map<String, dynamic> params = const <String, dynamic>{},
      this.readAt,
      required this.createdAt})
      : _params = params,
        super._();

  factory _$AppNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppNotificationImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  final NotificationType type;
  @override
  final int? targetId;
  final Map<String, dynamic> _params;
  @override
  @JsonKey()
  Map<String, dynamic> get params {
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_params);
  }

  @override
  final DateTime? readAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, targetId: $targetId, params: $params, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            const DeepCollectionEquality().equals(other._params, _params) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, targetId,
      const DeepCollectionEquality().hash(_params), readAt, createdAt);

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      __$$AppNotificationImplCopyWithImpl<_$AppNotificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppNotificationImplToJson(
      this,
    );
  }
}

abstract class _AppNotification extends AppNotification {
  const factory _AppNotification(
      {required final int id,
      @JsonKey(unknownEnumValue: NotificationType.unknown)
      final NotificationType type,
      final int? targetId,
      final Map<String, dynamic> params,
      final DateTime? readAt,
      required final DateTime createdAt}) = _$AppNotificationImpl;
  const _AppNotification._() : super._();

  factory _AppNotification.fromJson(Map<String, dynamic> json) =
      _$AppNotificationImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(unknownEnumValue: NotificationType.unknown)
  NotificationType get type;
  @override
  int? get targetId;
  @override
  Map<String, dynamic> get params;
  @override
  DateTime? get readAt;
  @override
  DateTime get createdAt;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DealDeposit _$DealDepositFromJson(Map<String, dynamic> json) {
  return _DealDeposit.fromJson(json);
}

/// @nodoc
mixin _$DealDeposit {
  int get id => throw _privateConstructorUsedError;
  int get dealId => throw _privateConstructorUsedError;
  String get dealTitle => throw _privateConstructorUsedError;
  int? get clientId => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  int? get propertyId => throw _privateConstructorUsedError;
  String? get propertyTitle => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get receivedOn => throw _privateConstructorUsedError;
  DateTime get holdUntil => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
  DepositHolder get holder => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DepositOutcome? get outcome => throw _privateConstructorUsedError;
  DateTime? get closedOn => throw _privateConstructorUsedError;

  /// Serializes this DealDeposit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DealDeposit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealDepositCopyWith<DealDeposit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealDepositCopyWith<$Res> {
  factory $DealDepositCopyWith(
          DealDeposit value, $Res Function(DealDeposit) then) =
      _$DealDepositCopyWithImpl<$Res, DealDeposit>;
  @useResult
  $Res call(
      {int id,
      int dealId,
      String dealTitle,
      int? clientId,
      String? clientName,
      int? propertyId,
      String? propertyTitle,
      int? agentId,
      String? agentName,
      double amount,
      DateTime receivedOn,
      DateTime holdUntil,
      @JsonKey(unknownEnumValue: DepositHolder.AGENCY) DepositHolder holder,
      String? note,
      bool active,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DepositOutcome? outcome,
      DateTime? closedOn});
}

/// @nodoc
class _$DealDepositCopyWithImpl<$Res, $Val extends DealDeposit>
    implements $DealDepositCopyWith<$Res> {
  _$DealDepositCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DealDeposit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? dealTitle = null,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? amount = null,
    Object? receivedOn = null,
    Object? holdUntil = null,
    Object? holder = null,
    Object? note = freezed,
    Object? active = null,
    Object? outcome = freezed,
    Object? closedOn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int,
      dealTitle: null == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      receivedOn: null == receivedOn
          ? _value.receivedOn
          : receivedOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holdUntil: null == holdUntil
          ? _value.holdUntil
          : holdUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holder: null == holder
          ? _value.holder
          : holder // ignore: cast_nullable_to_non_nullable
              as DepositHolder,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      outcome: freezed == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as DepositOutcome?,
      closedOn: freezed == closedOn
          ? _value.closedOn
          : closedOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealDepositImplCopyWith<$Res>
    implements $DealDepositCopyWith<$Res> {
  factory _$$DealDepositImplCopyWith(
          _$DealDepositImpl value, $Res Function(_$DealDepositImpl) then) =
      __$$DealDepositImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int dealId,
      String dealTitle,
      int? clientId,
      String? clientName,
      int? propertyId,
      String? propertyTitle,
      int? agentId,
      String? agentName,
      double amount,
      DateTime receivedOn,
      DateTime holdUntil,
      @JsonKey(unknownEnumValue: DepositHolder.AGENCY) DepositHolder holder,
      String? note,
      bool active,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      DepositOutcome? outcome,
      DateTime? closedOn});
}

/// @nodoc
class __$$DealDepositImplCopyWithImpl<$Res>
    extends _$DealDepositCopyWithImpl<$Res, _$DealDepositImpl>
    implements _$$DealDepositImplCopyWith<$Res> {
  __$$DealDepositImplCopyWithImpl(
      _$DealDepositImpl _value, $Res Function(_$DealDepositImpl) _then)
      : super(_value, _then);

  /// Create a copy of DealDeposit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? dealTitle = null,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? propertyId = freezed,
    Object? propertyTitle = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? amount = null,
    Object? receivedOn = null,
    Object? holdUntil = null,
    Object? holder = null,
    Object? note = freezed,
    Object? active = null,
    Object? outcome = freezed,
    Object? closedOn = freezed,
  }) {
    return _then(_$DealDepositImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as int,
      dealTitle: null == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyId: freezed == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int?,
      propertyTitle: freezed == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      receivedOn: null == receivedOn
          ? _value.receivedOn
          : receivedOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holdUntil: null == holdUntil
          ? _value.holdUntil
          : holdUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      holder: null == holder
          ? _value.holder
          : holder // ignore: cast_nullable_to_non_nullable
              as DepositHolder,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      outcome: freezed == outcome
          ? _value.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as DepositOutcome?,
      closedOn: freezed == closedOn
          ? _value.closedOn
          : closedOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealDepositImpl implements _DealDeposit {
  const _$DealDepositImpl(
      {required this.id,
      required this.dealId,
      this.dealTitle = '',
      this.clientId,
      this.clientName,
      this.propertyId,
      this.propertyTitle,
      this.agentId,
      this.agentName,
      this.amount = 0.0,
      required this.receivedOn,
      required this.holdUntil,
      @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
      this.holder = DepositHolder.AGENCY,
      this.note,
      this.active = true,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.outcome,
      this.closedOn});

  factory _$DealDepositImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealDepositImplFromJson(json);

  @override
  final int id;
  @override
  final int dealId;
  @override
  @JsonKey()
  final String dealTitle;
  @override
  final int? clientId;
  @override
  final String? clientName;
  @override
  final int? propertyId;
  @override
  final String? propertyTitle;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  @JsonKey()
  final double amount;
  @override
  final DateTime receivedOn;
  @override
  final DateTime holdUntil;
  @override
  @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
  final DepositHolder holder;
  @override
  final String? note;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final DepositOutcome? outcome;
  @override
  final DateTime? closedOn;

  @override
  String toString() {
    return 'DealDeposit(id: $id, dealId: $dealId, dealTitle: $dealTitle, clientId: $clientId, clientName: $clientName, propertyId: $propertyId, propertyTitle: $propertyTitle, agentId: $agentId, agentName: $agentName, amount: $amount, receivedOn: $receivedOn, holdUntil: $holdUntil, holder: $holder, note: $note, active: $active, outcome: $outcome, closedOn: $closedOn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealDepositImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.receivedOn, receivedOn) ||
                other.receivedOn == receivedOn) &&
            (identical(other.holdUntil, holdUntil) ||
                other.holdUntil == holdUntil) &&
            (identical(other.holder, holder) || other.holder == holder) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.closedOn, closedOn) ||
                other.closedOn == closedOn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      dealId,
      dealTitle,
      clientId,
      clientName,
      propertyId,
      propertyTitle,
      agentId,
      agentName,
      amount,
      receivedOn,
      holdUntil,
      holder,
      note,
      active,
      outcome,
      closedOn);

  /// Create a copy of DealDeposit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealDepositImplCopyWith<_$DealDepositImpl> get copyWith =>
      __$$DealDepositImplCopyWithImpl<_$DealDepositImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealDepositImplToJson(
      this,
    );
  }
}

abstract class _DealDeposit implements DealDeposit {
  const factory _DealDeposit(
      {required final int id,
      required final int dealId,
      final String dealTitle,
      final int? clientId,
      final String? clientName,
      final int? propertyId,
      final String? propertyTitle,
      final int? agentId,
      final String? agentName,
      final double amount,
      required final DateTime receivedOn,
      required final DateTime holdUntil,
      @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
      final DepositHolder holder,
      final String? note,
      final bool active,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final DepositOutcome? outcome,
      final DateTime? closedOn}) = _$DealDepositImpl;

  factory _DealDeposit.fromJson(Map<String, dynamic> json) =
      _$DealDepositImpl.fromJson;

  @override
  int get id;
  @override
  int get dealId;
  @override
  String get dealTitle;
  @override
  int? get clientId;
  @override
  String? get clientName;
  @override
  int? get propertyId;
  @override
  String? get propertyTitle;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  double get amount;
  @override
  DateTime get receivedOn;
  @override
  DateTime get holdUntil;
  @override
  @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
  DepositHolder get holder;
  @override
  String? get note;
  @override
  bool get active;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  DepositOutcome? get outcome;
  @override
  DateTime? get closedOn;

  /// Create a copy of DealDeposit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealDepositImplCopyWith<_$DealDepositImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OpenHouse _$OpenHouseFromJson(Map<String, dynamic> json) {
  return _OpenHouse.fromJson(json);
}

/// @nodoc
mixin _$OpenHouse {
  int get id => throw _privateConstructorUsedError;
  int get propertyId => throw _privateConstructorUsedError;
  String get propertyTitle => throw _privateConstructorUsedError;
  String? get propertyAddress => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  DateTime get startsAt => throw _privateConstructorUsedError;
  DateTime get endsAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int get visitorCount => throw _privateConstructorUsedError;
  int get newClientCount => throw _privateConstructorUsedError;
  int get interestedCount => throw _privateConstructorUsedError;

  /// Whether the signed-in user may move or cancel it.
  bool get canEdit => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<OpenHouseVisitor> get visitors => throw _privateConstructorUsedError;

  /// Serializes this OpenHouse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OpenHouse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenHouseCopyWith<OpenHouse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenHouseCopyWith<$Res> {
  factory $OpenHouseCopyWith(OpenHouse value, $Res Function(OpenHouse) then) =
      _$OpenHouseCopyWithImpl<$Res, OpenHouse>;
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String propertyTitle,
      String? propertyAddress,
      int? agentId,
      String? agentName,
      DateTime startsAt,
      DateTime endsAt,
      String? note,
      int visitorCount,
      int newClientCount,
      int interestedCount,
      bool canEdit,
      DateTime? createdAt,
      List<OpenHouseVisitor> visitors});
}

/// @nodoc
class _$OpenHouseCopyWithImpl<$Res, $Val extends OpenHouse>
    implements $OpenHouseCopyWith<$Res> {
  _$OpenHouseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenHouse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? propertyTitle = null,
    Object? propertyAddress = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? note = freezed,
    Object? visitorCount = null,
    Object? newClientCount = null,
    Object? interestedCount = null,
    Object? canEdit = null,
    Object? createdAt = freezed,
    Object? visitors = null,
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
      propertyTitle: null == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      visitorCount: null == visitorCount
          ? _value.visitorCount
          : visitorCount // ignore: cast_nullable_to_non_nullable
              as int,
      newClientCount: null == newClientCount
          ? _value.newClientCount
          : newClientCount // ignore: cast_nullable_to_non_nullable
              as int,
      interestedCount: null == interestedCount
          ? _value.interestedCount
          : interestedCount // ignore: cast_nullable_to_non_nullable
              as int,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitors: null == visitors
          ? _value.visitors
          : visitors // ignore: cast_nullable_to_non_nullable
              as List<OpenHouseVisitor>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OpenHouseImplCopyWith<$Res>
    implements $OpenHouseCopyWith<$Res> {
  factory _$$OpenHouseImplCopyWith(
          _$OpenHouseImpl value, $Res Function(_$OpenHouseImpl) then) =
      __$$OpenHouseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String propertyTitle,
      String? propertyAddress,
      int? agentId,
      String? agentName,
      DateTime startsAt,
      DateTime endsAt,
      String? note,
      int visitorCount,
      int newClientCount,
      int interestedCount,
      bool canEdit,
      DateTime? createdAt,
      List<OpenHouseVisitor> visitors});
}

/// @nodoc
class __$$OpenHouseImplCopyWithImpl<$Res>
    extends _$OpenHouseCopyWithImpl<$Res, _$OpenHouseImpl>
    implements _$$OpenHouseImplCopyWith<$Res> {
  __$$OpenHouseImplCopyWithImpl(
      _$OpenHouseImpl _value, $Res Function(_$OpenHouseImpl) _then)
      : super(_value, _then);

  /// Create a copy of OpenHouse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? propertyTitle = null,
    Object? propertyAddress = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? note = freezed,
    Object? visitorCount = null,
    Object? newClientCount = null,
    Object? interestedCount = null,
    Object? canEdit = null,
    Object? createdAt = freezed,
    Object? visitors = null,
  }) {
    return _then(_$OpenHouseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      propertyTitle: null == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      visitorCount: null == visitorCount
          ? _value.visitorCount
          : visitorCount // ignore: cast_nullable_to_non_nullable
              as int,
      newClientCount: null == newClientCount
          ? _value.newClientCount
          : newClientCount // ignore: cast_nullable_to_non_nullable
              as int,
      interestedCount: null == interestedCount
          ? _value.interestedCount
          : interestedCount // ignore: cast_nullable_to_non_nullable
              as int,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitors: null == visitors
          ? _value._visitors
          : visitors // ignore: cast_nullable_to_non_nullable
              as List<OpenHouseVisitor>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OpenHouseImpl extends _OpenHouse {
  const _$OpenHouseImpl(
      {required this.id,
      required this.propertyId,
      this.propertyTitle = '',
      this.propertyAddress,
      this.agentId,
      this.agentName,
      required this.startsAt,
      required this.endsAt,
      this.note,
      this.visitorCount = 0,
      this.newClientCount = 0,
      this.interestedCount = 0,
      this.canEdit = false,
      this.createdAt,
      final List<OpenHouseVisitor> visitors = const <OpenHouseVisitor>[]})
      : _visitors = visitors,
        super._();

  factory _$OpenHouseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OpenHouseImplFromJson(json);

  @override
  final int id;
  @override
  final int propertyId;
  @override
  @JsonKey()
  final String propertyTitle;
  @override
  final String? propertyAddress;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final String? note;
  @override
  @JsonKey()
  final int visitorCount;
  @override
  @JsonKey()
  final int newClientCount;
  @override
  @JsonKey()
  final int interestedCount;

  /// Whether the signed-in user may move or cancel it.
  @override
  @JsonKey()
  final bool canEdit;
  @override
  final DateTime? createdAt;
  final List<OpenHouseVisitor> _visitors;
  @override
  @JsonKey()
  List<OpenHouseVisitor> get visitors {
    if (_visitors is EqualUnmodifiableListView) return _visitors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visitors);
  }

  @override
  String toString() {
    return 'OpenHouse(id: $id, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, agentId: $agentId, agentName: $agentName, startsAt: $startsAt, endsAt: $endsAt, note: $note, visitorCount: $visitorCount, newClientCount: $newClientCount, interestedCount: $interestedCount, canEdit: $canEdit, createdAt: $createdAt, visitors: $visitors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenHouseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.propertyAddress, propertyAddress) ||
                other.propertyAddress == propertyAddress) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.visitorCount, visitorCount) ||
                other.visitorCount == visitorCount) &&
            (identical(other.newClientCount, newClientCount) ||
                other.newClientCount == newClientCount) &&
            (identical(other.interestedCount, interestedCount) ||
                other.interestedCount == interestedCount) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._visitors, _visitors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      propertyId,
      propertyTitle,
      propertyAddress,
      agentId,
      agentName,
      startsAt,
      endsAt,
      note,
      visitorCount,
      newClientCount,
      interestedCount,
      canEdit,
      createdAt,
      const DeepCollectionEquality().hash(_visitors));

  /// Create a copy of OpenHouse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenHouseImplCopyWith<_$OpenHouseImpl> get copyWith =>
      __$$OpenHouseImplCopyWithImpl<_$OpenHouseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OpenHouseImplToJson(
      this,
    );
  }
}

abstract class _OpenHouse extends OpenHouse {
  const factory _OpenHouse(
      {required final int id,
      required final int propertyId,
      final String propertyTitle,
      final String? propertyAddress,
      final int? agentId,
      final String? agentName,
      required final DateTime startsAt,
      required final DateTime endsAt,
      final String? note,
      final int visitorCount,
      final int newClientCount,
      final int interestedCount,
      final bool canEdit,
      final DateTime? createdAt,
      final List<OpenHouseVisitor> visitors}) = _$OpenHouseImpl;
  const _OpenHouse._() : super._();

  factory _OpenHouse.fromJson(Map<String, dynamic> json) =
      _$OpenHouseImpl.fromJson;

  @override
  int get id;
  @override
  int get propertyId;
  @override
  String get propertyTitle;
  @override
  String? get propertyAddress;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  DateTime get startsAt;
  @override
  DateTime get endsAt;
  @override
  String? get note;
  @override
  int get visitorCount;
  @override
  int get newClientCount;
  @override
  int get interestedCount;

  /// Whether the signed-in user may move or cancel it.
  @override
  bool get canEdit;
  @override
  DateTime? get createdAt;
  @override
  List<OpenHouseVisitor> get visitors;

  /// Create a copy of OpenHouse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenHouseImplCopyWith<_$OpenHouseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OpenHouseVisitor _$OpenHouseVisitorFromJson(Map<String, dynamic> json) {
  return _OpenHouseVisitor.fromJson(json);
}

/// @nodoc
mixin _$OpenHouseVisitor {
  int get id => throw _privateConstructorUsedError;
  int get openHouseId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OpenHouseInterest? get interest => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int? get clientId => throw _privateConstructorUsedError;

  /// Whether the signed-in user may open the client card; a colleague's
  /// client, on an own-records scope, is named by [clientAgentName] only.
  bool get clientVisible => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  String? get clientAgentName => throw _privateConstructorUsedError;

  /// Whether this sign-in made the client rather than finding one.
  bool get newClient => throw _privateConstructorUsedError;
  int? get signedInById => throw _privateConstructorUsedError;
  String? get signedInByName => throw _privateConstructorUsedError;
  DateTime? get signedInAt => throw _privateConstructorUsedError;
  bool get canRemove => throw _privateConstructorUsedError;

  /// Serializes this OpenHouseVisitor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OpenHouseVisitor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenHouseVisitorCopyWith<OpenHouseVisitor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenHouseVisitorCopyWith<$Res> {
  factory $OpenHouseVisitorCopyWith(
          OpenHouseVisitor value, $Res Function(OpenHouseVisitor) then) =
      _$OpenHouseVisitorCopyWithImpl<$Res, OpenHouseVisitor>;
  @useResult
  $Res call(
      {int id,
      int openHouseId,
      String fullName,
      String phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OpenHouseInterest? interest,
      String? note,
      int? clientId,
      bool clientVisible,
      String? clientName,
      String? clientAgentName,
      bool newClient,
      int? signedInById,
      String? signedInByName,
      DateTime? signedInAt,
      bool canRemove});
}

/// @nodoc
class _$OpenHouseVisitorCopyWithImpl<$Res, $Val extends OpenHouseVisitor>
    implements $OpenHouseVisitorCopyWith<$Res> {
  _$OpenHouseVisitorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenHouseVisitor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? openHouseId = null,
    Object? fullName = null,
    Object? phone = null,
    Object? interest = freezed,
    Object? note = freezed,
    Object? clientId = freezed,
    Object? clientVisible = null,
    Object? clientName = freezed,
    Object? clientAgentName = freezed,
    Object? newClient = null,
    Object? signedInById = freezed,
    Object? signedInByName = freezed,
    Object? signedInAt = freezed,
    Object? canRemove = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      openHouseId: null == openHouseId
          ? _value.openHouseId
          : openHouseId // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      interest: freezed == interest
          ? _value.interest
          : interest // ignore: cast_nullable_to_non_nullable
              as OpenHouseInterest?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientVisible: null == clientVisible
          ? _value.clientVisible
          : clientVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientAgentName: freezed == clientAgentName
          ? _value.clientAgentName
          : clientAgentName // ignore: cast_nullable_to_non_nullable
              as String?,
      newClient: null == newClient
          ? _value.newClient
          : newClient // ignore: cast_nullable_to_non_nullable
              as bool,
      signedInById: freezed == signedInById
          ? _value.signedInById
          : signedInById // ignore: cast_nullable_to_non_nullable
              as int?,
      signedInByName: freezed == signedInByName
          ? _value.signedInByName
          : signedInByName // ignore: cast_nullable_to_non_nullable
              as String?,
      signedInAt: freezed == signedInAt
          ? _value.signedInAt
          : signedInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canRemove: null == canRemove
          ? _value.canRemove
          : canRemove // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OpenHouseVisitorImplCopyWith<$Res>
    implements $OpenHouseVisitorCopyWith<$Res> {
  factory _$$OpenHouseVisitorImplCopyWith(_$OpenHouseVisitorImpl value,
          $Res Function(_$OpenHouseVisitorImpl) then) =
      __$$OpenHouseVisitorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int openHouseId,
      String fullName,
      String phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OpenHouseInterest? interest,
      String? note,
      int? clientId,
      bool clientVisible,
      String? clientName,
      String? clientAgentName,
      bool newClient,
      int? signedInById,
      String? signedInByName,
      DateTime? signedInAt,
      bool canRemove});
}

/// @nodoc
class __$$OpenHouseVisitorImplCopyWithImpl<$Res>
    extends _$OpenHouseVisitorCopyWithImpl<$Res, _$OpenHouseVisitorImpl>
    implements _$$OpenHouseVisitorImplCopyWith<$Res> {
  __$$OpenHouseVisitorImplCopyWithImpl(_$OpenHouseVisitorImpl _value,
      $Res Function(_$OpenHouseVisitorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OpenHouseVisitor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? openHouseId = null,
    Object? fullName = null,
    Object? phone = null,
    Object? interest = freezed,
    Object? note = freezed,
    Object? clientId = freezed,
    Object? clientVisible = null,
    Object? clientName = freezed,
    Object? clientAgentName = freezed,
    Object? newClient = null,
    Object? signedInById = freezed,
    Object? signedInByName = freezed,
    Object? signedInAt = freezed,
    Object? canRemove = null,
  }) {
    return _then(_$OpenHouseVisitorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      openHouseId: null == openHouseId
          ? _value.openHouseId
          : openHouseId // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      interest: freezed == interest
          ? _value.interest
          : interest // ignore: cast_nullable_to_non_nullable
              as OpenHouseInterest?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int?,
      clientVisible: null == clientVisible
          ? _value.clientVisible
          : clientVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientAgentName: freezed == clientAgentName
          ? _value.clientAgentName
          : clientAgentName // ignore: cast_nullable_to_non_nullable
              as String?,
      newClient: null == newClient
          ? _value.newClient
          : newClient // ignore: cast_nullable_to_non_nullable
              as bool,
      signedInById: freezed == signedInById
          ? _value.signedInById
          : signedInById // ignore: cast_nullable_to_non_nullable
              as int?,
      signedInByName: freezed == signedInByName
          ? _value.signedInByName
          : signedInByName // ignore: cast_nullable_to_non_nullable
              as String?,
      signedInAt: freezed == signedInAt
          ? _value.signedInAt
          : signedInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canRemove: null == canRemove
          ? _value.canRemove
          : canRemove // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OpenHouseVisitorImpl implements _OpenHouseVisitor {
  const _$OpenHouseVisitorImpl(
      {required this.id,
      required this.openHouseId,
      this.fullName = '',
      this.phone = '',
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      this.interest,
      this.note,
      this.clientId,
      this.clientVisible = false,
      this.clientName,
      this.clientAgentName,
      this.newClient = false,
      this.signedInById,
      this.signedInByName,
      this.signedInAt,
      this.canRemove = false});

  factory _$OpenHouseVisitorImpl.fromJson(Map<String, dynamic> json) =>
      _$$OpenHouseVisitorImplFromJson(json);

  @override
  final int id;
  @override
  final int openHouseId;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final OpenHouseInterest? interest;
  @override
  final String? note;
  @override
  final int? clientId;

  /// Whether the signed-in user may open the client card; a colleague's
  /// client, on an own-records scope, is named by [clientAgentName] only.
  @override
  @JsonKey()
  final bool clientVisible;
  @override
  final String? clientName;
  @override
  final String? clientAgentName;

  /// Whether this sign-in made the client rather than finding one.
  @override
  @JsonKey()
  final bool newClient;
  @override
  final int? signedInById;
  @override
  final String? signedInByName;
  @override
  final DateTime? signedInAt;
  @override
  @JsonKey()
  final bool canRemove;

  @override
  String toString() {
    return 'OpenHouseVisitor(id: $id, openHouseId: $openHouseId, fullName: $fullName, phone: $phone, interest: $interest, note: $note, clientId: $clientId, clientVisible: $clientVisible, clientName: $clientName, clientAgentName: $clientAgentName, newClient: $newClient, signedInById: $signedInById, signedInByName: $signedInByName, signedInAt: $signedInAt, canRemove: $canRemove)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenHouseVisitorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.openHouseId, openHouseId) ||
                other.openHouseId == openHouseId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.interest, interest) ||
                other.interest == interest) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientVisible, clientVisible) ||
                other.clientVisible == clientVisible) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.clientAgentName, clientAgentName) ||
                other.clientAgentName == clientAgentName) &&
            (identical(other.newClient, newClient) ||
                other.newClient == newClient) &&
            (identical(other.signedInById, signedInById) ||
                other.signedInById == signedInById) &&
            (identical(other.signedInByName, signedInByName) ||
                other.signedInByName == signedInByName) &&
            (identical(other.signedInAt, signedInAt) ||
                other.signedInAt == signedInAt) &&
            (identical(other.canRemove, canRemove) ||
                other.canRemove == canRemove));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      openHouseId,
      fullName,
      phone,
      interest,
      note,
      clientId,
      clientVisible,
      clientName,
      clientAgentName,
      newClient,
      signedInById,
      signedInByName,
      signedInAt,
      canRemove);

  /// Create a copy of OpenHouseVisitor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenHouseVisitorImplCopyWith<_$OpenHouseVisitorImpl> get copyWith =>
      __$$OpenHouseVisitorImplCopyWithImpl<_$OpenHouseVisitorImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OpenHouseVisitorImplToJson(
      this,
    );
  }
}

abstract class _OpenHouseVisitor implements OpenHouseVisitor {
  const factory _OpenHouseVisitor(
      {required final int id,
      required final int openHouseId,
      final String fullName,
      final String phone,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final OpenHouseInterest? interest,
      final String? note,
      final int? clientId,
      final bool clientVisible,
      final String? clientName,
      final String? clientAgentName,
      final bool newClient,
      final int? signedInById,
      final String? signedInByName,
      final DateTime? signedInAt,
      final bool canRemove}) = _$OpenHouseVisitorImpl;

  factory _OpenHouseVisitor.fromJson(Map<String, dynamic> json) =
      _$OpenHouseVisitorImpl.fromJson;

  @override
  int get id;
  @override
  int get openHouseId;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OpenHouseInterest? get interest;
  @override
  String? get note;
  @override
  int? get clientId;

  /// Whether the signed-in user may open the client card; a colleague's
  /// client, on an own-records scope, is named by [clientAgentName] only.
  @override
  bool get clientVisible;
  @override
  String? get clientName;
  @override
  String? get clientAgentName;

  /// Whether this sign-in made the client rather than finding one.
  @override
  bool get newClient;
  @override
  int? get signedInById;
  @override
  String? get signedInByName;
  @override
  DateTime? get signedInAt;
  @override
  bool get canRemove;

  /// Create a copy of OpenHouseVisitor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenHouseVisitorImplCopyWith<_$OpenHouseVisitorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyOffer _$PropertyOfferFromJson(Map<String, dynamic> json) {
  return _PropertyOffer.fromJson(json);
}

/// @nodoc
mixin _$PropertyOffer {
  int get id => throw _privateConstructorUsedError;
  int get propertyId => throw _privateConstructorUsedError;
  String get propertyTitle => throw _privateConstructorUsedError;
  String? get propertyAddress => throw _privateConstructorUsedError;
  double? get propertyPrice => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;

  /// Whether the signed-in user may open the buyer's card; a colleague's
  /// buyer, on an own-records scope, is named by [clientAgentName] only.
  bool get clientVisible => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  String? get clientAgentName => throw _privateConstructorUsedError;
  int? get agentId => throw _privateConstructorUsedError;
  String? get agentName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: OfferParty.buyer)
  OfferParty get lastParty => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime? get expiresOn => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: OfferStatus.isNew)
  OfferStatus get status => throw _privateConstructorUsedError;

  /// Another offer on the same listing is accepted while this one waits.
  bool get otherAccepted => throw _privateConstructorUsedError;

  /// Whether the signed-in user may counter, accept, reject or withdraw it.
  bool get canEdit => throw _privateConstructorUsedError;
  DateTime? get decidedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<OfferStep> get history => throw _privateConstructorUsedError;

  /// Serializes this PropertyOffer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyOfferCopyWith<PropertyOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyOfferCopyWith<$Res> {
  factory $PropertyOfferCopyWith(
          PropertyOffer value, $Res Function(PropertyOffer) then) =
      _$PropertyOfferCopyWithImpl<$Res, PropertyOffer>;
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String propertyTitle,
      String? propertyAddress,
      double? propertyPrice,
      int clientId,
      bool clientVisible,
      String? clientName,
      String? clientAgentName,
      int? agentId,
      String? agentName,
      double amount,
      @JsonKey(unknownEnumValue: OfferParty.buyer) OfferParty lastParty,
      String? note,
      DateTime? expiresOn,
      @JsonKey(unknownEnumValue: OfferStatus.isNew) OfferStatus status,
      bool otherAccepted,
      bool canEdit,
      DateTime? decidedAt,
      DateTime? createdAt,
      List<OfferStep> history});
}

/// @nodoc
class _$PropertyOfferCopyWithImpl<$Res, $Val extends PropertyOffer>
    implements $PropertyOfferCopyWith<$Res> {
  _$PropertyOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? propertyTitle = null,
    Object? propertyAddress = freezed,
    Object? propertyPrice = freezed,
    Object? clientId = null,
    Object? clientVisible = null,
    Object? clientName = freezed,
    Object? clientAgentName = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? amount = null,
    Object? lastParty = null,
    Object? note = freezed,
    Object? expiresOn = freezed,
    Object? status = null,
    Object? otherAccepted = null,
    Object? canEdit = null,
    Object? decidedAt = freezed,
    Object? createdAt = freezed,
    Object? history = null,
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
      propertyTitle: null == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyPrice: freezed == propertyPrice
          ? _value.propertyPrice
          : propertyPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientVisible: null == clientVisible
          ? _value.clientVisible
          : clientVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientAgentName: freezed == clientAgentName
          ? _value.clientAgentName
          : clientAgentName // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      lastParty: null == lastParty
          ? _value.lastParty
          : lastParty // ignore: cast_nullable_to_non_nullable
              as OfferParty,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresOn: freezed == expiresOn
          ? _value.expiresOn
          : expiresOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OfferStatus,
      otherAccepted: null == otherAccepted
          ? _value.otherAccepted
          : otherAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
      decidedAt: freezed == decidedAt
          ? _value.decidedAt
          : decidedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<OfferStep>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyOfferImplCopyWith<$Res>
    implements $PropertyOfferCopyWith<$Res> {
  factory _$$PropertyOfferImplCopyWith(
          _$PropertyOfferImpl value, $Res Function(_$PropertyOfferImpl) then) =
      __$$PropertyOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int propertyId,
      String propertyTitle,
      String? propertyAddress,
      double? propertyPrice,
      int clientId,
      bool clientVisible,
      String? clientName,
      String? clientAgentName,
      int? agentId,
      String? agentName,
      double amount,
      @JsonKey(unknownEnumValue: OfferParty.buyer) OfferParty lastParty,
      String? note,
      DateTime? expiresOn,
      @JsonKey(unknownEnumValue: OfferStatus.isNew) OfferStatus status,
      bool otherAccepted,
      bool canEdit,
      DateTime? decidedAt,
      DateTime? createdAt,
      List<OfferStep> history});
}

/// @nodoc
class __$$PropertyOfferImplCopyWithImpl<$Res>
    extends _$PropertyOfferCopyWithImpl<$Res, _$PropertyOfferImpl>
    implements _$$PropertyOfferImplCopyWith<$Res> {
  __$$PropertyOfferImplCopyWithImpl(
      _$PropertyOfferImpl _value, $Res Function(_$PropertyOfferImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? propertyTitle = null,
    Object? propertyAddress = freezed,
    Object? propertyPrice = freezed,
    Object? clientId = null,
    Object? clientVisible = null,
    Object? clientName = freezed,
    Object? clientAgentName = freezed,
    Object? agentId = freezed,
    Object? agentName = freezed,
    Object? amount = null,
    Object? lastParty = null,
    Object? note = freezed,
    Object? expiresOn = freezed,
    Object? status = null,
    Object? otherAccepted = null,
    Object? canEdit = null,
    Object? decidedAt = freezed,
    Object? createdAt = freezed,
    Object? history = null,
  }) {
    return _then(_$PropertyOfferImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      propertyId: null == propertyId
          ? _value.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as int,
      propertyTitle: null == propertyTitle
          ? _value.propertyTitle
          : propertyTitle // ignore: cast_nullable_to_non_nullable
              as String,
      propertyAddress: freezed == propertyAddress
          ? _value.propertyAddress
          : propertyAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyPrice: freezed == propertyPrice
          ? _value.propertyPrice
          : propertyPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      clientVisible: null == clientVisible
          ? _value.clientVisible
          : clientVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      clientAgentName: freezed == clientAgentName
          ? _value.clientAgentName
          : clientAgentName // ignore: cast_nullable_to_non_nullable
              as String?,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as int?,
      agentName: freezed == agentName
          ? _value.agentName
          : agentName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      lastParty: null == lastParty
          ? _value.lastParty
          : lastParty // ignore: cast_nullable_to_non_nullable
              as OfferParty,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresOn: freezed == expiresOn
          ? _value.expiresOn
          : expiresOn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OfferStatus,
      otherAccepted: null == otherAccepted
          ? _value.otherAccepted
          : otherAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
      decidedAt: freezed == decidedAt
          ? _value.decidedAt
          : decidedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<OfferStep>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyOfferImpl implements _PropertyOffer {
  const _$PropertyOfferImpl(
      {required this.id,
      required this.propertyId,
      this.propertyTitle = '',
      this.propertyAddress,
      this.propertyPrice,
      required this.clientId,
      this.clientVisible = false,
      this.clientName,
      this.clientAgentName,
      this.agentId,
      this.agentName,
      this.amount = 0.0,
      @JsonKey(unknownEnumValue: OfferParty.buyer)
      this.lastParty = OfferParty.buyer,
      this.note,
      this.expiresOn,
      @JsonKey(unknownEnumValue: OfferStatus.isNew)
      this.status = OfferStatus.isNew,
      this.otherAccepted = false,
      this.canEdit = false,
      this.decidedAt,
      this.createdAt,
      final List<OfferStep> history = const <OfferStep>[]})
      : _history = history;

  factory _$PropertyOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyOfferImplFromJson(json);

  @override
  final int id;
  @override
  final int propertyId;
  @override
  @JsonKey()
  final String propertyTitle;
  @override
  final String? propertyAddress;
  @override
  final double? propertyPrice;
  @override
  final int clientId;

  /// Whether the signed-in user may open the buyer's card; a colleague's
  /// buyer, on an own-records scope, is named by [clientAgentName] only.
  @override
  @JsonKey()
  final bool clientVisible;
  @override
  final String? clientName;
  @override
  final String? clientAgentName;
  @override
  final int? agentId;
  @override
  final String? agentName;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey(unknownEnumValue: OfferParty.buyer)
  final OfferParty lastParty;
  @override
  final String? note;
  @override
  final DateTime? expiresOn;
  @override
  @JsonKey(unknownEnumValue: OfferStatus.isNew)
  final OfferStatus status;

  /// Another offer on the same listing is accepted while this one waits.
  @override
  @JsonKey()
  final bool otherAccepted;

  /// Whether the signed-in user may counter, accept, reject or withdraw it.
  @override
  @JsonKey()
  final bool canEdit;
  @override
  final DateTime? decidedAt;
  @override
  final DateTime? createdAt;
  final List<OfferStep> _history;
  @override
  @JsonKey()
  List<OfferStep> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'PropertyOffer(id: $id, propertyId: $propertyId, propertyTitle: $propertyTitle, propertyAddress: $propertyAddress, propertyPrice: $propertyPrice, clientId: $clientId, clientVisible: $clientVisible, clientName: $clientName, clientAgentName: $clientAgentName, agentId: $agentId, agentName: $agentName, amount: $amount, lastParty: $lastParty, note: $note, expiresOn: $expiresOn, status: $status, otherAccepted: $otherAccepted, canEdit: $canEdit, decidedAt: $decidedAt, createdAt: $createdAt, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.propertyTitle, propertyTitle) ||
                other.propertyTitle == propertyTitle) &&
            (identical(other.propertyAddress, propertyAddress) ||
                other.propertyAddress == propertyAddress) &&
            (identical(other.propertyPrice, propertyPrice) ||
                other.propertyPrice == propertyPrice) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientVisible, clientVisible) ||
                other.clientVisible == clientVisible) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.clientAgentName, clientAgentName) ||
                other.clientAgentName == clientAgentName) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.lastParty, lastParty) ||
                other.lastParty == lastParty) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.expiresOn, expiresOn) ||
                other.expiresOn == expiresOn) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.otherAccepted, otherAccepted) ||
                other.otherAccepted == otherAccepted) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            (identical(other.decidedAt, decidedAt) ||
                other.decidedAt == decidedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        propertyId,
        propertyTitle,
        propertyAddress,
        propertyPrice,
        clientId,
        clientVisible,
        clientName,
        clientAgentName,
        agentId,
        agentName,
        amount,
        lastParty,
        note,
        expiresOn,
        status,
        otherAccepted,
        canEdit,
        decidedAt,
        createdAt,
        const DeepCollectionEquality().hash(_history)
      ]);

  /// Create a copy of PropertyOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyOfferImplCopyWith<_$PropertyOfferImpl> get copyWith =>
      __$$PropertyOfferImplCopyWithImpl<_$PropertyOfferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyOfferImplToJson(
      this,
    );
  }
}

abstract class _PropertyOffer implements PropertyOffer {
  const factory _PropertyOffer(
      {required final int id,
      required final int propertyId,
      final String propertyTitle,
      final String? propertyAddress,
      final double? propertyPrice,
      required final int clientId,
      final bool clientVisible,
      final String? clientName,
      final String? clientAgentName,
      final int? agentId,
      final String? agentName,
      final double amount,
      @JsonKey(unknownEnumValue: OfferParty.buyer) final OfferParty lastParty,
      final String? note,
      final DateTime? expiresOn,
      @JsonKey(unknownEnumValue: OfferStatus.isNew) final OfferStatus status,
      final bool otherAccepted,
      final bool canEdit,
      final DateTime? decidedAt,
      final DateTime? createdAt,
      final List<OfferStep> history}) = _$PropertyOfferImpl;

  factory _PropertyOffer.fromJson(Map<String, dynamic> json) =
      _$PropertyOfferImpl.fromJson;

  @override
  int get id;
  @override
  int get propertyId;
  @override
  String get propertyTitle;
  @override
  String? get propertyAddress;
  @override
  double? get propertyPrice;
  @override
  int get clientId;

  /// Whether the signed-in user may open the buyer's card; a colleague's
  /// buyer, on an own-records scope, is named by [clientAgentName] only.
  @override
  bool get clientVisible;
  @override
  String? get clientName;
  @override
  String? get clientAgentName;
  @override
  int? get agentId;
  @override
  String? get agentName;
  @override
  double get amount;
  @override
  @JsonKey(unknownEnumValue: OfferParty.buyer)
  OfferParty get lastParty;
  @override
  String? get note;
  @override
  DateTime? get expiresOn;
  @override
  @JsonKey(unknownEnumValue: OfferStatus.isNew)
  OfferStatus get status;

  /// Another offer on the same listing is accepted while this one waits.
  @override
  bool get otherAccepted;

  /// Whether the signed-in user may counter, accept, reject or withdraw it.
  @override
  bool get canEdit;
  @override
  DateTime? get decidedAt;
  @override
  DateTime? get createdAt;
  @override
  List<OfferStep> get history;

  /// Create a copy of PropertyOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyOfferImplCopyWith<_$PropertyOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OfferStep _$OfferStepFromJson(Map<String, dynamic> json) {
  return _OfferStep.fromJson(json);
}

/// @nodoc
mixin _$OfferStep {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OfferAction? get action => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OfferParty? get party => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int? get actorId => throw _privateConstructorUsedError;
  String? get actorName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OfferStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfferStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferStepCopyWith<OfferStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferStepCopyWith<$Res> {
  factory $OfferStepCopyWith(OfferStep value, $Res Function(OfferStep) then) =
      _$OfferStepCopyWithImpl<$Res, OfferStep>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OfferAction? action,
      double amount,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OfferParty? party,
      String? note,
      int? actorId,
      String? actorName,
      DateTime? createdAt});
}

/// @nodoc
class _$OfferStepCopyWithImpl<$Res, $Val extends OfferStep>
    implements $OfferStepCopyWith<$Res> {
  _$OfferStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = freezed,
    Object? amount = null,
    Object? party = freezed,
    Object? note = freezed,
    Object? actorId = freezed,
    Object? actorName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as OfferAction?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      party: freezed == party
          ? _value.party
          : party // ignore: cast_nullable_to_non_nullable
              as OfferParty?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      actorId: freezed == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as int?,
      actorName: freezed == actorName
          ? _value.actorName
          : actorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OfferStepImplCopyWith<$Res>
    implements $OfferStepCopyWith<$Res> {
  factory _$$OfferStepImplCopyWith(
          _$OfferStepImpl value, $Res Function(_$OfferStepImpl) then) =
      __$$OfferStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OfferAction? action,
      double amount,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      OfferParty? party,
      String? note,
      int? actorId,
      String? actorName,
      DateTime? createdAt});
}

/// @nodoc
class __$$OfferStepImplCopyWithImpl<$Res>
    extends _$OfferStepCopyWithImpl<$Res, _$OfferStepImpl>
    implements _$$OfferStepImplCopyWith<$Res> {
  __$$OfferStepImplCopyWithImpl(
      _$OfferStepImpl _value, $Res Function(_$OfferStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = freezed,
    Object? amount = null,
    Object? party = freezed,
    Object? note = freezed,
    Object? actorId = freezed,
    Object? actorName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$OfferStepImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as OfferAction?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      party: freezed == party
          ? _value.party
          : party // ignore: cast_nullable_to_non_nullable
              as OfferParty?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      actorId: freezed == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as int?,
      actorName: freezed == actorName
          ? _value.actorName
          : actorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferStepImpl implements _OfferStep {
  const _$OfferStepImpl(
      {required this.id,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.action,
      this.amount = 0.0,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.party,
      this.note,
      this.actorId,
      this.actorName,
      this.createdAt});

  factory _$OfferStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferStepImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final OfferAction? action;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final OfferParty? party;
  @override
  final String? note;
  @override
  final int? actorId;
  @override
  final String? actorName;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'OfferStep(id: $id, action: $action, amount: $amount, party: $party, note: $note, actorId: $actorId, actorName: $actorName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.party, party) || other.party == party) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.actorName, actorName) ||
                other.actorName == actorName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, action, amount, party, note,
      actorId, actorName, createdAt);

  /// Create a copy of OfferStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferStepImplCopyWith<_$OfferStepImpl> get copyWith =>
      __$$OfferStepImplCopyWithImpl<_$OfferStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferStepImplToJson(
      this,
    );
  }
}

abstract class _OfferStep implements OfferStep {
  const factory _OfferStep(
      {required final int id,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final OfferAction? action,
      final double amount,
      @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
      final OfferParty? party,
      final String? note,
      final int? actorId,
      final String? actorName,
      final DateTime? createdAt}) = _$OfferStepImpl;

  factory _OfferStep.fromJson(Map<String, dynamic> json) =
      _$OfferStepImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OfferAction? get action;
  @override
  double get amount;
  @override
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  OfferParty? get party;
  @override
  String? get note;
  @override
  int? get actorId;
  @override
  String? get actorName;
  @override
  DateTime? get createdAt;

  /// Create a copy of OfferStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferStepImplCopyWith<_$OfferStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
