import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/open_house_labels.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/schedule_open_house_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many past open houses the card shows before "Show all".
const _pastShown = 3;

/// A listing's open houses on its detail screen: the ones to come, soonest
/// first, then the ones held, latest first, each with its count of visitors.
/// Reads on its own, so the detail screen only has to place it.
class PropertyOpenHousesCard extends StatefulWidget {
  final int propertyId;

  const PropertyOpenHousesCard({super.key, required this.propertyId});

  @override
  State<PropertyOpenHousesCard> createState() => _PropertyOpenHousesCardState();
}

class _PropertyOpenHousesCardState extends State<PropertyOpenHousesCard> {
  List<OpenHouse>? _openHouses;
  bool _allPast = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<OpenHouse> found;
    try {
      found =
          await Injector.openHousesRepository.getForProperty(widget.propertyId);
    } catch (_) {
      found = const [];
    }
    if (mounted) setState(() => _openHouses = found);
  }

  Future<void> _schedule() async {
    final saved = await showScheduleOpenHouseSheet(context,
        propertyId: widget.propertyId);
    if (saved == null || !mounted) return;
    await _open(saved);
  }

  Future<void> _open(OpenHouse o) async {
    await context.push('/open-houses/${o.id}');
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final all = _openHouses;
    if (all == null) {
      return const ShimmerGroup(
          child: ShimmerInfoCard(rows: 2, heading: true, buttons: 1));
    }

    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final upcoming = all.where((o) => !o.isOver(now)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final past = all.where((o) => o.isOver(now)).toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    final pastShown = _allPast ? past : past.take(_pastShown).toList();

    return AppCard(
      key: const ValueKey('property-open-houses'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.openHousesCardTitle)),
              Text('${all.length}',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (all.isEmpty)
            Text(
              l10n.openHouseNone,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  color: t.textSecondary),
            ),
          if (upcoming.isNotEmpty) ...[
            _Heading(l10n.openHouseUpcoming),
            for (final o in upcoming) ...[
              const SizedBox(height: 8),
              OpenHouseRow(openHouse: o, now: now, onTap: () => _open(o)),
            ],
          ],
          if (pastShown.isNotEmpty) ...[
            if (upcoming.isNotEmpty) const SizedBox(height: 14),
            _Heading(l10n.openHousePast),
            for (final o in pastShown) ...[
              const SizedBox(height: 8),
              OpenHouseRow(openHouse: o, now: now, onTap: () => _open(o)),
            ],
            if (past.length > pastShown.length) ...[
              const SizedBox(height: 4),
              AppGhostButton(
                key: const ValueKey('open-houses-show-all'),
                label: l10n.openHouseSeeAll,
                height: AppMetrics.minHitTarget,
                fontSize: 12.5,
                onPressed: () => setState(() => _allPast = true),
              ),
            ],
          ],
          const SizedBox(height: 12),
          AppGhostButton(
            key: const ValueKey('open-house-schedule'),
            label: l10n.openHouseSchedule,
            icon: Icons.event_available_outlined,
            onPressed: _schedule,
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: context.tokens.textSecondary),
      );
}

/// One open house in a list: when, and how many came or that it is on now.
class OpenHouseRow extends StatelessWidget {
  final OpenHouse openHouse;
  final DateTime now;
  final VoidCallback onTap;

  const OpenHouseRow({
    super.key,
    required this.openHouse,
    required this.now,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = openHouse;
    final host = o.agentName?.trim();

    return AppCard(
      key: ValueKey('open-house-row-${o.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  openHouseWhen(o, locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    l10n.openHouseVisitorsCount(o.visitorCount),
                    if (host != null && host.isNotEmpty) host,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          if (o.isOn(now)) ...[
            const SizedBox(width: 8),
            Flexible(
              child: StatusChip(
                  label: l10n.openHouseLive, hue: StatusHue.positive),
            ),
          ] else
            Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
        ],
      ),
    );
  }
}
