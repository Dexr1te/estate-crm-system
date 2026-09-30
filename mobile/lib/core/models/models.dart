// ignore_for_file: invalid_annotation_target

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

/// The stages a deal checklist is organised by; a lost deal has nothing left
/// to collect, so it is not one of them.
// ignore: constant_identifier_names
enum ChecklistStage { LEAD, NEGOTIATION, CLOSED_WON }

enum DealLostReason {
  // ignore: constant_identifier_names
  PRICE,
  // ignore: constant_identifier_names
  CHOSE_ANOTHER,
  // ignore: constant_identifier_names
  FINANCING,
  // ignore: constant_identifier_names
  CHANGED_MIND,
  // ignore: constant_identifier_names
  NO_RESPONSE,
  // ignore: constant_identifier_names
  OTHER,
}

// ignore: constant_identifier_names
enum ViewingOutcome { INTERESTED, REJECTED, NO_SHOW }

// ignore: constant_identifier_names
enum ActivityType { CALL, MESSAGE, EMAIL, NOTE }

/// Where a client record came from. Unknown values read as [manual].
enum ClientSource {
  @JsonValue('MANUAL')
  manual,
  @JsonValue('IMPORT')
  imported,
  @JsonValue('PUBLIC_LINK')
  publicLink,
}

// ignore: constant_identifier_names
enum DuplicateMatch { PHONE, EMAIL, PHONE_AND_EMAIL }

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
    int? teamId,
    String? teamName,

    /// The team's currency (ISO 4217), or null with no team; see AppCurrency.
    String? teamCurrency,
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
    @JsonKey(unknownEnumValue: ClientSource.manual)
    @Default(ClientSource.manual)
    ClientSource source,
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
    @JsonKey(unknownEnumValue: ClientSource.manual)
    @Default(ClientSource.manual)
    ClientSource source,
    DateTime? createdAt,
  }) = _ClientListItem;

  factory ClientListItem.fromJson(Map<String, dynamic> json) =>
      _$ClientListItemFromJson(json);
}

@freezed
class ClientActivity with _$ClientActivity {
  const factory ClientActivity({
    required int id,
    required int clientId,
    @Default(ActivityType.NOTE) ActivityType type,
    String? note,
    required DateTime occurredAt,
    int? authorId,
    String? authorName,
    DateTime? createdAt,

    /// The listings this entry was about — what went out in a message.
    @Default(<ActivityProperty>[]) List<ActivityProperty> properties,
  }) = _ClientActivity;

  factory ClientActivity.fromJson(Map<String, dynamic> json) =>
      _$ClientActivityFromJson(json);
}

/// Just enough of a listing to name it in the history and open it.
@freezed
class ActivityProperty with _$ActivityProperty {
  const factory ActivityProperty({
    required int id,
    @Default('') String title,
  }) = _ActivityProperty;

  factory ActivityProperty.fromJson(Map<String, dynamic> json) =>
      _$ActivityPropertyFromJson(json);
}

/// Another card in the agency that looks like the same person — only what it
/// takes to find the colleague who holds it.
@freezed
class ClientDuplicate with _$ClientDuplicate {
  const factory ClientDuplicate({
    required int id,
    @Default('') String fullName,
    @Default(ClientType.BUYER) ClientType type,
    int? agentId,
    String? agentName,
    String? phone,
    String? email,
    @JsonKey(unknownEnumValue: DuplicateMatch.PHONE)
    @Default(DuplicateMatch.PHONE)
    DuplicateMatch matchedOn,

    /// Whether this person may open the card: an agent on their own clients
    /// learns who holds a colleague's buyer, not the file itself.
    @Default(true) bool visible,
  }) = _ClientDuplicate;

  factory ClientDuplicate.fromJson(Map<String, dynamic> json) =>
      _$ClientDuplicateFromJson(json);
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
    double? previousPrice,
    DateTime? priceChangedAt,

    /// Where it stands, in degrees; both null until an agent drops a pin.
    double? latitude,
    double? longitude,
  }) = _PropertyResponse;

  factory PropertyResponse.fromJson(Map<String, dynamic> json) =>
      _$PropertyResponseFromJson(json);
}

@freezed
class PropertyPriceChange with _$PropertyPriceChange {
  const factory PropertyPriceChange({
    required int id,
    int? propertyId,
    @Default(0.0) double oldPrice,
    @Default(0.0) double newPrice,
    int? changedById,
    String? changedByName,
    DateTime? changedAt,
  }) = _PropertyPriceChange;

  factory PropertyPriceChange.fromJson(Map<String, dynamic> json) =>
      _$PropertyPriceChangeFromJson(json);
}

// ignore: constant_identifier_names
enum PriceRoomsRule { EXACT, NEAR, ANY }

/// Price per square metre across one group of comparables; the figures are
/// null when the group is empty.
@freezed
class PriceInsightStats with _$PriceInsightStats {
  const factory PriceInsightStats({
    @Default(0) int count,
    double? medianPerSqm,
    double? p25PerSqm,
    double? p75PerSqm,
    int? medianDaysOnMarket,
  }) = _PriceInsightStats;

  factory PriceInsightStats.fromJson(Map<String, dynamic> json) =>
      _$PriceInsightStatsFromJson(json);
}

@freezed
class PriceInsightRange with _$PriceInsightRange {
  const factory PriceInsightRange({
    @Default(0.0) double low,
    @Default(0.0) double median,
    @Default(0.0) double high,
  }) = _PriceInsightRange;

  factory PriceInsightRange.fromJson(Map<String, dynamic> json) =>
      _$PriceInsightRangeFromJson(json);
}

/// Where a listing's own price per m² sits among the active comparables.
@freezed
class PriceInsightPosition with _$PriceInsightPosition {
  const factory PriceInsightPosition({
    @Default(0.0) double pricePerSqm,
    int? percentile,
    double? vsMedianPercent,
  }) = _PriceInsightPosition;

  factory PriceInsightPosition.fromJson(Map<String, dynamic> json) =>
      _$PriceInsightPositionFromJson(json);
}

@freezed
class PriceInsightCriteria with _$PriceInsightCriteria {
  const factory PriceInsightCriteria({
    String? city,
    PropertyType? type,
    int? rooms,
    double? areaSqm,
    @JsonKey(unknownEnumValue: PriceRoomsRule.ANY)
    @Default(PriceRoomsRule.ANY)
    PriceRoomsRule roomsRule,
    int? minRooms,
    int? maxRooms,
  }) = _PriceInsightCriteria;

  factory PriceInsightCriteria.fromJson(Map<String, dynamic> json) =>
      _$PriceInsightCriteriaFromJson(json);
}

/// One of the agency's own listings a price was compared against.
@freezed
class PriceComparable with _$PriceComparable {
  const factory PriceComparable({
    required int id,
    @Default('') String title,
    @Default(0.0) double price,
    double? areaSqm,
    @Default(0.0) double pricePerSqm,
    int? rooms,
    @Default(PropertyStatus.AVAILABLE) PropertyStatus status,
    @Default(false) bool sold,
  }) = _PriceComparable;

  factory PriceComparable.fromJson(Map<String, dynamic> json) =>
      _$PriceComparableFromJson(json);
}

/// Is this price right? The agency's own listings and sales, per m².
@freezed
class PriceInsight with _$PriceInsight {
  const factory PriceInsight({
    @Default(0) int count,
    @Default(true) bool lowConfidence,
    @Default(PriceInsightCriteria()) PriceInsightCriteria criteria,
    @Default(PriceInsightStats()) PriceInsightStats active,
    @Default(PriceInsightStats()) PriceInsightStats sold,
    PriceInsightRange? suggested,
    PriceInsightPosition? position,
    @Default(<PriceComparable>[]) List<PriceComparable> comparables,
  }) = _PriceInsight;

  factory PriceInsight.fromJson(Map<String, dynamic> json) =>
      _$PriceInsightFromJson(json);
}

/// A listing's public link. [url] is null while the listing has none.
@freezed
class PropertyShareLink with _$PropertyShareLink {
  const factory PropertyShareLink({
    String? url,
    @Default(0) int viewCount,
    DateTime? lastViewedAt,
    DateTime? createdAt,

    /// How many buyers left their details on the page through this link.
    @Default(0) int leadCount,
  }) = _PropertyShareLink;

  factory PropertyShareLink.fromJson(Map<String, dynamic> json) =>
      _$PropertyShareLinkFromJson(json);
}

/// A listing's viewings as the seller report counts them. [outcomes] is keyed
/// by the [ViewingOutcome] name, so one the app does not know yet still parses.
@freezed
class SellerReportViewings with _$SellerReportViewings {
  const SellerReportViewings._();

  const factory SellerReportViewings({
    @Default(0) int total,
    @Default(0) int held,
    @Default(0) int upcoming,
    @Default(<String, int>{}) Map<String, int> outcomes,
    @Default(0) int awaitingOutcome,
    DateTime? lastHeldAt,
    DateTime? nextAt,
  }) = _SellerReportViewings;

  int count(ViewingOutcome outcome) => outcomes[outcome.name] ?? 0;

  factory SellerReportViewings.fromJson(Map<String, dynamic> json) =>
      _$SellerReportViewingsFromJson(json);
}

@freezed
class SellerReportLink with _$SellerReportLink {
  const factory SellerReportLink({
    @Default(false) bool active,
    @Default(0) int views,
    @Default(0) int leads,
  }) = _SellerReportLink;

  factory SellerReportLink.fromJson(Map<String, dynamic> json) =>
      _$SellerReportLinkFromJson(json);
}

@freezed
class SellerReportPrice with _$SellerReportPrice {
  const factory SellerReportPrice({
    @Default(0.0) double current,
    @Default(0.0) double original,
    @Default(0.0) double change,
    double? changePercent,

    /// Oldest first.
    @Default(<PropertyPriceChange>[]) List<PropertyPriceChange> changes,
  }) = _SellerReportPrice;

  factory SellerReportPrice.fromJson(Map<String, dynamic> json) =>
      _$SellerReportPriceFromJson(json);
}

/// What the agency has done for one listing, for its owner. Counts only.
@freezed
class SellerReport with _$SellerReport {
  const factory SellerReport({
    required int propertyId,
    @Default('') String title,
    @Default('') String address,
    String? city,
    @Default(PropertyStatus.AVAILABLE) PropertyStatus status,
    DateTime? listedAt,
    @Default(0) int daysOnMarket,
    DateTime? soldAt,
    DateTime? generatedOn,
    @Default(SellerReportViewings()) SellerReportViewings viewings,
    @Default(SellerReportLink()) SellerReportLink publicLink,
    @Default(SellerReportPrice()) SellerReportPrice price,
    @Default(0) int matchingBuyers,
  }) = _SellerReport;

  factory SellerReport.fromJson(Map<String, dynamic> json) =>
      _$SellerReportFromJson(json);
}

@freezed
class PropertyMatch with _$PropertyMatch {
  const factory PropertyMatch({
    required PropertyResponse property,
    @Default(false) bool overBudget,
    DateTime? lastShownAt,

    /// When it last went out to this buyer in a logged message.
    DateTime? lastSentAt,
  }) = _PropertyMatch;

  factory PropertyMatch.fromJson(Map<String, dynamic> json) =>
      _$PropertyMatchFromJson(json);
}

@freezed
class PropertyPhoto with _$PropertyPhoto {
  const factory PropertyPhoto({
    required int id,
    required int propertyId,
    @Default('') String fileName,
    @Default('image/jpeg') String contentType,
    @Default(0) int fileSize,
    @Default(0) int sortOrder,
    @Default(false) bool hasThumbnail,
    int? uploadedById,
    DateTime? uploadedAt,
  }) = _PropertyPhoto;

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) =>
      _$PropertyPhotoFromJson(json);
}

@freezed
class ClientMatch with _$ClientMatch {
  const factory ClientMatch({
    required ClientResponse client,
    @Default(false) bool overBudget,
  }) = _ClientMatch;

  factory ClientMatch.fromJson(Map<String, dynamic> json) =>
      _$ClientMatchFromJson(json);
}

@freezed
class DealResponse with _$DealResponse {
  const factory DealResponse({
    required int id,
    @Default('') String title,
    @Default(DealStatus.LEAD) DealStatus status,
    double? dealPrice,
    double? budget,
    double? commissionPercent,
    double? commission,
    String? notes,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    DealLostReason? lostReason,
    String? lostNote,
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
    @Default(0) int commentCount,
    @Default(0) int checklistDone,
    @Default(0) int checklistTotal,
    @Default(0) int openRequired,
    @Default(<String, int>{}) Map<String, int> openRequiredByStage,
  }) = _DealResponse;

  factory DealResponse.fromJson(Map<String, dynamic> json) =>
      _$DealResponseFromJson(json);
}

/// One line of a deal's checklist, or of the agency's template — which leaves
/// the deal-only fields empty.
@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required int id,
    @JsonKey(unknownEnumValue: ChecklistStage.LEAD)
    @Default(ChecklistStage.LEAD)
    ChecklistStage stage,
    @Default('') String title,
    @Default(0) int position,
    @Default(false) bool required,
    @Default(false) bool custom,
    @Default(false) bool done,
    DateTime? doneAt,
    int? doneById,
    String? doneByName,
    int? documentId,
    String? documentName,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

/// One line in the discussion on a deal.
@freezed
class DealComment with _$DealComment {
  const factory DealComment({
    required int id,
    required int dealId,
    @Default('') String body,
    int? authorId,
    String? authorName,
    required DateTime createdAt,
    DateTime? editedAt,
    @Default(<CommentMention>[]) List<CommentMention> mentions,
  }) = _DealComment;

  factory DealComment.fromJson(Map<String, dynamic> json) =>
      _$DealCommentFromJson(json);
}

/// Somebody a comment @mentions: enough to highlight the name in the text.
@freezed
class CommentMention with _$CommentMention {
  const factory CommentMention({
    required int id,
    @Default('') String fullName,
  }) = _CommentMention;

  factory CommentMention.fromJson(Map<String, dynamic> json) =>
      _$CommentMentionFromJson(json);
}

/// A stretch of a deal's discussion, oldest first, and whether more is above.
@freezed
class DealCommentPage with _$DealCommentPage {
  const factory DealCommentPage({
    @Default(<DealComment>[]) List<DealComment> comments,
    @Default(false) bool hasEarlier,
  }) = _DealCommentPage;

  factory DealCommentPage.fromJson(Map<String, dynamic> json) =>
      _$DealCommentPageFromJson(json);
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
    int? propertyId,
    String? propertyTitle,
    String? propertyAddress,

    /// The listing's pin, when it has one; what a day's route is drawn from.
    double? propertyLatitude,
    double? propertyLongitude,
    ViewingOutcome? outcome,
    String? outcomeNote,
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
class TaskResponse with _$TaskResponse {
  const TaskResponse._();

  const factory TaskResponse({
    required int id,
    @Default('') String title,
    String? note,
    required DateTime dueAt,
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
    DateTime? updatedAt,
  }) = _TaskResponse;

  bool get isDone => completedAt != null;

  factory TaskResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseFromJson(json);
}

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    @Default(0) int totalDeals,
    @Default(0) int activeDeals,
    @Default(0) int closedDeals,
    @Default(0) int totalClients,
    @Default(0) int upcomingMeetings,
    @Default(0) double commissionThisMonth,
    @Default(0) int tasksDueToday,
    @Default(0) int tasksOverdue,
    @Default(0) int coldCount,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

/// Why a client going cold is still worth the call. Unknown values read as
/// [unknown] and are not shown.
enum ColdReasonCode {
  @JsonValue('OPEN_DEAL')
  openDeal,
  @JsonValue('MATCHES')
  matches,
  @JsonValue('NEW_LEAD')
  newLead,
  unknown,
}

/// What the call should be about.
enum ColdNextStep {
  @JsonValue('PUSH_DEAL')
  pushDeal,
  @JsonValue('SEND_MATCHES')
  sendMatches,
  @JsonValue('FIRST_CALL')
  firstCall,
  @JsonValue('CHECK_IN')
  checkIn,
}

@freezed
class ColdReason with _$ColdReason {
  const factory ColdReason({
    @JsonKey(unknownEnumValue: ColdReasonCode.unknown)
    @Default(ColdReasonCode.unknown)
    ColdReasonCode code,
    String? dealTitle,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    DealStatus? dealStatus,
    int? matchCount,
  }) = _ColdReason;

  factory ColdReason.fromJson(Map<String, dynamic> json) =>
      _$ColdReasonFromJson(json);
}

/// A client nobody has spoken to in a while — `GET /clients/cold`.
@freezed
class ColdClient with _$ColdClient {
  const ColdClient._();

  const factory ColdClient({
    required int id,
    @Default('') String fullName,
    String? phone,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    ClientType? type,
    int? agentId,
    String? agentName,
    DateTime? lastContactAt,
    @Default(0) int silentDays,
    @Default(<ColdReason>[]) List<ColdReason> reasons,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    ColdNextStep? nextStep,
  }) = _ColdClient;

  /// The reasons the app knows how to word, most valuable first.
  List<ColdReason> get knownReasons =>
      reasons.where((r) => r.code != ColdReasonCode.unknown).toList();

  factory ColdClient.fromJson(Map<String, dynamic> json) =>
      _$ColdClientFromJson(json);
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

@freezed
class DealFunnel with _$DealFunnel {
  const factory DealFunnel({
    DateTime? from,
    DateTime? to,
    @Default(0) int created,
    @Default(0) int reachedNegotiation,
    @Default(0) int won,
    @Default(0) int lost,
    double? leadToNegotiationRate,
    double? negotiationToWonRate,
    double? leadToWonRate,
    @Default(0) double wonValue,
    double? avgDaysToWin,
    @Default(<FunnelLostReason>[]) List<FunnelLostReason> lostReasons,
    @Default(<FunnelMonth>[]) List<FunnelMonth> monthly,
  }) = _DealFunnel;

  factory DealFunnel.fromJson(Map<String, dynamic> json) =>
      _$DealFunnelFromJson(json);
}

@freezed
class FunnelLostReason with _$FunnelLostReason {
  const factory FunnelLostReason({
    @Default('UNSPECIFIED') String reason,
    @Default(0) int count,
    @Default(0) double share,
  }) = _FunnelLostReason;

  factory FunnelLostReason.fromJson(Map<String, dynamic> json) =>
      _$FunnelLostReasonFromJson(json);
}

@freezed
class FunnelMonth with _$FunnelMonth {
  const factory FunnelMonth({
    required DateTime month,
    @Default(0) int created,
    @Default(0) int won,
    @Default(0) int lost,
  }) = _FunnelMonth;

  factory FunnelMonth.fromJson(Map<String, dynamic> json) =>
      _$FunnelMonthFromJson(json);
}

enum NotificationType {
  @JsonValue('TASK_ASSIGNED')
  taskAssigned,
  @JsonValue('RECORDS_HANDED_OVER')
  recordsHandedOver,
  @JsonValue('JOIN_REQUEST')
  joinRequest,
  @JsonValue('JOIN_ACCEPTED')
  joinAccepted,
  @JsonValue('NEW_MATCH')
  newMatch,
  @JsonValue('PRICE_DROP_MATCH')
  priceDropMatch,
  @JsonValue('DEAL_STATUS_CHANGED')
  dealStatusChanged,
  @JsonValue('LISTING_LEAD')
  listingLead,
  @JsonValue('DEAL_MENTION')
  dealMention,
  @JsonValue('DEAL_COMMENT')
  dealComment,
  unknown,
}

@freezed
class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required int id,
    @JsonKey(unknownEnumValue: NotificationType.unknown)
    @Default(NotificationType.unknown)
    NotificationType type,
    int? targetId,
    @Default(<String, dynamic>{}) Map<String, dynamic> params,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  bool get isRead => readAt != null;

  String? text(String key) {
    final value = params[key];
    return value == null ? null : '$value';
  }

  int count(String key) {
    final value = params[key];
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  double? amount(String key) {
    final value = params[key];
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}');
  }

  int? refId(String key) {
    final value = params[key];
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}');
  }

  List<String> names(String key) {
    final value = params[key];
    return value is List ? value.map((e) => '$e').toList() : const [];
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
