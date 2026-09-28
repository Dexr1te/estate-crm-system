import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/route_map.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Kilometres with one decimal, in the reader's own decimal mark.
String formatKm(double km, String locale) =>
    NumberFormat('0.0', locale).format(km);

/// "40 min", "1 h", "1 h 20 min".
String formatGap(AppLocalizations l10n, Duration d) {
  final minutes = d.inMinutes.abs();
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.routeDurationMin(m);
  if (m == 0) return l10n.routeDurationHours(h);
  return l10n.routeDurationHourMin(h, m);
}

StatusHue viewingOutcomeHue(ViewingOutcome o) => switch (o) {
      ViewingOutcome.INTERESTED => StatusHue.positive,
      ViewingOutcome.REJECTED => StatusHue.danger,
      ViewingOutcome.NO_SHOW => StatusHue.neutral,
    };

/// What the listing is called and where, for a row.
String stopPlace(MeetingResponse m) => [
      m.propertyTitle ?? '',
      m.propertyAddress ?? '',
    ].where((s) => s.trim().isNotEmpty).join(' · ');

/// One stop in the list: its number, time, client and listing, how far it
/// is from the one before, and whether it is done.
class RouteStopRow extends StatelessWidget {
  final RouteLeg? leg;
  final RouteStop stop;
  final DateTime now;
  final bool isNext;
  final VoidCallback onTap;
  final Widget? footer;

  const RouteStopRow({
    super.key,
    required this.stop,
    required this.now,
    required this.onTap,
    this.leg,
    this.isNext = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final m = stop.meeting;
    final over = stop.isPast(now) || stop.isDone;
    final km = leg?.kmFromPrevious;
    final place = stopPlace(m);
    final outcome = m.outcome;

    TextStyle style(double size, Color color, [FontWeight? w]) => TextStyle(
        fontFamily: AppFonts.sans, fontSize: size, color: color, fontWeight: w);

    final row = AppCard(
      radius: 14,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leg != null) ...[
            StopNumber(number: leg!.number, muted: over, highlighted: isNext),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [formatTimeOfDay(m.scheduledAt), m.clientName]
                      .where((s) => s.trim().isNotEmpty)
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(14, t.textPrimary, FontWeight.w600),
                ),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(place,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: style(12.5, t.textSecondary)),
                ],
                if (km != null) ...[
                  const SizedBox(height: 3),
                  Text(l10n.routeFromPrevious(formatKm(km, locale)),
                      key: ValueKey('route-km-${leg!.number}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style(12, t.textHint)),
                ],
                if (outcome != null || m.completed || isNext) ...[
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: [
                    if (isNext)
                      StatusChip(label: l10n.routeNext, hue: StatusHue.lead),
                    if (outcome != null)
                      StatusChip(
                          label: viewingOutcomeLabel(l10n, outcome),
                          hue: viewingOutcomeHue(outcome))
                    else if (m.completed)
                      StatusChip(label: l10n.routeDone, hue: StatusHue.neutral),
                  ]),
                ],
                if (footer != null) ...[const SizedBox(height: 10), footer!],
              ],
            ),
          ),
        ],
      ),
    );
    return over ? Opacity(opacity: 0.6, child: row) : row;
  }
}

/// Between two stops: the time until the next starts, or a warning that it
/// starts before this one can be over.
class RouteGap extends StatelessWidget {
  final RouteLeg leg;

  const RouteGap({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final gap = leg.untilNext;
    if (gap == null) return const SizedBox(height: 9);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 6, 0, 6),
      child: leg.overlapsNext
          ? Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                key: ValueKey('route-overlap-${leg.number}'),
                label: l10n.routeOverlap,
                hue: StatusHue.danger,
              ),
            )
          : Text(
              l10n.routeUntilNext(formatGap(l10n, gap)),
              key: ValueKey('route-gap-${leg.number}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  color: t.textSecondary),
            ),
    );
  }
}
