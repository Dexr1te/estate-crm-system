import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

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
            color: color.withAlpha(38),
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
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontFamily: 'Sora')),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: subColor,
                              fontFamily: 'Sora')),
                      if (subtitle != null)
                        Text(subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: subColor)),
                    ],
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? const Color(0xFF252A3D) : const Color(0xFFEEF1F8);
    final iconColor =
        isDark ? const Color(0xFF4A5070) : const Color(0xFFADB5CC);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDark ? const Color(0xFFF0F2FF) : const Color(0xFF0F1E3C),
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? const Color(0xFF8B9CC8) : const Color(0xFF6B7A99),
        );

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: iconBg, borderRadius: BorderRadius.circular(20)),
                  child: Icon(icon, size: 36, color: iconColor)),
              const SizedBox(height: 16),
              Text(title, style: titleStyle, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!,
                    style: subtitleStyle, textAlign: TextAlign.center)
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

// ─── Shimmer Helpers ─────────────────────────────────────────────

/// A plain white box that becomes the shimmer "bone" shape.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox(
      {super.key, required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(radius)));
}

/// Wraps a list of skeleton cards in a Shimmer effect.
class ShimmerList extends StatelessWidget {
  final Widget Function() cardBuilder;
  final int count;
  const ShimmerList({super.key, required this.cardBuilder, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252A3D) : const Color(0xFFE8ECF4);
    final highlight =
        isDark ? const Color(0xFF353B52) : const Color(0xFFF5F7FC);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => cardBuilder(),
      ),
    );
  }
}

// ─── Skeleton Cards ───────────────────────────────────────────────

class ClientCardSkeleton extends StatelessWidget {
  const ClientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 60, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 120, height: 11, radius: 5),
            Spacer(),
            ShimmerBox(width: 60, height: 11, radius: 5),
          ]),
        ]),
      ),
    );
  }
}

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: ShimmerBox(width: 160, height: 14, radius: 7)),
            SizedBox(width: 12),
            ShimmerBox(width: 70, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 100, height: 11, radius: 5),
            SizedBox(width: 12),
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 80, height: 11, radius: 5),
          ]),
          SizedBox(height: 8),
          Row(children: [
            ShimmerBox(width: 80, height: 13, radius: 6),
            SizedBox(width: 12),
            ShimmerBox(width: 90, height: 11, radius: 5),
          ]),
          SizedBox(height: 4),
          ShimmerBox(width: 110, height: 11, radius: 5),
        ]),
      ),
    );
  }
}

class MeetingCardSkeleton extends StatelessWidget {
  const MeetingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 44, height: 44, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 20, height: 20, radius: 4),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 160, height: 12, radius: 6),
            SizedBox(width: 12),
            ShimmerBox(width: 14, height: 14, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 80, height: 12, radius: 6),
          ]),
        ]),
      ),
    );
  }
}

class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ShimmerBox(width: 44, height: 44, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 14, radius: 7),
                    SizedBox(height: 6),
                    ShimmerBox(width: 80, height: 11, radius: 5),
                  ]),
            ),
            ShimmerBox(width: 70, height: 22, radius: 12),
          ]),
          SizedBox(height: 10),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(children: [
            ShimmerBox(width: 90, height: 16, radius: 8),
            Spacer(),
            ShimmerBox(width: 55, height: 11, radius: 5),
            SizedBox(width: 8),
            ShimmerBox(width: 60, height: 11, radius: 5),
          ]),
          SizedBox(height: 6),
          Row(children: [
            ShimmerBox(width: 13, height: 13, radius: 4),
            SizedBox(width: 4),
            ShimmerBox(width: 180, height: 11, radius: 5),
          ]),
        ]),
      ),
    );
  }
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
