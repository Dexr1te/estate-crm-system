import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/partners/domain/repositories/partners_repository.dart';

/// Partners in memory. Deleting a partner with referrals or hand-offs is
/// refused with the server's code, and a hand-off on a day still to come is
/// refused the way the server refuses it.
class FakePartnersRepository implements PartnersRepository {
  final List<Partner> partners;
  final Map<int, List<PartnerReferral>> referrals;
  final List<PartnerHandoff> handoffs;
  final List<PartnerDraft> saved = [];
  final List<HandoffDraft> sent = [];
  final List<int> deleted = [];
  final List<int> deletedHandoffs = [];
  int _nextId = 1000;

  /// When set, every read and write fails with it.
  Object? failWith;

  /// The day the fake calls today, for refusing a hand-off in the future.
  DateTime today = DateTime(2026, 10, 4);

  FakePartnersRepository({
    List<Partner>? partners,
    Map<int, List<PartnerReferral>>? referrals,
    List<PartnerHandoff>? handoffs,
  })  : partners = partners ?? [],
        referrals = referrals ?? {},
        handoffs = handoffs ?? [];

  void _check() {
    final error = failWith;
    if (error != null) throw error;
  }

  static DioException refusal(String path, int status, String code) =>
      DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: status,
          data: {'status': status, 'code': code, 'message': code},
        ),
        type: DioExceptionType.badResponse,
      );

  Partner _find(int id) => partners.firstWhere((p) => p.id == id);

  @override
  Future<List<Partner>> getPartners({PartnerKind? kind, String? search}) async {
    _check();
    final q = search?.trim().toLowerCase() ?? '';
    return partners
        .where((p) => kind == null || p.kind == kind)
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Partner> getPartner(int id) async {
    _check();
    return _find(id);
  }

  Partner _apply(Partner p, PartnerDraft d) => p.copyWith(
        name: d.name,
        kind: d.kind,
        company: d.company,
        phone: d.phone,
        email: d.email,
        note: d.note,
        feeType: d.feeType,
        feeValue: d.feeValue,
      );

  @override
  Future<Partner> create(PartnerDraft draft) async {
    _check();
    saved.add(draft);
    final made = _apply(Partner(id: _nextId++, canEdit: true), draft);
    partners.add(made);
    return made;
  }

  @override
  Future<Partner> update(int id, PartnerDraft draft) async {
    _check();
    saved.add(draft);
    final i = partners.indexWhere((p) => p.id == id);
    partners[i] = _apply(partners[i], draft);
    return partners[i];
  }

  @override
  Future<void> delete(int id) async {
    _check();
    final p = _find(id);
    if (p.referredClients > 0 ||
        p.handoffs > 0 ||
        handoffs.any((h) => h.partnerId == id)) {
      throw refusal('/partners/$id', 409, 'PARTNER_IN_USE');
    }
    deleted.add(id);
    partners.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<PartnerReferral>> getReferrals(int id) async {
    _check();
    return referrals[id] ?? const [];
  }

  @override
  Future<List<PartnerHandoff>> getPartnerHandoffs(int id) async {
    _check();
    return handoffs.where((h) => h.partnerId == id).toList();
  }

  @override
  Future<List<PartnerHandoff>> getClientHandoffs(int clientId) async {
    _check();
    return handoffs.where((h) => h.clientId == clientId).toList();
  }

  @override
  Future<PartnerHandoff> createHandoff(int clientId, HandoffDraft draft) async {
    _check();
    if (draft.sentOn.isAfter(today)) {
      throw refusal(
          '/clients/$clientId/partner-handoffs', 400, 'SENT_ON_IN_FUTURE');
    }
    sent.add(draft);
    final partner = _find(draft.partnerId);
    final made = PartnerHandoff(
      id: _nextId++,
      clientId: clientId,
      partnerId: partner.id,
      partnerName: partner.name,
      partnerCompany: partner.company,
      partnerKind: partner.kind,
      sentOn: draft.sentOn,
      status: draft.status,
      note: draft.note,
    );
    handoffs.insert(0, made);
    return made;
  }

  @override
  Future<PartnerHandoff> updateHandoff(
      int clientId, int handoffId, HandoffDraft draft) async {
    _check();
    sent.add(draft);
    final i = handoffs.indexWhere((h) => h.id == handoffId);
    handoffs[i] = handoffs[i]
        .copyWith(sentOn: draft.sentOn, status: draft.status, note: draft.note);
    return handoffs[i];
  }

  @override
  Future<void> deleteHandoff(int clientId, int handoffId) async {
    _check();
    deletedHandoffs.add(handoffId);
    handoffs.removeWhere((h) => h.id == handoffId);
  }
}
