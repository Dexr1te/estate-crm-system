import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/route/domain/maps_links.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands [link] to the phone: the app's own scheme first, the web link if
/// that does not open. There is no `canLaunchUrl` check on purpose: on iOS it
/// answers false for any scheme not listed in Info.plist, and on Android 11+
/// without a `<queries>` entry, while `launchUrl` itself opens the app fine
/// or fails, which is when the fallback runs. Goes through
/// [ContactActions.opener] so tests can watch it.
Future<bool> openMapsLink(MapsLink link) async {
  try {
    if (await ContactActions.opener(
        link.primary, LaunchMode.externalApplication)) {
      return true;
    }
  } catch (_) {
    // The app is not installed; the web link below may still open.
  }
  final fallback = link.fallback;
  if (fallback == null) return false;
  try {
    return await ContactActions.opener(
        fallback, LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
