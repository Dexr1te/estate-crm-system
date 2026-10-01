import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/open_houses/domain/repositories/open_houses_repository.dart';

/// Open houses in memory. Signing in matches an existing number against
/// [knownPhones] (digits only), the way the server matches the agency's
/// clients, and refuses a number already on the sheet with the server's code.
class FakeOpenHousesRepository implements OpenHousesRepository {
  final List<OpenHouse> openHouses;
  final Set<String> knownPhones;
  final List<OpenHouseDraft> created = [];
  final List<VisitorDraft> signedIn = [];
  final List<int> removed = [];
  final List<int> deleted = [];
  int _nextId = 1000;

  /// When set, every read and write fails with it.
  Object? failWith;

  FakeOpenHousesRepository(
      {List<OpenHouse>? openHouses, this.knownPhones = const {}})
      : openHouses = openHouses ?? [];

  /// Digits only, with the domestic 8 read as +7, as the server compares.
  static String _digits(String s) {
    final digits = s.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && digits.startsWith('8')
        ? '7${digits.substring(1)}'
        : digits;
  }

  void _check() {
    final error = failWith;
    if (error != null) throw error;
  }

  OpenHouse _find(int id) => openHouses.firstWhere((o) => o.id == id);

  void _put(OpenHouse o) {
    final i = openHouses.indexWhere((e) => e.id == o.id);
    if (i < 0) {
      openHouses.add(o);
    } else {
      openHouses[i] = o;
    }
  }

  static OpenHouse _summarised(OpenHouse o) => o.copyWith(
        visitorCount: o.visitors.length,
        newClientCount: o.visitors.where((v) => v.newClient).length,
        interestedCount: o.visitors
            .where((v) => v.interest == OpenHouseInterest.interested)
            .length,
      );

  @override
  Future<List<OpenHouse>> getForProperty(int propertyId) async {
    _check();
    return openHouses
        .where((o) => o.propertyId == propertyId)
        .map((o) => o.copyWith(visitors: const []))
        .toList();
  }

  @override
  Future<List<OpenHouse>> getBetween(DateTime from, DateTime to) async {
    _check();
    return openHouses
        .where((o) => o.startsAt.isBefore(to) && o.endsAt.isAfter(from))
        .map((o) => o.copyWith(visitors: const []))
        .toList();
  }

  @override
  Future<OpenHouse> getOpenHouse(int id) async {
    _check();
    return _find(id);
  }

  @override
  Future<OpenHouse> create(int propertyId, OpenHouseDraft draft) async {
    _check();
    created.add(draft);
    final o = OpenHouse(
      id: _nextId++,
      propertyId: propertyId,
      propertyTitle: 'Listing $propertyId',
      startsAt: draft.startsAt,
      endsAt: draft.endsAt,
      note: draft.note,
      canEdit: true,
    );
    _put(o);
    return o;
  }

  @override
  Future<OpenHouse> update(int id, OpenHouseDraft draft) async {
    _check();
    final o = _find(id).copyWith(
        startsAt: draft.startsAt, endsAt: draft.endsAt, note: draft.note);
    _put(o);
    return o;
  }

  @override
  Future<void> delete(int id) async {
    _check();
    deleted.add(id);
    openHouses.removeWhere((o) => o.id == id);
  }

  @override
  Future<OpenHouseVisitor> signIn(int id, VisitorDraft visitor) async {
    _check();
    final o = _find(id);
    final phone = _digits(visitor.phone);
    if (o.visitors.any((v) => _digits(v.phone) == phone)) {
      final options = RequestOptions(path: '/open-houses/$id/visitors');
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 409,
          data: {
            'code': 'ALREADY_SIGNED_IN',
            'message': 'Someone with this number has already signed in',
          },
        ),
        type: DioExceptionType.badResponse,
      );
    }
    signedIn.add(visitor);
    final known = knownPhones.contains(phone);
    final v = OpenHouseVisitor(
      id: _nextId++,
      openHouseId: id,
      fullName: visitor.fullName,
      phone: visitor.phone,
      interest: visitor.interest,
      note: visitor.note,
      clientId: _nextId++,
      clientVisible: true,
      clientName: visitor.fullName,
      newClient: !known,
      signedInAt: DateTime(2026, 10, 4, 12, 30),
      canRemove: true,
    );
    _put(_summarised(o.copyWith(visitors: [v, ...o.visitors])));
    return v;
  }

  @override
  Future<void> removeVisitor(int id, int visitorId) async {
    _check();
    removed.add(visitorId);
    final o = _find(id);
    _put(_summarised(o.copyWith(
        visitors: o.visitors.where((v) => v.id != visitorId).toList())));
  }
}
