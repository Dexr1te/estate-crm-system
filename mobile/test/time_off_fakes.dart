import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/time_off/domain/repositories/time_off_repository.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

/// Time off in memory. Reads filter [items] by the window and the person the
/// way the server does; writes are remembered in [created], [updated] and
/// [cancelled], and answer with [answer] when a test wants the server's reply
/// to carry something (meetings that clash). [failWith] makes the next write
/// fail with that server code; [failReads] makes every read fail.
class FakeTimeOffRepository implements TimeOffRepository {
  List<TimeOff> items;
  TimeOff? answer;
  String? failWith;
  bool failReads;

  final List<TimeOffDraft> created = [];
  final List<(int, TimeOffDraft)> updated = [];
  final List<int> cancelled = [];
  final List<(DateTime, DateTime, int?)> asked = [];

  FakeTimeOffRepository(
      {this.items = const [], this.answer, this.failReads = false});

  @override
  Future<List<TimeOff>> getTimeOff(
      {required DateTime from, required DateTime to, int? userId}) async {
    asked.add((from, to, userId));
    if (failReads) throw _failure('GET', 500, null);
    return items
        .where((t) => userId == null || t.userId == userId)
        .where((t) =>
            !timeOffDay(t.startDate).isAfter(timeOffDay(to)) &&
            !timeOffDay(t.endDate).isBefore(timeOffDay(from)))
        .toList();
  }

  @override
  Future<TimeOff> getOne(int id) async {
    if (failReads) throw _failure('GET', 500, null);
    return items.firstWhere((t) => t.id == id,
        orElse: () => throw _failure('GET', 404, null));
  }

  @override
  Future<TimeOff> create(TimeOffDraft draft) async {
    _maybeFail('POST');
    created.add(draft);
    return answer ?? _from(100 + created.length, draft);
  }

  @override
  Future<TimeOff> update(int id, TimeOffDraft draft) async {
    _maybeFail('PUT');
    updated.add((id, draft));
    return answer ?? _from(id, draft);
  }

  @override
  Future<void> cancel(int id) async {
    _maybeFail('DELETE');
    cancelled.add(id);
    items = items.where((t) => t.id != id).toList();
  }

  void _maybeFail(String method) {
    final code = failWith;
    if (code == null) return;
    failWith = null;
    throw _failure(method, code == 'TIME_OFF_OVERLAPS' ? 409 : 400, code);
  }

  static TimeOff _from(int id, TimeOffDraft d) => TimeOff(
        id: id,
        userId: d.userId ?? 1,
        kind: d.kind,
        startDate: d.startDate,
        endDate: d.endDate,
        days: timeOffLength(d.startDate, d.endDate),
        coverId: d.coverId,
        note: d.note,
        canEdit: true,
      );

  static DioException _failure(String method, int status, String? code) {
    final options = RequestOptions(path: '/time-off', method: method);
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: status,
        data: {if (code != null) 'code': code},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
