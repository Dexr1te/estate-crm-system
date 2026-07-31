import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class BrandMark extends StatelessWidget {
  final double size;

  final double? radius;

  const BrandMark({super.key, this.size = 62, this.radius});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.isDark ? t.surfaceVariant : t.primary,
        borderRadius: BorderRadius.circular(radius ?? size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          text: 'e',
          children: [
            TextSpan(text: '.', style: TextStyle(color: t.accent)),
          ],
        ),
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: size * 0.48,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: -size * 0.016,
          color: const Color(0xFFF0F2FF),
        ),
      ),
    );
  }
}

class BrandWordmark extends StatelessWidget {
  final double fontSize;
  const BrandWordmark({super.key, this.fontSize = 19});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text.rich(
      TextSpan(
        text: 'EstateCRM',
        children: [
          TextSpan(text: '.', style: TextStyle(color: t.accent)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: fontSize,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: -fontSize * 0.03,
        color: t.textPrimary,
      ),
    );
  }
}

class CenteredScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const CenteredScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  padding.resolve(Directionality.of(context)).vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [child],
            ),
          ),
        ),
      );
}
