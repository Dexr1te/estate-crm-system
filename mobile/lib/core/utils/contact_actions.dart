import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef UrlOpener = Future<bool> Function(Uri uri, LaunchMode mode);

Future<bool> _launch(Uri uri, LaunchMode mode) => launchUrl(uri, mode: mode);

class ContactActions {
  const ContactActions._();

  /// What actually hands a link to the phone. Tests swap it for a recorder so
  /// a tap on Call can be followed without a dialer.
  static UrlOpener opener = _launch;

  @visibleForTesting
  static void resetOpener() => opener = _launch;

  static Future<bool> call(String? phone) =>
      _open('tel', phone, strip: RegExp(r'[^\d+]'));

  static Future<bool> email(String? address) => _open('mailto', address);

  static Future<bool> directions(String? address) async {
    if (address == null || address.trim().isEmpty) return false;
    final uri = Uri.parse(
        'https://maps.google.com/?q=${Uri.encodeComponent(address.trim())}');
    return opener(uri, LaunchMode.externalApplication);
  }

  static Future<bool> whatsApp(String? phone, String text) async {
    final digits = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return false;
    final uri = Uri.https('wa.me', '/$digits', {'text': text});
    try {
      return await opener(uri, LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _open(String scheme, String? raw, {RegExp? strip}) async {
    if (raw == null || raw.trim().isEmpty) return false;
    final value = strip == null ? raw.trim() : raw.replaceAll(strip, '');
    if (value.isEmpty) return false;
    try {
      return await opener(
          Uri(scheme: scheme, path: value), LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }
}

void showActionUnavailable(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
