import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

// ─── Status Chips ───────────────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora')),
      );
}

// ─── Stat Card ───────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary;
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontFamily: 'Sora')),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 13, color: subColor, fontFamily: 'Sora')),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: TextStyle(fontSize: 11, color: subColor)),
                  ],
                ),
              ],
            ),
          ])),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyState(
      {super.key,
      required this.title,
      this.subtitle,
      required this.icon,
      this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(icon,
                      size: 36,
                      color: Theme.of(context).textTheme.bodySmall?.color)),
              const SizedBox(height: 16),
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center)
              ],
              if (action != null) ...[const SizedBox(height: 24), action!],
            ])));
  }
}

// ─── Loading / Error ─────────────────────────────────────────────
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => Center(
      child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary));
}

class ErrorWidget2 extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidget2({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'))
            ],
          ])));
}

// ─── Confirm Dialog ───────────────────────────────────────────────
Future<bool> showConfirmDialog(BuildContext context,
    {required String title,
    required String content,
    String confirmLabel = 'Delete',
    Color confirmColor = AppColors.error}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style:
              const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}

// ─── Formatters ──────────────────────────────────────────────────
String formatPrice(double price) {
  if (price >= 1000000) return '\$${(price / 1000000).toStringAsFixed(1)}M';
  if (price >= 1000) return '\$${NumberFormat('#,##0', 'en_US').format(price)}';
  return '\$${price.toStringAsFixed(0)}';
}

String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
String formatDateTime(DateTime dt) =>
    DateFormat('MMM d, yyyy • h:mm a').format(dt);
