import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/entity_picker.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef DraftValues = Map<String, Object?>;

class FormDraft {
  FormDraft(this.id, {this.delay = const Duration(milliseconds: 500)})
      : key = '$keyPrefix${scope() ?? '-'}:$id' {
    _watchSession();
  }

  static const keyPrefix = 'form_draft:';

  static String? Function() scope = () => Injector.session.cacheScope;

  static bool _watchingSession = false;

  final String id;
  final String key;
  final Duration delay;

  Timer? _timer;
  DraftValues? _pending;
  bool _dirty = false;
  bool _finished = false;
  Future<void> _writes = Future<void>.value();

  bool get isFinished => _finished;

  Future<DraftValues?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  void schedule(DraftValues? values) {
    if (_finished) return;
    _pending = values;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    if (_finished || !_dirty) return _writes;
    final values = _pending;
    _pending = null;
    _dirty = false;
    return _write(values);
  }

  Future<void> discard() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
    _dirty = false;
    return _write(null);
  }

  Future<void> finish() {
    final done = discard();
    _finished = true;
    return done;
  }

  Future<void> _write(DraftValues? values) => _writes = _writes.then((_) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          if (values == null) {
            await prefs.remove(key);
          } else {
            await prefs.setString(key, jsonEncode(values));
          }
        } catch (_) {}
      });

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [
        for (final k in prefs.getKeys())
          if (k.startsWith(keyPrefix)) k
      ];
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }

  static void _watchSession() {
    if (_watchingSession) return;
    _watchingSession = true;
    Injector.session.addClearListener(clearAll);
  }
}

const _refKey = 'ref';

DraftValues? draftRef(PickerItem? item) => item == null
    ? null
    : {_refKey: item.id, 'title': item.title, 'subtitle': item.subtitle};

String? draftDate(DateTime? date) => date?.toIso8601String();

Future<bool> savedOutcome<S>(
  Stream<S> states, {
  required bool Function(S state) saved,
  required bool Function(S state) failed,
}) =>
    states.firstWhere((s) => saved(s) || failed(s)).then(saved);

bool sameDraft(Object? a, Object? b) {
  if (a is Map<Object?, Object?> && b is Map<Object?, Object?>) {
    if (a.containsKey(_refKey) || b.containsKey(_refKey)) {
      return a[_refKey] == b[_refKey];
    }
    return {...a.keys, ...b.keys}.every((k) => sameDraft(a[k], b[k]));
  }
  if (a is List<Object?> && b is List<Object?>) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!sameDraft(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

extension DraftValuesRead on DraftValues {
  String textAt(String key) {
    final v = this[key];
    return v is String ? v : '';
  }

  String? stringAt(String key) {
    final v = this[key];
    return v is String ? v : null;
  }

  int? intAt(String key) {
    final v = this[key];
    return v is num ? v.toInt() : null;
  }

  double? doubleAt(String key) {
    final v = this[key];
    return v is num ? v.toDouble() : null;
  }

  DateTime? dateAt(String key) {
    final v = this[key];
    return v is String ? DateTime.tryParse(v) : null;
  }

  E? enumAt<E extends Enum>(String key, List<E> values) {
    final v = this[key];
    return v is String ? values.asNameMap()[v] : null;
  }

  List<String> stringsAt(String key) {
    final v = this[key];
    return v is List<Object?>
        ? [
            for (final s in v)
              if (s is String) s
          ]
        : [];
  }

  Map<String, dynamic>? mapAt(String key) {
    final v = this[key];
    return v is Map<String, dynamic> ? v : null;
  }

  PickerItem? refAt(String key) {
    final v = this[key];
    if (v is! Map<String, dynamic>) return null;
    final id = v[_refKey];
    if (id is! int) return null;
    final title = v['title'];
    final subtitle = v['subtitle'];
    return PickerItem(
      id: id,
      title: title is String ? title : '',
      subtitle: subtitle is String ? subtitle : null,
    );
  }
}

mixin FormDraftMixin<T extends StatefulWidget> on State<T> {
  FormDraft? _draft;
  DraftValues? _original;
  DraftValues? _sent;
  List<Listenable> _watched = const [];

  String get draftId;

  DraftValues captureDraft();

  void restoreDraft(DraftValues values);

  List<Listenable> get draftFields => const [];

  bool get draftStarted => _draft != null;

  void startDraft() => unawaited(_startDraft());

  Future<void> _startDraft() async {
    if (_draft != null) return;
    final draft = _draft = FormDraft(draftId);
    _original = captureDraft();
    _watched = draftFields;
    for (final field in _watched) {
      field.addListener(_draftChanged);
    }
    final saved = await draft.read();
    if (!mounted || saved == null || draft.isFinished) return;
    if (!sameDraft(captureDraft(), _original)) return;
    if (sameDraft(saved, _original)) {
      await draft.discard();
      return;
    }
    _sent = saved;
    setState(() => restoreDraft(saved));
    onDraftRestored();
  }

  void settleDraft(VoidCallback change) {
    final original = _original;
    final untouched = original != null && sameDraft(captureDraft(), original);
    change();
    if (untouched) _original = captureDraft();
  }

  void onDraftRestored() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final l10n = AppLocalizations.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        key: const ValueKey('draft-restored'),
        content: Text(l10n.coreDraftRestored,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        action: SnackBarAction(
          key: const ValueKey('draft-discard'),
          label: l10n.coreDraftDiscard,
          onPressed: discardDraft,
        ),
      ));
  }

  void discardDraft() {
    final draft = _draft;
    final original = _original;
    if (draft == null || original == null) return;
    _sent = null;
    unawaited(draft.discard());
    if (mounted) setState(() => restoreDraft(original));
  }

  void saveDraftNow() {
    final draft = _draft;
    if (draft != null) unawaited(draft.flush());
  }

  void closeDraft() {
    final draft = _draft;
    if (draft != null) unawaited(draft.finish());
  }

  void closeDraftWhen(Future<bool> saved) {
    final draft = _draft;
    if (draft == null) return;
    unawaited(draft.flush());
    unawaited(saved.then((ok) {
      if (ok) unawaited(draft.finish());
    }, onError: (Object _) {}));
  }

  void _draftChanged() {
    final draft = _draft;
    final original = _original;
    if (draft == null || original == null || draft.isFinished) return;
    final now = captureDraft();
    final next = sameDraft(now, original) ? null : now;
    if (sameDraft(next, _sent)) return;
    _sent = next;
    draft.schedule(next);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _draftChanged();
  }

  @override
  void dispose() {
    for (final field in _watched) {
      field.removeListener(_draftChanged);
    }
    final draft = _draft;
    if (draft != null) unawaited(draft.flush());
    super.dispose();
  }
}
