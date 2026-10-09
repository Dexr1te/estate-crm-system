/// One time a listing's keys went out: who has (or had) them, until when,
/// and who recorded them going out and coming back.
class KeyHandover {
  final int id;
  final int propertyId;
  final String? propertyTitle;
  final String? propertyAddress;
  final String? propertyCity;

  /// The colleague holding them; null for somebody outside the agency.
  final int? holderUserId;

  /// Who holds them, by name: the colleague's, or the one typed in.
  final String holderName;
  final String? note;
  final DateTime handedOutAt;

  /// The last day they are to be back, if one was set.
  final DateTime? dueBackAt;

  /// When they came back; null while they are out.
  final DateTime? returnedAt;
  final int? handedOutById;
  final String? handedOutByName;
  final int? returnedById;
  final String? returnedByName;

  /// Out past the day they were due back, as the server counts days.
  final bool overdue;

  const KeyHandover({
    required this.id,
    required this.propertyId,
    this.propertyTitle,
    this.propertyAddress,
    this.propertyCity,
    this.holderUserId,
    required this.holderName,
    this.note,
    required this.handedOutAt,
    this.dueBackAt,
    this.returnedAt,
    this.handedOutById,
    this.handedOutByName,
    this.returnedById,
    this.returnedByName,
    this.overdue = false,
  });

  bool get isOut => returnedAt == null;

  /// Held by a colleague rather than somebody named by hand.
  bool get withColleague => holderUserId != null;

  factory KeyHandover.fromJson(Map<String, dynamic> json) => KeyHandover(
        id: (json['id'] as num).toInt(),
        propertyId: (json['propertyId'] as num).toInt(),
        propertyTitle: json['propertyTitle'] as String?,
        propertyAddress: json['propertyAddress'] as String?,
        propertyCity: json['propertyCity'] as String?,
        holderUserId: (json['holderUserId'] as num?)?.toInt(),
        holderName: (json['holderName'] ?? '') as String,
        note: json['note'] as String?,
        handedOutAt: _dateTime(json['handedOutAt']) ?? DateTime(1970),
        dueBackAt: _dateTime(json['dueBackAt']),
        returnedAt: _dateTime(json['returnedAt']),
        handedOutById: (json['handedOutById'] as num?)?.toInt(),
        handedOutByName: json['handedOutByName'] as String?,
        returnedById: (json['returnedById'] as num?)?.toInt(),
        returnedByName: json['returnedByName'] as String?,
        overdue: (json['overdue'] ?? false) as bool,
      );
}

/// A listing's keys: who has them now, if anybody, and the handovers that
/// are over, the newest first.
class PropertyKeys {
  final KeyHandover? current;
  final List<KeyHandover> history;

  const PropertyKeys({this.current, this.history = const []});

  static const empty = PropertyKeys();

  factory PropertyKeys.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final history = json['history'];
    return PropertyKeys(
      current: current is Map<String, dynamic>
          ? KeyHandover.fromJson(current)
          : null,
      history: history is List
          ? [
              for (final h in history)
                if (h is Map<String, dynamic>) KeyHandover.fromJson(h),
            ]
          : const [],
    );
  }
}

/// What the app sends to hand a listing's keys out: to a colleague
/// ([holderUserId]) or to somebody by name ([holderName]), exactly one of
/// the two, with the last day they are due back and a note, both optional.
class KeyHandoverDraft {
  final int? holderUserId;
  final String? holderName;
  final DateTime? dueBackAt;
  final String? note;

  const KeyHandoverDraft({
    this.holderUserId,
    this.holderName,
    this.dueBackAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final name = holderName?.trim() ?? '';
    final text = note?.trim() ?? '';
    final due = dueBackAt;
    return {
      if (holderUserId != null) 'holderUserId': holderUserId,
      if (holderUserId == null && name.isNotEmpty) 'holderName': name,
      if (due != null) 'dueBackAt': keyDateParam(due),
      if (text.isNotEmpty) 'note': text,
    };
  }
}

/// The longest note the server keeps on a handover.
const kKeyNoteMaxLength = 500;

/// A day as the server takes it: "2026-10-12".
String keyDateParam(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? _dateTime(Object? raw) =>
    raw is String ? DateTime.tryParse(raw) : null;
