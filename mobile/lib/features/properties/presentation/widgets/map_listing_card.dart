import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_map_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The listing a tapped pin stands for, over the bottom of the map: enough to
/// decide whether to open it, and a tap opens it.
class MapListingCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap;

  const MapListingCard(
      {super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      key: ValueKey('map-card-${property.id}'),
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PropertyCover.of(property, size: 64, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                const SizedBox(height: 3),
                Text(formatPrice(property.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.textPrimary)),
                const SizedBox(height: 3),
                Text(propertySpecs(l10n, property),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textSecondary)),
                const SizedBox(height: 6),
                PropertyStatusChip(status: property.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "N listings have no location": the ones the map cannot draw, and a way to
/// see which.
class UnpinnedHint extends StatelessWidget {
  final int count;
  final PropertiesRepository repository;
  final MapFilters filters;

  const UnpinnedHint({
    super.key,
    required this.count,
    required this.repository,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      child: InkWell(
        key: const ValueKey('map-unpinned-hint'),
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        onTap: () => _showList(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.location_off_outlined,
                  size: 18, color: t.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.propertiesMapUnpinned(count),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: t.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showAppBottomSheet<void>(
      context,
      title: l10n.propertiesMapUnpinnedTitle,
      subtitle: l10n.propertiesMapUnpinnedHint,
      builder: (ctx) => _UnpinnedList(
        load: repository.getPropertiesWithoutLocation(
            status: filters.status,
            type: filters.type,
            search: filters.search,
            size: 50),
        onOpen: (p) {
          Navigator.pop(ctx);
          context.go('/properties/${p.id}');
        },
      ),
    );
  }
}

class _UnpinnedList extends StatelessWidget {
  final Future<PagedResponse<PropertyResponse>> load;
  final ValueChanged<PropertyResponse> onOpen;

  const _UnpinnedList({required this.load, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<PagedResponse<PropertyResponse>>(
      future: load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ShimmerGroup(
            child: Column(children: [
              PropertyCardBone(),
              SizedBox(height: 9),
              PropertyCardBone(),
            ]),
          );
        }
        final items = snapshot.data?.content;
        if (items == null) {
          return ErrorWidget2(
              message: apiFailureLabel(
                  l10n, ApiFailure.from(snapshot.error ?? StateError(''))));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final p in items) ...[
              PropertyCard(property: p, onTap: () => onOpen(p)),
              const SizedBox(height: 9),
            ],
          ],
        );
      },
    );
  }
}
