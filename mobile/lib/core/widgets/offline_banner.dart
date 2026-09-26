import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "14:32" today, "12 Sep, 14:32" on any other day.
String offlineSinceLabel(DateTime savedAt, String locale) {
  final now = AppClock.now();
  final local = savedAt.toLocal();
  final sameDay = now.year == local.year &&
      now.month == local.month &&
      now.day == local.day;
  final time = formatTimeOfDay(local);
  return sameDay ? time : '${formatDayMonth(local, locale)}, $time';
}

/// Wraps the whole app: while [status] holds a time, what is on screen came
/// from the offline cache, and a slim strip across the top says so — once,
/// for every screen, with a way to try the network again.
class OfflineBanner extends StatelessWidget {
  final ValueListenable<DateTime?> status;
  final VoidCallback onRetry;
  final Widget child;

  const OfflineBanner({
    super.key,
    required this.status,
    required this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: status,
      child: child,
      builder: (context, since, app) {
        final stale = since != null;
        return Column(children: [
          if (stale) _Strip(since: since, onRetry: onRetry),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: stale,
              child: app!,
            ),
          ),
        ]);
      },
    );
  }
}

class _Strip extends StatelessWidget {
  final DateTime since;
  final VoidCallback onRetry;
  const _Strip({required this.since, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final tone = StatusPalette.resolve(t, StatusHue.negotiation);
    final locale = Localizations.localeOf(context).languageCode;

    return Material(
      key: const Key('offline-banner'),
      color: tone.fill,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Row(children: [
            Icon(Icons.cloud_off_rounded, size: 16, color: tone.label),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.coreOfflineSince(offlineSinceLabel(since, locale)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: tone.label,
                ),
              ),
            ),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppMetrics.minHitTarget,
                  minWidth: AppMetrics.minHitTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      l10n.coreRetry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
