import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What [ComparisonTray.toggle] did.
enum TrayChange { added, removed, full }

/// The listings an agent set aside for comparison from their detail pages.
/// It lives for the session and is kept per user on the device, so it comes
/// back after a restart but never shows one agent another's picks.
class ComparisonTray extends ChangeNotifier {
  /// Whose tray this is; null when nobody is signed in, which keeps it in
  /// memory only.
  final String? Function() scope;

  ComparisonTray({required this.scope});

  List<int> _ids = const [];
  String? _loadedFor;

  List<int> get ids => _ids;
  int get length => _ids.length;
  bool get isFull => _ids.length >= kMaxCompared;
  bool contains(int id) => _ids.contains(id);

  String? get _key {
    final s = scope();
    return s == null ? null : 'compare_tray:$s';
  }

  /// Reads the saved tray for whoever is signed in now. A different account
  /// starts from its own tray, not the last one's.
  Future<void> load() async {
    final key = _key;
    if (key == _loadedFor) return;
    _loadedFor = key;
    var saved = const <int>[];
    if (key != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        saved =
            parseCompareIds((prefs.getStringList(key) ?? const []).join(','));
      } catch (_) {}
    }
    if (_loadedFor != key) return;
    _ids = saved;
    notifyListeners();
  }

  TrayChange toggle(int id) {
    if (contains(id)) {
      _set([
        for (final i in _ids)
          if (i != id) i
      ]);
      return TrayChange.removed;
    }
    if (isFull) return TrayChange.full;
    _set([..._ids, id]);
    return TrayChange.added;
  }

  void remove(int id) {
    if (!contains(id)) return;
    _set([
      for (final i in _ids)
        if (i != id) i
    ]);
  }

  void clear() => _set(const []);

  void _set(List<int> ids) {
    _ids = List.unmodifiable(ids);
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final key = _key;
    if (key == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_ids.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setStringList(key, [for (final id in _ids) '$id']);
      }
    } catch (_) {}
  }
}
