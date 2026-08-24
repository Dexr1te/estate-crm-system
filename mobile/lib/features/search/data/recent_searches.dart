import 'package:shared_preferences/shared_preferences.dart';

/// The last few queries that actually led somewhere, newest first.
///
/// Only a query someone opened a result from is kept. Recording every
/// debounced keystroke instead would fill the list with the prefixes of one
/// search — "a", "ai", "aig" — and bury the searches worth offering back.
class RecentSearches {
  static const _key = 'recent_searches';
  static const max = 5;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> remember(String query) async {
    final q = query.trim();
    if (q.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final kept = [
      q,
      // Case-insensitively, so re-running a search moves it to the front
      // instead of listing it twice.
      ...(prefs.getStringList(_key) ?? const [])
          .where((e) => e.toLowerCase() != q.toLowerCase()),
    ].take(max).toList();

    await prefs.setStringList(_key, kept);
    return kept;
  }

  Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return const [];
  }
}
