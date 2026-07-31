import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Status chip — radius 999, padding 4/9, font 600/10, **no shadow**.
///
/// Light draws a solid pastel fill; dark keeps the same hue at low alpha with
/// a lightened label. Colour here signals status and nothing else.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusHue hue;
  const StatusChip({super.key, required this.label, required this.hue});

  @override
  Widget build(BuildContext context) {
    final p = StatusPalette.resolve(context.tokens, hue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: p.fill,
        borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: p.label,
        ),
      ),
    );
  }
}

/// The admin role chip: navy fill with a gold label in light, inverted in
/// dark so gold stays the single accent.
class BrandChip extends StatelessWidget {
  final String label;
  const BrandChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: t.isDark ? t.accent : t.primary,
        borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: t.isDark ? t.onAccent : t.accent,
        ),
      ),
    );
  }
}

StatusHue dealStatusHue(DealStatus status) {
  switch (status) {
    case DealStatus.LEAD:
      return StatusHue.lead;
    case DealStatus.NEGOTIATION:
      return StatusHue.negotiation;
    case DealStatus.CLOSED_WON:
      return StatusHue.positive;
    case DealStatus.CLOSED_LOST:
      return StatusHue.danger;
  }
}

String dealStatusLabel(AppLocalizations l10n, DealStatus status) {
  switch (status) {
    case DealStatus.LEAD:
      return l10n.coreStatusLead;
    case DealStatus.NEGOTIATION:
      return l10n.coreStatusNegotiation;
    case DealStatus.CLOSED_WON:
      return l10n.coreStatusWon;
    case DealStatus.CLOSED_LOST:
      return l10n.coreStatusLost;
  }
}

StatusHue propertyStatusHue(PropertyStatus status) {
  switch (status) {
    case PropertyStatus.AVAILABLE:
      return StatusHue.positive;
    case PropertyStatus.RESERVED:
      return StatusHue.negotiation;
    case PropertyStatus.SOLD:
      return StatusHue.lead;
  }
}

String propertyStatusLabel(AppLocalizations l10n, PropertyStatus status) {
  switch (status) {
    case PropertyStatus.AVAILABLE:
      return l10n.coreStatusAvailable;
    case PropertyStatus.RESERVED:
      return l10n.coreStatusReserved;
    case PropertyStatus.SOLD:
      return l10n.coreStatusSold;
  }
}

/// Role names must never render as raw enum values.
String roleLabel(AppLocalizations l10n, Role role) {
  switch (role) {
    case Role.ADMIN:
      return l10n.coreRoleAdmin;
    case Role.MANAGER:
      return l10n.coreRoleManager;
    case Role.AGENT:
      return l10n.coreRoleAgent;
  }
}

/// Property types must never render as raw enum names.
String propertyTypeLabel(AppLocalizations l10n, PropertyType type) {
  switch (type) {
    case PropertyType.APARTMENT:
      return l10n.corePropertyTypeApartment;
    case PropertyType.HOUSE:
      return l10n.corePropertyTypeHouse;
    case PropertyType.COMMERCIAL:
      return l10n.corePropertyTypeCommercial;
    case PropertyType.LAND:
      return l10n.corePropertyTypeLand;
    case PropertyType.OFFICE:
      return l10n.corePropertyTypeOffice;
  }
}

IconData propertyTypeIcon(PropertyType type) {
  switch (type) {
    case PropertyType.APARTMENT:
      return Icons.apartment_rounded;
    case PropertyType.HOUSE:
      return Icons.home_outlined;
    case PropertyType.COMMERCIAL:
      return Icons.storefront_outlined;
    case PropertyType.LAND:
      return Icons.landscape_outlined;
    case PropertyType.OFFICE:
      return Icons.business_outlined;
  }
}

String clientTypeLabel(AppLocalizations l10n, ClientType type) =>
    type == ClientType.BUYER
        ? l10n.coreClientTypeBuyer
        : l10n.coreClientTypeSeller;

class DealStatusChip extends StatelessWidget {
  final DealStatus status;
  const DealStatusChip({super.key, required this.status});
  @override
  Widget build(BuildContext context) => StatusChip(
        label: dealStatusLabel(AppLocalizations.of(context), status),
        hue: dealStatusHue(status),
      );
}

class PropertyStatusChip extends StatelessWidget {
  final PropertyStatus status;
  const PropertyStatusChip({super.key, required this.status});
  @override
  Widget build(BuildContext context) => StatusChip(
        label: propertyStatusLabel(AppLocalizations.of(context), status),
        hue: propertyStatusHue(status),
      );
}

class ClientTypeChip extends StatelessWidget {
  final ClientType type;
  const ClientTypeChip({super.key, required this.type});
  @override
  Widget build(BuildContext context) => StatusChip(
        label: clientTypeLabel(AppLocalizations.of(context), type),
        // Buyers read as leads (violet), sellers as in-negotiation (amber) —
        // the same two hues the deal pipeline already uses.
        hue: type == ClientType.BUYER ? StatusHue.lead : StatusHue.negotiation,
      );
}
