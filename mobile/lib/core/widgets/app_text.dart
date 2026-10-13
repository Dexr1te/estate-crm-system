import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_surface.dart';
import 'package:real_estate_crm/core/widgets/hit_slop.dart';
import 'package:real_estate_crm/core/widgets/row_chevron.dart';

const _sectionLink = #sectionHeaderLink;

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  final String? trailingText;

  final int? count;
  final bool countIsAlert;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailingText,
    this.count,
    this.countIsAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final trailingStyle = TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: AppType.subhead,
      fontWeight: FontWeight.w500,
      color: t.textSecondary,
    );

    final link =
        trailingText == null && actionLabel != null && onAction != null;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: t.textPrimary,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                _CountChip(count: count!, alert: countIsAlert),
              ],
            ],
          ),
        ),
        if (trailingText != null) ...[
          const SizedBox(width: 12),
          Text(trailingText!, style: trailingStyle),
        ] else if (link) ...[
          const SizedBox(width: 8),
          MetaData(
            metaData: _sectionLink,
            child: _Tappable(
              onTap: onAction!,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(actionLabel!,
                    style: trailingStyle.copyWith(color: t.primary)),
                const SizedBox(width: 2),
                RowChevron(color: t.primary),
              ]),
            ),
          ),
        ],
      ],
    );

    return link
        ? HitSlop(minWidth: 0, target: _sectionLink, child: header)
        : header;
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final bool alert;
  const _CountChip({required this.count, required this.alert});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: alert ? t.dangerFill : AppSurface.fillOf(context),
        borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: alert ? t.dangerText : t.textSecondary,
        ),
      ),
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
        fontSize: AppType.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: color ??
            (AppSurface.levelOf(context) == SurfaceLevel.hero
                ? t.heroTextMuted
                : t.textSecondary),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  final bool reserveSubtitle;

  final Widget? trailing;

  const ScreenTitle(
    this.title, {
    super.key,
    this.subtitle,
    this.reserveSubtitle = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final heading = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 28,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: t.textPrimary,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trailing == null)
          heading
        else
          Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 12),
              trailing!,
            ],
          ),
        if (subtitle != null || reserveSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            subtitle ?? ' ',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: AppType.subhead,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: AppType.subhead,
                color: t.textSecondary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: trailing != null
              ? Align(
                  alignment: AlignmentDirectional.topEnd,
                  heightFactor: 1,
                  child: trailing,
                )
              : Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: AppType.body,
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
                fontSize: AppType.footnote,
                color: t.textSecondary)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: AppType.body,
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
            padding:
                const EdgeInsetsDirectional.only(start: 4, top: 6, bottom: 6),
            child: child,
          ),
        ),
      );
}
