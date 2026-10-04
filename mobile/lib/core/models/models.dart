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

/// The seller's agreement with the agency on a listing. A listing with none
/// recorded has a null type, which is not the same as an open one.
// ignore: constant_identifier_names
enum MandateType { EXCLUSIVE, OPEN }

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

/// Whether a deal sells a place or lets it. Deals from before rents existed,
/// and any value this app does not know, read as [sale].
enum DealKind {
  @JsonValue('SALE')
  sale,
  @JsonValue('RENT')
  rent,
}

/// Where a client record came from. Unknown values read as [manual].
enum ClientSource {
  @JsonValue('MANUAL')
  manual,
  @JsonValue('IMPORT')
  imported,
  @JsonValue('PUBLIC_LINK')
  publicLink,
  @JsonValue('OPEN_HOUSE')
  openHouse,
}

/// How a client reached the agency: the channel, not how the card was
/// entered (that is [ClientSource]). Optional on a client.
// ignore: constant_identifier_names
enum LeadSource {
  // ignore: constant_identifier_names
  REFERRAL,
  // ignore: constant_identifier_names
  WEBSITE,
  // ignore: constant_identifier_names
  PORTAL,
  // ignore: constant_identifier_names
  SOCIAL,
  // ignore: constant_identifier_names
  WALK_IN,
  // ignore: constant_identifier_names
  COLD_CALL,
  // ignore: constant_identifier_names
  REPEAT,

  /// Sent by one of the agency's partners, named beside it on the client.
  // ignore: constant_identifier_names
  PARTNER,
  // ignore: constant_identifier_names
  OTHER,
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

    /// The agency's tags on this client, in name order.
    @Default(<String>[]) List<String> tags,

    /// How the client reached the agency; null when nobody recorded it.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    LeadSource? leadSource,
    String? leadSourceDetail,

    /// The partner who sent them, when [leadSource] is PARTNER.
    int? referredByPartnerId,
    String? referredByPartnerName,

    /// `1990-05-14`, or `--05-14` when the year is not known. Read it
    /// through `ClientBirthday.parse`.
    String? birthday,
  }) = _ClientResponse;

  factory ClientResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientResponseFromJson(json);
}

/// A tag of the agency and how many of its clients carry it — what the tag
/// editor suggests, the most used first.
@freezed
class ClientTagUsage with _$ClientTagUsage {
  const factory ClientTagUsage({
    required String name,
    @Default(0) int count,
  }) = _ClientTagUsage;

  factory ClientTagUsage.fromJson(Map<String, dynamic> json) =>
      _$ClientTagUsageFromJson(json);
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

    /// Set when the entry is a visit signed in at an open house.
    int? openHouseId,

    /// Set, both of them, on the line a manager's handover wrote: who held
    /// the client before and who holds it now. The from name is empty when
    /// nobody held it.
    String? handoverFromName,
    String? handoverToName,
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

    /// The seller's agreement; null when none is recorded. A kind this build
    /// does not know reads as none rather than failing the whole listing.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    MandateType? mandateType,

    /// Its last day (a date, no time); null when it has no end date.
    DateTime? mandateEndDate,

    /// The last day the listing is held for a buyer's deposit; null when no
    /// deal on it has an active deposit. While set, the listing is reserved.
    DateTime? depositHoldUntil,
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

    /// A rent has [monthlyRent] and a lease instead of a [dealPrice]; its
    /// commission is a percentage of one month's rent.
    @JsonKey(unknownEnumValue: DealKind.sale)
    @Default(DealKind.sale)
    DealKind kind,
    double? monthlyRent,
    DateTime? leaseStart,
    DateTime? leaseEnd,

    /// As saved; null means the default, which [leaseReminderDaysEffective]
    /// fills in.
    int? leaseReminderDays,
    int? leaseReminderDaysEffective,
    int? landlordId,
    String? landlordName,
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

/// One of the agency's message templates. [body] carries its placeholders
/// unfilled — `{client}`, `{agent}`, `{listing}`, `{price}`, `{address}`,
/// `{link}` — and the app fills them for the client in hand.
@freezed
class MessageTemplate with _$MessageTemplate {
  const factory MessageTemplate({
    required int id,
    @Default('') String title,
    @Default('') String body,
    DateTime? updatedAt,
  }) = _MessageTemplate;

  factory MessageTemplate.fromJson(Map<String, dynamic> json) =>
      _$MessageTemplateFromJson(json);
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

/// One person's month against their target, or the agency's when [agentId]
/// is null. The manager's target wins over the person's own ([source] says
/// whose counts); progress is counted on the server from the deals won that
/// calendar month, in the agency's currency.
@freezed
class GoalProgress with _$GoalProgress {
  const GoalProgress._();

  const factory GoalProgress({
    /// "2026-10".
    @Default('') String month,
    String? currency,
    int? agentId,
    String? agentName,

    /// MANAGER or PERSONAL; null while there is no target.
    String? source,
    double? commissionTarget,
    int? dealsTarget,

    /// The person's own target while the manager's overrides it.
    double? personalCommissionTarget,
    int? personalDealsTarget,
    @Default(0) double commissionAchieved,
    @Default(0) int dealsWon,
    int? commissionPercent,
    int? dealsPercent,
    @Default(0) int daysLeft,
    double? commissionPerDay,
    double? dealsPerDay,

    /// Whether the person may set their own: not while the manager's counts.
    @Default(false) bool personalEditable,
  }) = _GoalProgress;

  bool get hasTarget => commissionTarget != null || dealsTarget != null;
  bool get setByManager => source == 'MANAGER';

  factory GoalProgress.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressFromJson(json);
}

/// The manager's month: the agency's line and one per member, by name.
@freezed
class TeamGoals with _$TeamGoals {
  const factory TeamGoals({
    @Default('') String month,
    String? currency,
    @Default(0) int daysLeft,
    required GoalProgress agency,
    @Default(<GoalProgress>[]) List<GoalProgress> agents,

    /// How many targets a copy from last month brought; null otherwise.
    int? copied,
  }) = _TeamGoals;

  factory TeamGoals.fromJson(Map<String, dynamic> json) =>
      _$TeamGoalsFromJson(json);
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

/// A date that comes round every year. Unknown values read as [unknown] and
/// are not shown.
enum ClientDateKind {
  @JsonValue('BIRTHDAY')
  birthday,
  @JsonValue('PURCHASE_ANNIVERSARY')
  purchaseAnniversary,
  unknown,
}

/// A birthday or purchase anniversary coming up —
/// `GET /clients/upcoming-dates`.
@freezed
class UpcomingClientDate with _$UpcomingClientDate {
  const factory UpcomingClientDate({
    @JsonKey(unknownEnumValue: ClientDateKind.unknown)
    @Default(ClientDateKind.unknown)
    ClientDateKind kind,

    /// The day it falls on this time; 29 February is the 28th in a common
    /// year.
    required DateTime date,

    /// 0 today, 1 tomorrow.
    @Default(0) int daysAway,

    /// The age the client turns, or the years since the deal was won. Null
    /// for a birthday whose year is not known.
    int? years,
    required int clientId,
    @Default('') String clientName,
    String? phone,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    ClientType? clientType,
    int? agentId,
    String? agentName,
    int? dealId,
    String? dealTitle,
    String? propertyTitle,
  }) = _UpcomingClientDate;

  factory UpcomingClientDate.fromJson(Map<String, dynamic> json) =>
      _$UpcomingClientDateFromJson(json);
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

/// Clients created in a period by how they reached the agency, and how many
/// of each have a won deal.
@freezed
class LeadSourceBreakdown with _$LeadSourceBreakdown {
  const factory LeadSourceBreakdown({
    DateTime? from,
    DateTime? to,
    @Default(0) int clients,
    @Default(0) int won,
    @Default(<LeadSourceRow>[]) List<LeadSourceRow> sources,
  }) = _LeadSourceBreakdown;

  factory LeadSourceBreakdown.fromJson(Map<String, dynamic> json) =>
      _$LeadSourceBreakdownFromJson(json);
}

/// One channel: a [LeadSource] name, or `UNKNOWN` for clients with none.
@freezed
class LeadSourceRow with _$LeadSourceRow {
  const factory LeadSourceRow({
    @Default('UNKNOWN') String source,
    @Default(0) int clients,
    @Default(0) int won,
    @Default(0) double conversionRate,
  }) = _LeadSourceRow;

  factory LeadSourceRow.fromJson(Map<String, dynamic> json) =>
      _$LeadSourceRowFromJson(json);
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

/// How each person in one agency did over [from, to), for its manager.
/// [agents] are ranked by commission; [inactive] are members deactivated but
/// still in the agency, ranked apart.
@freezed
class AgentLeaderboard with _$AgentLeaderboard {
  const factory AgentLeaderboard({
    DateTime? from,
    DateTime? to,
    String? currency,
    @Default(<LeaderboardRow>[]) List<LeaderboardRow> agents,
    @Default(<LeaderboardRow>[]) List<LeaderboardRow> inactive,
    LeaderboardRow? totals,
  }) = _AgentLeaderboard;

  factory AgentLeaderboard.fromJson(Map<String, dynamic> json) =>
      _$AgentLeaderboardFromJson(json);
}

@freezed
class LeaderboardRow with _$LeaderboardRow {
  const factory LeaderboardRow({
    int? rank,
    int? agentId,
    @Default('') String fullName,
    String? role,
    @Default(0) int dealsWon,
    @Default(0) int dealsLost,
    @Default(0) double wonValue,
    @Default(0) double commission,
    @Default(0) int viewingsHeld,
    @Default(0) int newClients,
    double? winRate,
  }) = _LeaderboardRow;

  factory LeaderboardRow.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardRowFromJson(json);
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
  @JsonValue('CLIENT_BIRTHDAY')
  clientBirthday,
  @JsonValue('PURCHASE_ANNIVERSARY')
  purchaseAnniversary,
  @JsonValue('LEASE_ENDING')
  leaseEnding,
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

/// Who keeps a buyer's deposit while the deal is under way.
// ignore: constant_identifier_names
enum DepositHolder { AGENCY, SELLER, NOTARY }

/// How a deposit ended; a deposit without one is still active.
// ignore: constant_identifier_names
enum DepositOutcome { APPLIED, REFUNDED, FORFEITED }

/// Money a buyer put down on a deal, and how long the deal's listing is held
/// for them. [amount] is in the agency's currency.
@freezed
class DealDeposit with _$DealDeposit {
  const factory DealDeposit({
    required int id,
    required int dealId,
    @Default('') String dealTitle,
    int? clientId,
    String? clientName,
    int? propertyId,
    String? propertyTitle,
    int? agentId,
    String? agentName,
    @Default(0.0) double amount,
    required DateTime receivedOn,
    required DateTime holdUntil,
    @JsonKey(unknownEnumValue: DepositHolder.AGENCY)
    @Default(DepositHolder.AGENCY)
    DepositHolder holder,
    String? note,
    @Default(true) bool active,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    DepositOutcome? outcome,
    DateTime? closedOn,
  }) = _DealDeposit;

  factory DealDeposit.fromJson(Map<String, dynamic> json) =>
      _$DealDepositFromJson(json);
}

/// A won rent whose lease runs out soon, and the two people to call about it:
/// the tenant (the deal's client) and, when the deal names one, the landlord.
/// [monthlyRent] is in the agency's currency.
@freezed
class LeaseEnding with _$LeaseEnding {
  const factory LeaseEnding({
    required int dealId,
    @Default('') String dealTitle,
    @Default(0.0) double monthlyRent,
    DateTime? leaseStart,
    required DateTime leaseEnd,
    @Default(0) int daysLeft,
    @Default(30) int reminderDays,
    required int tenantId,
    @Default('') String tenantName,
    String? tenantPhone,
    int? landlordId,
    String? landlordName,
    String? landlordPhone,
    int? propertyId,
    String? propertyTitle,
    String? propertyAddress,
    int? agentId,
    String? agentName,
  }) = _LeaseEnding;

  factory LeaseEnding.fromJson(Map<String, dynamic> json) =>
      _$LeaseEndingFromJson(json);
}

/// What a visitor said at the door of an open house. Not asking is allowed,
/// and reads as null; so does a value this app does not know.
enum OpenHouseInterest {
  @JsonValue('INTERESTED')
  interested,
  @JsonValue('JUST_LOOKING')
  justLooking,
}

/// A listing held open for a few hours, with its summary. [visitors] is the
/// sign-in sheet and comes only with a single open house.
@freezed
class OpenHouse with _$OpenHouse {
  const OpenHouse._();

  const factory OpenHouse({
    required int id,
    required int propertyId,
    @Default('') String propertyTitle,
    String? propertyAddress,
    int? agentId,
    String? agentName,
    required DateTime startsAt,
    required DateTime endsAt,
    String? note,
    @Default(0) int visitorCount,
    @Default(0) int newClientCount,
    @Default(0) int interestedCount,

    /// Whether the signed-in user may move or cancel it.
    @Default(false) bool canEdit,
    DateTime? createdAt,
    @Default(<OpenHouseVisitor>[]) List<OpenHouseVisitor> visitors,
  }) = _OpenHouse;

  /// Over by [now]: what turns the sheet into a summary.
  bool isOver(DateTime now) => !endsAt.isAfter(now);

  /// Running at [now].
  bool isOn(DateTime now) => !startsAt.isAfter(now) && endsAt.isAfter(now);

  factory OpenHouse.fromJson(Map<String, dynamic> json) =>
      _$OpenHouseFromJson(json);
}

/// One line of an open house's sign-in sheet.
@freezed
class OpenHouseVisitor with _$OpenHouseVisitor {
  const factory OpenHouseVisitor({
    required int id,
    required int openHouseId,
    @Default('') String fullName,
    @Default('') String phone,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    OpenHouseInterest? interest,
    String? note,
    int? clientId,

    /// Whether the signed-in user may open the client card; a colleague's
    /// client, on an own-records scope, is named by [clientAgentName] only.
    @Default(false) bool clientVisible,
    String? clientName,
    String? clientAgentName,

    /// Whether this sign-in made the client rather than finding one.
    @Default(false) bool newClient,
    int? signedInById,
    String? signedInByName,
    DateTime? signedInAt,
    @Default(false) bool canRemove,
  }) = _OpenHouseVisitor;

  factory OpenHouseVisitor.fromJson(Map<String, dynamic> json) =>
      _$OpenHouseVisitorFromJson(json);
}

/// What an outside partner of the agency does.
enum PartnerKind {
  @JsonValue('MORTGAGE_BROKER')
  mortgageBroker,

  /// A lawyer or a notary.
  @JsonValue('LAWYER')
  lawyer,
  @JsonValue('APPRAISER')
  appraiser,
  @JsonValue('DEVELOPER')
  developer,

  /// Another agency.
  @JsonValue('AGENCY')
  agency,
  @JsonValue('OTHER')
  other,
}

/// How a partner's referral fee is worked out on a won deal: a share of the
/// agency's commission, or a fixed amount in the agency's currency.
enum ReferralFeeType {
  @JsonValue('PERCENT')
  percent,
  @JsonValue('FIXED')
  fixed,
}

/// Where a client sent to a partner has got to.
enum PartnerHandoffStatus {
  @JsonValue('SENT')
  sent,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('DONE')
  done,
}

/// One of the agency's partners, with what its referrals came to, counted
/// over the clients the signed-in user sees.
@freezed
class Partner with _$Partner {
  const factory Partner({
    required int id,
    @Default('') String name,
    String? company,
    @JsonKey(unknownEnumValue: PartnerKind.other)
    @Default(PartnerKind.other)
    PartnerKind kind,
    String? phone,
    String? email,
    String? note,

    /// Both or neither: no fee was agreed when null.
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    ReferralFeeType? feeType,
    double? feeValue,
    int? createdById,
    String? createdByName,

    /// Whether the signed-in user may change or delete it.
    @Default(false) bool canEdit,
    DateTime? createdAt,
    @Default(0) int referredClients,
    @Default(0) int wonDeals,
    @Default(0) double feesOwed,

    /// Won deals left out of [feesOwed] for want of a recorded commission.
    @Default(0) int wonDealsWithoutCommission,
    @Default(0) int handoffs,
    @Default(0) int openHandoffs,
  }) = _Partner;

  factory Partner.fromJson(Map<String, dynamic> json) =>
      _$PartnerFromJson(json);
}

/// A client a partner sent, with their won deals and the fee on them.
@freezed
class PartnerReferral with _$PartnerReferral {
  const factory PartnerReferral({
    required int clientId,
    @Default('') String fullName,
    @Default(ClientType.BUYER) ClientType type,
    int? agentId,
    String? agentName,
    @Default(0) int wonDeals,
    @Default(0) double feeOwed,
    @Default(0) int wonDealsWithoutCommission,
    DateTime? createdAt,
  }) = _PartnerReferral;

  factory PartnerReferral.fromJson(Map<String, dynamic> json) =>
      _$PartnerReferralFromJson(json);
}

/// A client sent to a partner, named from both ends.
@freezed
class PartnerHandoff with _$PartnerHandoff {
  const factory PartnerHandoff({
    required int id,
    required int clientId,
    @Default('') String clientName,
    required int partnerId,
    @Default('') String partnerName,
    String? partnerCompany,
    @JsonKey(unknownEnumValue: PartnerKind.other)
    @Default(PartnerKind.other)
    PartnerKind partnerKind,
    required DateTime sentOn,
    @JsonKey(unknownEnumValue: PartnerHandoffStatus.sent)
    @Default(PartnerHandoffStatus.sent)
    PartnerHandoffStatus status,
    String? note,
    int? sentById,
    String? sentByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartnerHandoff;

  factory PartnerHandoff.fromJson(Map<String, dynamic> json) =>
      _$PartnerHandoffFromJson(json);
}

/// The records whose changes the server writes down.
enum ChangeEntityType {
  @JsonValue('PROPERTY')
  property,
  @JsonValue('DEAL')
  deal,
  @JsonValue('CLIENT')
  client,
}

/// What one line of a change log says happened. An edit the app does not
/// know reads as [updated].
enum ChangeAction {
  @JsonValue('CREATED')
  created,
  @JsonValue('DELETED')
  deleted,
  @JsonValue('STATUS_CHANGED')
  statusChanged,
  @JsonValue('PRICE_CHANGED')
  priceChanged,
  @JsonValue('AGENT_CHANGED')
  agentChanged,
  @JsonValue('UPDATED')
  updated,
}

/// One line of a listing's, deal's or client's change log: it was created or
/// deleted, or [field] went from [oldValue] to [newValue]. Values are the
/// server's plain text (enum names, plain numbers, ISO dates, names) and are
/// put into words on screen. [actorId] is null once that person has left;
/// [actorName] still says who it was.
@freezed
class RecordChange with _$RecordChange {
  const factory RecordChange({
    required int id,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    ChangeEntityType? entityType,
    @Default(0) int entityId,
    String? entityLabel,
    @JsonKey(unknownEnumValue: ChangeAction.updated)
    @Default(ChangeAction.updated)
    ChangeAction action,
    String? field,
    String? oldValue,
    String? newValue,
    int? actorId,
    String? actorName,
    DateTime? changedAt,
  }) = _RecordChange;

  factory RecordChange.fromJson(Map<String, dynamic> json) =>
      _$RecordChangeFromJson(json);
}

/// Where a buyer's offer on a listing stands. [isNew] and [countered] are
/// open; the rest are decided. [expired] is an open offer past its last day,
/// as the server works it out when it reads one.
enum OfferStatus {
  @JsonValue('NEW')
  isNew,
  @JsonValue('COUNTERED')
  countered,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('WITHDRAWN')
  withdrawn,
  @JsonValue('EXPIRED')
  expired;

  bool get isOpen => this == isNew || this == countered;
}

/// Whose figure is on the table: the buyer's offer or the seller's counter.
enum OfferParty {
  @JsonValue('BUYER')
  buyer,
  @JsonValue('SELLER')
  seller,
}

/// One step in an offer's negotiation.
enum OfferAction {
  @JsonValue('OFFERED')
  offered,
  @JsonValue('COUNTERED')
  countered,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('WITHDRAWN')
  withdrawn,
}

/// A buyer's offer on a listing. [amount] is the figure on the table now, in
/// the agency's currency. [history] is the negotiation and comes only with a
/// single offer.
@freezed
class PropertyOffer with _$PropertyOffer {
  const factory PropertyOffer({
    required int id,
    required int propertyId,
    @Default('') String propertyTitle,
    String? propertyAddress,
    double? propertyPrice,
    required int clientId,

    /// Whether the signed-in user may open the buyer's card; a colleague's
    /// buyer, on an own-records scope, is named by [clientAgentName] only.
    @Default(false) bool clientVisible,
    String? clientName,
    String? clientAgentName,
    int? agentId,
    String? agentName,
    @Default(0.0) double amount,
    @JsonKey(unknownEnumValue: OfferParty.buyer)
    @Default(OfferParty.buyer)
    OfferParty lastParty,
    String? note,
    DateTime? expiresOn,
    @JsonKey(unknownEnumValue: OfferStatus.isNew)
    @Default(OfferStatus.isNew)
    OfferStatus status,

    /// Another offer on the same listing is accepted while this one waits.
    @Default(false) bool otherAccepted,

    /// Whether the signed-in user may counter, accept, reject or withdraw it.
    @Default(false) bool canEdit,
    DateTime? decidedAt,
    DateTime? createdAt,
    @Default(<OfferStep>[]) List<OfferStep> history,
  }) = _PropertyOffer;

  factory PropertyOffer.fromJson(Map<String, dynamic> json) =>
      _$PropertyOfferFromJson(json);
}

/// One step in an offer's negotiation, the first first.
@freezed
class OfferStep with _$OfferStep {
  const factory OfferStep({
    required int id,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    OfferAction? action,
    @Default(0.0) double amount,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    OfferParty? party,
    String? note,
    int? actorId,
    String? actorName,
    DateTime? createdAt,
  }) = _OfferStep;

  factory OfferStep.fromJson(Map<String, dynamic> json) =>
      _$OfferStepFromJson(json);
}
