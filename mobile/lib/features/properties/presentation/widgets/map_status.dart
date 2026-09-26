import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_map_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One line over the top of the map: a skeleton while the first pins come,
/// or why the map looks the way it does (nothing here, too many to draw,
/// failed to load). Silent when the pins speak for themselves.
class MapStatus extends StatelessWidget {
  final PropertiesMapState state;
  final VoidCallback onRetry;

  const MapStatus({super.key, required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (state.load) {
      case MapLoad.idle:
      case MapLoad.loading:
        if (state.listings.isNotEmpty) return const SizedBox.shrink();
        return Semantics(
          label: l10n.propertiesMapLoading,
          child: const ShimmerGroup(
            key: ValueKey('map-loading'),
            child: ShimmerBox(width: 150, height: 32, radius: 16),
          ),
        );
      case MapLoad.failed:
        return _Pill(
          key: const ValueKey('map-failed'),
          text: apiFailureLabel(l10n, state.failure!),
          action: l10n.coreRetry,
          onTap: onRetry,
        );
      case MapLoad.loaded:
        if (state.capped) {
          return _Pill(
              key: const ValueKey('map-capped'),
              text: l10n.propertiesMapCapped(state.listings.length));
        }
        if (state.listings.isEmpty) {
          return _Pill(
              key: const ValueKey('map-empty'), text: l10n.propertiesMapEmpty);
        }
        return const SizedBox.shrink();
    }
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onTap;

  const _Pill({super.key, required this.text, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
              ),
              if (action != null) ...[
                const SizedBox(width: 10),
                Text(action!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: t.primary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
