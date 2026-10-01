import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/domain/repositories/deposits_repository.dart';

/// Deal deposits in memory. Every write is remembered; [writeError], when
/// set, is thrown by every write after it is remembered.
class FakeDepositsRepository implements DepositsRepository {
  Map<int, List<DealDeposit>> byDeal;
  List<DealDeposit> ending;
  bool failLoad;
  bool failEnding;
  Object? writeError;

  final List<(int, DepositDraft)> recorded = [];
  final List<(int, int, DepositDraft)> updated = [];
  final List<(int, int, DepositClosing)> closed = [];
  int _nextId = 900;

  FakeDepositsRepository({
    Map<int, List<DealDeposit>>? byDeal,
    this.ending = const [],
    this.failLoad = false,
    this.failEnding = false,
  }) : byDeal = byDeal ?? {};

  @override
  Future<List<DealDeposit>> getDealDeposits(int dealId) async {
    if (failLoad) throw Exception('offline');
    return byDeal[dealId] ?? const [];
  }

  @override
  Future<DealDeposit> record(int dealId, DepositDraft draft) async {
    recorded.add((dealId, draft));
    if (writeError != null) throw writeError!;
    final d = DealDeposit(
      id: _nextId++,
      dealId: dealId,
      amount: draft.amount,
      receivedOn: draft.receivedOn,
      holdUntil: draft.holdUntil,
      holder: draft.holder,
      note: draft.note,
    );
    byDeal[dealId] = [d, ...?byDeal[dealId]];
    return d;
  }

  @override
  Future<DealDeposit> update(
      int dealId, int depositId, DepositDraft draft) async {
    updated.add((dealId, depositId, draft));
    if (writeError != null) throw writeError!;
    final before = byDeal[dealId]!.firstWhere((d) => d.id == depositId);
    final d = before.copyWith(
      amount: draft.amount,
      receivedOn: draft.receivedOn,
      holdUntil: draft.holdUntil,
      holder: draft.holder,
      note: draft.note,
    );
    byDeal[dealId] = [
      for (final x in byDeal[dealId]!) x.id == depositId ? d : x
    ];
    return d;
  }

  @override
  Future<DealDeposit> close(
      int dealId, int depositId, DepositClosing closing) async {
    closed.add((dealId, depositId, closing));
    if (writeError != null) throw writeError!;
    final before = byDeal[dealId]!.firstWhere((d) => d.id == depositId);
    final d = before.copyWith(
        active: false, outcome: closing.outcome, closedOn: closing.closedOn);
    byDeal[dealId] = [
      for (final x in byDeal[dealId]!) x.id == depositId ? d : x
    ];
    return d;
  }

  @override
  Future<List<DealDeposit>> getDepositsEnding() async {
    if (failEnding) throw Exception('offline');
    return ending;
  }
}
