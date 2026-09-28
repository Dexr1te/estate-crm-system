import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/route/data/maps_launcher.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/domain/maps_links.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/route_stop_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String mapsAppLabel(AppLocalizations l10n, MapsApp app) => switch (app) {
      MapsApp.google => l10n.routeAppGoogle,
      MapsApp.yandex => l10n.routeAppYandex,
      MapsApp.dgis => l10n.routeAppDgis,
      MapsApp.apple => l10n.routeAppApple,
    };

/// Apple Maps comes with iOS; anywhere else it is not there to open.
bool get offersAppleMaps => defaultTargetPlatform == TargetPlatform.iOS;

/// Asks which maps app to open [stops] in: just the first of them when
/// [whole] is false (the next stop), else all of them in order.
Future<void> showMapsChooser(BuildContext context,
    {required List<RouteLeg> stops, required bool whole}) {
  final l10n = AppLocalizations.of(context);
  final title = stopPlace(stops.first.stop.meeting);
  return showAppBottomSheet<void>(
    context,
    title: l10n.routeChooserTitle,
    subtitle: whole
        ? l10n.routeChooserWhole
        : l10n.routeChooserNext(
            title.isEmpty ? stops.first.stop.meeting.title : title),
    builder: (_) => MapsChooser(stops: stops, whole: whole),
  );
}

class MapsChooser extends StatelessWidget {
  final List<RouteLeg> stops;
  final bool whole;

  const MapsChooser({super.key, required this.stops, required this.whole});

  Future<void> _open(BuildContext context, MapsChoice c) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final points = [
      for (final l in stops.sublist(c.first, c.last + 1)) l.point,
    ];
    final opened = await openMapsLink(mapsLink(c.app, points));
    if (navigator.mounted) navigator.pop();
    if (!opened) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.routeOpenFailed)));
    }
  }

  String? _subtitle(AppLocalizations l10n, MapsChoice c, bool split) {
    if (!whole) return null;
    if (!carriesWholeRoute(c.app)) return l10n.routeAppNextOnly;
    if (split) {
      return l10n.routeAppStops(
          stops[c.first].number, stops[c.last].number, stops.last.number);
    }
    return l10n.routeAppWhole;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final choices =
        mapsChoices(stops.length, whole: whole, includeApple: offersAppleMaps);
    final split = choices.where((c) => c.app == MapsApp.google).length > 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ChoiceRow(
            key: ValueKey(
                'route-app-${choices[i].app.name}-${choices[i].first}'),
            label: mapsAppLabel(l10n, choices[i].app),
            subtitle: _subtitle(l10n, choices[i], split),
            onTap: () => _open(context, choices[i]),
          ),
        ],
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ChoiceRow(
      {super.key, required this.label, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.map_outlined, size: 20, color: t.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12,
                          color: t.textSecondary)),
                ],
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, size: 18, color: t.textHint),
        ],
      ),
    );
  }
}
