import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

class DealStatusChip extends StatelessWidget {
  final DealStatus status;
  const DealStatusChip({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case DealStatus.LEAD:
        color = AppColors.lead;
        label = 'Lead';
        break;
      case DealStatus.NEGOTIATION:
        color = AppColors.negotiation;
        label = 'Negotiation';
        break;
      case DealStatus.CLOSED_WON:
        color = AppColors.closedWon;
        label = 'Won';
        break;
      case DealStatus.CLOSED_LOST:
        color = AppColors.closedLost;
        label = 'Lost';
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
    Color color;
    String label;
    switch (status) {
      case PropertyStatus.AVAILABLE:
        color = AppColors.available;
        label = 'Available';
        break;
      case PropertyStatus.RESERVED:
        color = AppColors.reserved;
        label = 'Reserved';
        break;
      case PropertyStatus.SOLD:
        color = AppColors.sold;
        label = 'Sold';
        break;
    }
    return _StatusChip(label: label, color: color);
  }
}

class ClientTypeChip extends StatelessWidget {
  final ClientType type;
  const ClientTypeChip({super.key, required this.type});
  @override
  Widget build(BuildContext context) => _StatusChip(
        label: type == ClientType.BUYER ? 'Buyer' : 'Seller',
        color: type == ClientType.BUYER ? AppColors.info : AppColors.accent,
      );
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
