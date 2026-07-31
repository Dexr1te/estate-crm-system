import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactActions {
  const ContactActions._();

  static Future<bool> call(String? phone) =>
      _open('tel', phone, strip: RegExp(r'[^\d+]'));

  static Future<bool> email(String? address) => _open('mailto', address);

  static Future<bool> directions(String? address) async {
    if (address == null || address.trim().isEmpty) return false;
    final uri = Uri.parse(
        'https://maps.google.com/?q=${Uri.encodeComponent(address.trim())}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> _open(String scheme, String? raw, {RegExp? strip}) async {
    if (raw == null || raw.trim().isEmpty) return false;
    final value = strip == null ? raw.trim() : raw.replaceAll(strip, '');
    if (value.isEmpty) return false;
    try {
      return await launchUrl(Uri(scheme: scheme, path: value));
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
