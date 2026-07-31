import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  final String? trailingText;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final trailingStyle = TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: t.textSecondary,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: t.textPrimary,
            ),
          ),
        ),
        if (trailingText != null)
          Text(trailingText!, style: trailingStyle)
        else if (actionLabel != null && onAction != null)
          _Tappable(
            onTap: onAction!,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(actionLabel!, style: trailingStyle),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded,
                  size: 13, color: t.textSecondary),
            ]),
          ),
      ],
    );
  }
}

class EyebrowLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const EyebrowLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: color ?? t.accent,
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  final bool reserveSubtitle;

  const ScreenTitle(
    this.title, {
    super.key,
    this.subtitle,
    this.reserveSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 24,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: t.textPrimary,
          ),
        ),
        if (subtitle != null || reserveSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            subtitle ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12,
              color: t.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: trailing ??
              Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: t.textPrimary,
                ),
              ),
        ),
      ],
    );
  }
}

class DetailCell extends StatelessWidget {
  final String label;
  final String value;
  const DetailCell({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11,
                color: t.textSecondary)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.textPrimary)),
      ],
    );
  }
}

class DetailGrid extends StatelessWidget {
  final List<DetailCell> cells;
  const DetailGrid({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final single =
        MediaQuery.sizeOf(context).width < AppMetrics.singleColumnBreakpoint;
    if (single) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(height: 13),
            cells[i],
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var row = 0; row < (cells.length + 1) ~/ 2; row++) ...[
          if (row > 0) const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cells[row * 2]),
              const SizedBox(width: 10),
              Expanded(
                child: row * 2 + 1 < cells.length
                    ? cells[row * 2 + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Tappable extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Tappable({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: child,
          ),
        ),
      );
}
