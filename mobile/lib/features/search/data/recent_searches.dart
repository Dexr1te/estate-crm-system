import 'package:shared_preferences/shared_preferences.dart';

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
