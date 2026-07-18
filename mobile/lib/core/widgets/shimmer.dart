import 'package:flutter/material.dart';
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
