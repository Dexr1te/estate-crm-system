import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';
import 'package:real_estate_crm/features/commission_split/domain/repositories/commission_split_repository.dart';

/// Commission splits in memory. A deal nobody split reads as all its
/// agent's, with nothing to edit. Every write is remembered; [writeError],
/// when set, is thrown by every write after it is remembered.
class FakeCommissionSplitRepository implements CommissionSplitRepository {
  Map<int, CommissionSplit> byDeal;
  bool failLoad;
  Object? writeError;

  final List<(int, CommissionSplitDraft)> saved = [];
  final List<int> cleared = [];

  FakeCommissionSplitRepository({
    Map<int, CommissionSplit>? byDeal,
    this.failLoad = false,
  }) : byDeal = byDeal ?? {};

  @override
  Future<CommissionSplit> getSplit(int dealId) async {
    if (failLoad) throw Exception('offline');
    return byDeal[dealId] ?? CommissionSplit(dealId: dealId);
  }

  @override
  Future<CommissionSplit> saveSplit(
      int dealId, CommissionSplitDraft draft) async {
    saved.add((dealId, draft));
    if (writeError != null) throw writeError!;
    final before = byDeal[dealId] ?? CommissionSplit(dealId: dealId);
    final agent = before.shares.firstWhere(
        (s) => s.kind == CommissionPartyKind.AGENT,
        orElse: () => const CommissionShare(kind: CommissionPartyKind.AGENT));
    final commission = before.commission;
    double? amountOf(double percent) =>
        commission == null ? null : commission * percent / 100;
    final others = [
      for (final l in draft.lines)
        if (l.kind != CommissionPartyKind.AGENT)
          CommissionShare(
            kind: l.kind,
            userId: l.userId,
            name: l.name.trim(),
            agency: l.agency == null || l.agency!.trim().isEmpty
                ? null
                : l.agency!.trim(),
            percent: l.percent ?? 0,
            amount: amountOf(l.percent ?? 0),
          ),
    ];
    final mine = 100 - others.fold<double>(0, (sum, s) => sum + s.percent);
    final after = before.copyWith(
      split: others.isNotEmpty,
      shares: [
        agent.copyWith(percent: mine, amount: amountOf(mine)),
        ...others,
      ],
    );
    byDeal[dealId] = after;
    return after;
  }

  /// Every payout marked: the deal, the share and the note.
  final List<(int, int, String?)> markedPaid = [];

  /// Every payout undone: the deal and the share.
  final List<(int, int)> undone = [];

  /// When the fake says a share was paid.
  DateTime paidAt = DateTime(2026, 10, 9, 12);

  @override
  Future<CommissionSplit> markPaid(int dealId, int shareId,
      {String? note}) async {
    markedPaid.add((dealId, shareId, note));
    if (writeError != null) throw writeError!;
    return _payout(
        dealId,
        shareId,
        (s) => s.copyWith(
            paid: true,
            paidAt: paidAt,
            paidById: 1,
            paidByName: 'Asel Nurlanovna',
            payoutNote: note));
  }

  @override
  Future<CommissionSplit> undoPayout(int dealId, int shareId) async {
    undone.add((dealId, shareId));
    if (writeError != null) throw writeError!;
    return _payout(
        dealId,
        shareId,
        (s) => s.copyWith(
            paid: false,
            paidAt: null,
            paidById: null,
            paidByName: null,
            payoutNote: null));
  }

  CommissionSplit _payout(int dealId, int shareId,
      CommissionShare Function(CommissionShare) change) {
    final before = byDeal[dealId] ?? CommissionSplit(dealId: dealId);
    final after = before.copyWith(shares: [
      for (final s in before.shares) s.id == shareId ? change(s) : s,
    ]);
    byDeal[dealId] = after;
    return after;
  }

  @override
  Future<CommissionSplit> clearSplit(int dealId) async {
    cleared.add(dealId);
    if (writeError != null) throw writeError!;
    final before = byDeal[dealId] ?? CommissionSplit(dealId: dealId);
    final after = before.copyWith(split: false, shares: [
      for (final s in before.shares)
        if (s.kind == CommissionPartyKind.AGENT)
          s.copyWith(percent: 100, amount: before.commission),
    ]);
    byDeal[dealId] = after;
    return after;
  }
}
