import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealStatusChip extends StatelessWidget {
  final DealStatus status;
  const DealStatusChip({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;
    switch (status) {
      case DealStatus.LEAD:
        color = AppColors.lead;
        label = l10n.coreStatusLead;
        break;
      case DealStatus.NEGOTIATION:
        color = AppColors.negotiation;
        label = l10n.coreStatusNegotiation;
        break;
      case DealStatus.CLOSED_WON:
        color = AppColors.closedWon;
        label = l10n.coreStatusWon;
        break;
      case DealStatus.CLOSED_LOST:
        color = AppColors.closedLost;
        label = l10n.coreStatusLost;
        break;
    }
    return _StatusChip(label: label, color: color);
  }
}

class PropertyStatusChip extends StatelessWidget {
  final PropertyStatus status;
  const PropertyStatusChip({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;
    switch (status) {
      case PropertyStatus.AVAILABLE:
        color = AppColors.available;
        label = l10n.coreStatusAvailable;
        break;
      case PropertyStatus.RESERVED:
        color = AppColors.reserved;
        label = l10n.coreStatusReserved;
        break;
      case PropertyStatus.SOLD:
        color = AppColors.sold;
        label = l10n.coreStatusSold;
        break;
    }
    return _StatusChip(label: label, color: color);
  }
}

class ClientTypeChip extends StatelessWidget {
  final ClientType type;
  const ClientTypeChip({super.key, required this.type});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StatusChip(
      label: type == ClientType.BUYER
          ? l10n.coreClientTypeBuyer
          : l10n.coreClientTypeSeller,
      color: type == ClientType.BUYER ? AppColors.info : AppColors.accent,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.16),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
                fontFamily: 'Sora')),
      );
}
