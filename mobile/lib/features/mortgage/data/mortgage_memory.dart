import 'dart:convert';

import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The rate, term, payment type and down payment each person used last,
/// kept on this phone.
class MortgageMemory {
  MortgageMemory._();

  static String key(int userId) => 'mortgage_last_$userId';

  static Future<MortgageSettings?> read(int? userId) async {
    if (userId == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key(userId));
      if (raw == null) return null;
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return MortgageSettings.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(int? userId, MortgageSettings settings) async {
    if (userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key(userId), jsonEncode(settings.toJson()));
    } catch (_) {}
  }
}
