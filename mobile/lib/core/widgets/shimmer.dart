import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:shimmer/shimmer.dart';

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

/// Wraps any tree of [ShimmerBox] bones in the app's shimmer sweep. The single
/// place the base/highlight colours are defined.
class ShimmerGroup extends StatelessWidget {
  final Widget child;
  const ShimmerGroup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Shimmer.fromColors(
      baseColor: t.isDark ? t.surfaceVariant : t.border,
      highlightColor:
          t.isDark ? const Color(0xFF353B52) : const Color(0xFFF5F7FC),
      child: child,
    );
  }
}

/// Wraps a list of skeleton cards in a Shimmer effect.
class ShimmerList extends StatelessWidget {
  final Widget Function() cardBuilder;
  final int count;
  final EdgeInsetsGeometry? padding;
  const ShimmerList(
      {super.key, required this.cardBuilder, this.count = 6, this.padding});

  @override
  Widget build(BuildContext context) => ShimmerGroup(
        child: ListView.separated(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, __) => cardBuilder(),
        ),
      );
}
