import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_card.dart';

/// A grouped settings card — rows separated by 1px dividers inside a single
/// bordered card, as on the Profile screen.
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

/// One row of a [SettingsGroup]: label on the left (with an optional
/// sub-label), value or control on the right.
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

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                        color: t.textHint),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null)
            Flexible(child: trailing!)
          else if (value != null)
            Flexible(
              child: Text(
                value!,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary),
              ),
            ),
          if (showChevron) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
          ],
        ],
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: body),
    );
  }
}

/// The switch used in settings rows — gold in dark, navy in light, per the
/// "no blue anywhere" rule.
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
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onPrimary : t.surface),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.primary : t.border),
      trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.primary : t.border),
    );
  }
}
