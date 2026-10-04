import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/partners/domain/repositories/partners_repository.dart';

class PartnersRemoteDataSource {
  final ApiClient _client;
  PartnersRemoteDataSource(this._client);

  Future<List<Partner>> getPartners({PartnerKind? kind, String? search}) async {
    final res = await _client.dio.get('/partners', queryParameters: {
      if (kind != null) 'kind': partnerKindName(kind),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    return jsonArray(res).map(Partner.fromJson).toList();
  }

  Future<Partner> getPartner(int id) async {
    final res = await _client.dio.get('/partners/$id');
    return Partner.fromJson(jsonObject(res));
  }

  Future<Partner> create(PartnerDraft draft) async {
    final res = await _client.dio.post('/partners', data: _partner(draft));
    return Partner.fromJson(jsonObject(res));
  }

  Future<Partner> update(int id, PartnerDraft draft) async {
    final res = await _client.dio.put('/partners/$id', data: _partner(draft));
    return Partner.fromJson(jsonObject(res));
  }

  Future<void> delete(int id) async {
    await _client.dio.delete('/partners/$id');
  }

  Future<List<PartnerReferral>> getReferrals(int id) async {
    final res = await _client.dio.get('/partners/$id/referrals');
    return jsonArray(res).map(PartnerReferral.fromJson).toList();
  }

  Future<List<PartnerHandoff>> getPartnerHandoffs(int id) async {
    final res = await _client.dio.get('/partners/$id/handoffs');
    return jsonArray(res).map(PartnerHandoff.fromJson).toList();
  }

  Future<List<PartnerHandoff>> getClientHandoffs(int clientId) async {
    final res = await _client.dio.get('/clients/$clientId/partner-handoffs');
    return jsonArray(res).map(PartnerHandoff.fromJson).toList();
  }

  Future<PartnerHandoff> createHandoff(int clientId, HandoffDraft draft) async {
    final res = await _client.dio
        .post('/clients/$clientId/partner-handoffs', data: _handoff(draft));
    return PartnerHandoff.fromJson(jsonObject(res));
  }

  Future<PartnerHandoff> updateHandoff(
      int clientId, int handoffId, HandoffDraft draft) async {
    final res = await _client.dio.put(
        '/clients/$clientId/partner-handoffs/$handoffId',
        data: _handoff(draft));
    return PartnerHandoff.fromJson(jsonObject(res));
  }

  Future<void> deleteHandoff(int clientId, int handoffId) async {
    await _client.dio.delete('/clients/$clientId/partner-handoffs/$handoffId');
  }

  static Map<String, dynamic> _partner(PartnerDraft d) => {
        'name': d.name,
        'company': d.company,
        'kind': partnerKindName(d.kind),
        'phone': d.phone,
        'email': d.email,
        'note': d.note,
        'feeType': switch (d.feeType) {
          ReferralFeeType.percent => 'PERCENT',
          ReferralFeeType.fixed => 'FIXED',
          null => null,
        },
        'feeValue': d.feeType == null ? null : d.feeValue,
      };

  static Map<String, dynamic> _handoff(HandoffDraft d) => {
        'partnerId': d.partnerId,
        'sentOn': _day(d.sentOn),
        'status': switch (d.status) {
          PartnerHandoffStatus.sent => 'SENT',
          PartnerHandoffStatus.inProgress => 'IN_PROGRESS',
          PartnerHandoffStatus.done => 'DONE',
        },
        if (d.note != null) 'note': d.note,
      };

  static String _day(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// The server's name for a kind of partner.
String partnerKindName(PartnerKind kind) => switch (kind) {
      PartnerKind.mortgageBroker => 'MORTGAGE_BROKER',
      PartnerKind.lawyer => 'LAWYER',
      PartnerKind.appraiser => 'APPRAISER',
      PartnerKind.developer => 'DEVELOPER',
      PartnerKind.agency => 'AGENCY',
      PartnerKind.other => 'OTHER',
    };
