import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:shimmer/shimmer.dart';

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

class ShimmerBar extends StatelessWidget {
  final double widthFactor;
  final double height;
  const ShimmerBar({super.key, required this.widthFactor, this.height = 11});

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: ShimmerBox(
              width: double.infinity, height: height, radius: height / 2),
        ),
      );
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: size, height: size, radius: size / 2);
}

class ShimmerCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  const ShimmerCard({
    super.key,
    required this.child,
    this.height,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  });

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
}

class ShimmerRowCard extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final double titleFactor;
  final double subtitleFactor;

  const ShimmerRowCard({
    super.key,
    required this.leading,
    this.trailing = const ShimmerBox(width: 4, height: 16, radius: 2),
    this.titleFactor = 0.5,
    this.subtitleFactor = 0.72,
  });

  @override
  Widget build(BuildContext context) => ShimmerCard(
        height: 66,
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShimmerBar(widthFactor: titleFactor, height: 12),
                  const SizedBox(height: 8),
                  ShimmerBar(widthFactor: subtitleFactor, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      );
}

class ShimmerMetricsCard extends StatelessWidget {
  final int rows;
  const ShimmerMetricsCard({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < rows; i++)
              const Row(
                children: [
                  Expanded(child: _MetricCellBone()),
                  Expanded(child: _MetricCellBone()),
                ],
              ),
          ],
        ),
      );
}

class _MetricCellBone extends StatelessWidget {
  const _MetricCellBone();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShimmerBar(widthFactor: 0.34, height: 20),
            SizedBox(height: 8),
            ShimmerBar(widthFactor: 0.7, height: 10),
          ],
        ),
      );
}

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
      period: const Duration(milliseconds: 1100),
      child: child,
    );
  }
}

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

class ShimmerSectionHeader extends StatelessWidget {
  final double titleFactor;
  final bool hasAction;

  const ShimmerSectionHeader(
      {super.key, this.titleFactor = 0.42, this.hasAction = true});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: ShimmerBar(widthFactor: titleFactor, height: 13)),
          if (hasAction) const ShimmerBox(width: 54, height: 11, radius: 5.5),
        ],
      );
}

class ShimmerHeroCard extends StatelessWidget {
  final int lines;
  final int buttons;

  const ShimmerHeroCard({super.key, this.lines = 2, this.buttons = 2});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusLg,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShimmerBar(widthFactor: 0.3, height: 9),
            const SizedBox(height: 14),
            const ShimmerBar(widthFactor: 0.66, height: 17),
            for (var i = 0; i < lines; i++) ...[
              const SizedBox(height: 9),
              ShimmerBar(widthFactor: i.isEven ? 0.86 : 0.54, height: 10),
            ],
            if (buttons > 0) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var i = 0; i < buttons; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    const Expanded(
                        child: ShimmerBox(
                            width: double.infinity, height: 38, radius: 12)),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
}

class ShimmerField extends StatelessWidget {
  final double labelFactor;
  final double height;

  const ShimmerField({super.key, this.labelFactor = 0.3, this.height = 46});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBar(widthFactor: labelFactor, height: 9),
          const SizedBox(height: 9),
          ShimmerBox(
              width: double.infinity,
              height: height,
              radius: AppMetrics.radiusSm),
        ],
      );
}

class ShimmerFormCard extends StatelessWidget {
  final int fields;
  final bool heading;

  const ShimmerFormCard({super.key, this.fields = 3, this.heading = true});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (heading) ...[
              const ShimmerBar(widthFactor: 0.36, height: 11),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < fields; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              ShimmerField(labelFactor: i.isEven ? 0.3 : 0.24),
            ],
          ],
        ),
      );
}

class ShimmerInfoCard extends StatelessWidget {
  final int rows;
  final bool heading;

  final int buttons;

  const ShimmerInfoCard(
      {super.key, this.rows = 4, this.heading = false, this.buttons = 0});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (heading) ...[
              const ShimmerBar(widthFactor: 0.34, height: 11),
              const SizedBox(height: 14),
            ],
            for (var i = 0; i < rows; i++) ...[
              if (i > 0) const SizedBox(height: 15),
              Row(
                children: [
                  const SizedBox(
                      width: 92,
                      child: ShimmerBar(widthFactor: 0.82, height: 9)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShimmerBar(
                        widthFactor: [0.72, 0.46, 0.9, 0.58][i % 4],
                        height: 10),
                  ),
                ],
              ),
            ],
            if (buttons > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < buttons; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    const Expanded(
                        child: ShimmerBox(
                            width: double.infinity, height: 38, radius: 12)),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
}

class ShimmerChipRow extends StatelessWidget {
  final List<double> widths;
  const ShimmerChipRow({super.key, this.widths = const [76, 58]});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < widths.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            ShimmerBox(width: widths[i], height: 26, radius: 13),
          ],
        ],
      );
}

class ShimmerNestedListCard extends StatelessWidget {
  final int rows;
  final bool counted;

  const ShimmerNestedListCard({super.key, this.rows = 2, this.counted = true});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.all(AppMetrics.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                    child: ShimmerBar(widthFactor: 0.38, height: 10)),
                if (counted) const ShimmerBox(width: 14, height: 10, radius: 5),
              ],
            ),
            const SizedBox(height: 13),
            for (var i = 0; i < rows; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              ShimmerCard(
                radius: AppMetrics.radiusSm,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: ShimmerBar(
                                widthFactor: i.isEven ? 0.7 : 0.52,
                                height: 12)),
                        const SizedBox(width: 8),
                        const ShimmerBox(width: 56, height: 20, radius: 10),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                            child: ShimmerBar(
                                widthFactor: i.isEven ? 0.44 : 0.6,
                                height: 10)),
                        const SizedBox(width: 8),
                        const ShimmerBox(width: 68, height: 12, radius: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}
