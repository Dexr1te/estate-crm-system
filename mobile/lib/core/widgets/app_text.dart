import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

/// Section header — font 600/14 in textPrimary, with an optional trailing
/// "Все →" / "All →" link at 600/12 in textSecondary.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// A plain count or total shown instead of a tappable link.
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

/// Eyebrow label — font 600/10.5, letter-spacing 1.1, uppercase, accent
/// colour. Marks the top of a card section.
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

/// Screen title — font 700/24, letter-spacing -0.5, with an optional counter
/// line beneath it.
class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const ScreenTitle(this.title, {super.key, this.subtitle});

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
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
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

/// A label → value row inside a card. Label 400/12.5 secondary on the left,
/// value 500/12.5 primary on the right.
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
        // Both sides give way: a long translated label wraps rather than
        // pushing the value off the card.
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

/// One cell of the 2-column detail grid: caption 400/11 above value 600/13.
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
                fontFamily: AppFonts.sans, fontSize: 11, color: t.textSecondary)),
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

/// A 2-column grid of [DetailCell]s that collapses to a single column below
/// 340pt.
class DetailGrid extends StatelessWidget {
  final List<DetailCell> cells;
  const DetailGrid({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final single = MediaQuery.sizeOf(context).width <
        AppMetrics.singleColumnBreakpoint;
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
