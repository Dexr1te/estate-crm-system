import 'package:real_estate_crm/core/models/models.dart';

/// Whether a share of a won deal's commission has been paid out yet.
enum PayoutStatus {
  unpaid('UNPAID'),
  paid('PAID');

  /// How the server spells it.
  final String wire;
  const PayoutStatus(this.wire);

  static PayoutStatus parse(String? raw) =>
      raw == paid.wire ? PayoutStatus.paid : PayoutStatus.unpaid;
}

CommissionPartyKind _kind(Object? raw) =>
    raw == CommissionPartyKind.COLLEAGUE.name
        ? CommissionPartyKind.COLLEAGUE
        : CommissionPartyKind.CO_BROKER;

DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;

/// One share of a won deal's commission: whose it is, what it comes to, and
/// when and by whom it was paid out. [amount] is in the agency's currency,
/// null while the deal's price or rate is unknown. [agentId] is null for a
/// co-broker, who has no account.
class PayoutItem {
  final int shareId;
  final int dealId;
  final String dealTitle;
  final DateTime? closedAt;
  final CommissionPartyKind kind;
  final int? agentId;
  final String agentName;
  final String? agency;
  final double percent;
  final double? amount;
  final bool paid;
  final DateTime? paidAt;
  final int? paidById;
  final String? paidByName;
  final String? note;

  const PayoutItem({
    required this.shareId,
    required this.dealId,
    this.dealTitle = '',
    this.closedAt,
    this.kind = CommissionPartyKind.COLLEAGUE,
    this.agentId,
    this.agentName = '',
    this.agency,
    this.percent = 0,
    this.amount,
    this.paid = false,
    this.paidAt,
    this.paidById,
    this.paidByName,
    this.note,
  });

  factory PayoutItem.fromJson(Map<String, dynamic> json) => PayoutItem(
        shareId: (json['shareId'] as num).toInt(),
        dealId: (json['dealId'] as num).toInt(),
        dealTitle: json['dealTitle'] as String? ?? '',
        closedAt: _date(json['closedAt']),
        kind: _kind(json['kind']),
        agentId: (json['agentId'] as num?)?.toInt(),
        agentName: json['agentName'] as String? ?? '',
        agency: json['agency'] as String?,
        percent: (json['percent'] as num?)?.toDouble() ?? 0,
        amount: (json['amount'] as num?)?.toDouble(),
        paid: json['paid'] as bool? ?? false,
        paidAt: _date(json['paidAt']),
        paidById: (json['paidById'] as num?)?.toInt(),
        paidByName: json['paidByName'] as String?,
        note: json['note'] as String?,
      );
}

/// What one colleague (or co-broker) is still owed, over [shares] shares.
class PayoutPartyTotal {
  final CommissionPartyKind kind;
  final int? agentId;
  final String name;
  final String? agency;
  final double unpaid;
  final int shares;

  const PayoutPartyTotal({
    this.kind = CommissionPartyKind.COLLEAGUE,
    this.agentId,
    this.name = '',
    this.agency,
    this.unpaid = 0,
    this.shares = 0,
  });

  factory PayoutPartyTotal.fromJson(Map<String, dynamic> json) =>
      PayoutPartyTotal(
        kind: _kind(json['kind']),
        agentId: (json['agentId'] as num?)?.toInt(),
        name: json['name'] as String? ?? '',
        agency: json['agency'] as String?,
        unpaid: (json['unpaid'] as num?)?.toDouble() ?? 0,
        shares: (json['shares'] as num?)?.toInt() ?? 0,
      );
}

/// The shares of won deals in the reader's view: the whole agency for a
/// manager ([wholeTeam]), an agent's own otherwise. [items] are the ones in
/// [status]; the totals and [byAgent] cover every share in view.
class PayoutList {
  final PayoutStatus status;
  final bool wholeTeam;
  final double unpaidTotal;
  final double paidTotal;
  final List<PayoutPartyTotal> byAgent;
  final List<PayoutItem> items;

  const PayoutList({
    this.status = PayoutStatus.unpaid,
    this.wholeTeam = false,
    this.unpaidTotal = 0,
    this.paidTotal = 0,
    this.byAgent = const [],
    this.items = const [],
  });

  factory PayoutList.fromJson(Map<String, dynamic> json) => PayoutList(
        status: PayoutStatus.parse(json['status'] as String?),
        wholeTeam: json['wholeTeam'] as bool? ?? false,
        unpaidTotal: (json['unpaidTotal'] as num?)?.toDouble() ?? 0,
        paidTotal: (json['paidTotal'] as num?)?.toDouble() ?? 0,
        byAgent: [
          for (final p in json['byAgent'] as List<dynamic>? ?? const [])
            if (p is Map<String, dynamic>) PayoutPartyTotal.fromJson(p),
        ],
        items: [
          for (final i in json['items'] as List<dynamic>? ?? const [])
            if (i is Map<String, dynamic>) PayoutItem.fromJson(i),
        ],
      );
}
