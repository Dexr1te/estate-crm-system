import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_card.dart';
import 'package:real_estate_crm/core/widgets/app_text.dart';
import 'package:real_estate_crm/core/widgets/row_chevron.dart';
import 'package:real_estate_crm/core/widgets/text_measure.dart';

class SettingsGroup extends StatelessWidget {
  final List<Widget> rows;
  const SettingsGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Container(height: 1, color: t.border),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String label;
  final Widget child;

  const SettingsSection({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EyebrowLabel(label),
          const SizedBox(height: 8),
          child,
        ],
      );
}

class SettingsRow extends StatelessWidget {
  final String label;
  final String? subLabel;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const SettingsRow({
    super.key,
    required this.label,
    this.subLabel,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: t.textPrimary),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 3),
          Text(
            subLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11,
                color: t.textSecondary),
          ),
        ],
      ],
    );
    final chevron = [
      if (showChevron) ...[const SizedBox(width: 8), const RowChevron()],
    ];

    final Widget row;
    if (trailing == null && value != null) {
      final valueStyle = TextStyle(
          fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
      row = LayoutBuilder(builder: (context, constraints) {
        final valueWidth = singleLineTextWidth(context, value!, valueStyle);
        final labelMax = constraints.maxWidth -
            12 -
            math.min(valueWidth, constraints.maxWidth * 0.35) -
            (showChevron ? 8 + RowChevron.size : 0);
        return Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: math.max(0, labelMax)),
              child: labels,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value!,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            ),
            ...chevron,
          ],
        );
      });
    } else {
      row = Row(
        children: [
          Expanded(child: labels),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ...chevron,
        ],
      );
    }

    final body = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppMetrics.cardPadding(context), vertical: 14),
      child: row,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: body),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? t.onPrimary
              : (t.isDark ? t.textSecondary : t.surface)),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? t.primary
              : (t.isDark ? t.textHint : t.border)),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? t.primary
              : (t.isDark ? t.textHint : t.border)),
    );
  }
}
