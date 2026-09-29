import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String autoLockLabel(AppLocalizations l10n, AutoLock value) => switch (value) {
      AutoLock.immediately => l10n.lockAutoLockImmediately,
      AutoLock.oneMinute => l10n.lockAutoLockOneMinute,
      AutoLock.fiveMinutes => l10n.lockAutoLockFiveMinutes,
      AutoLock.fifteenMinutes => l10n.lockAutoLockFifteenMinutes,
    };

/// One card per choice of how long the app may sit in the background.
class AutoLockOptions extends StatelessWidget {
  final String? title;
  final AutoLock selected;
  final ValueChanged<AutoLock> onSelected;

  const AutoLockOptions({
    super.key,
    this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: t.textPrimary),
          ),
          const SizedBox(height: 14),
        ],
        for (final value in AutoLock.values) ...[
          if (value != AutoLock.values.first) const SizedBox(height: 8),
          AppCard(
            key: ValueKey('auto-lock-${value.name}'),
            nested: true,
            radius: AppMetrics.radiusSm,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            onTap: () => onSelected(value),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    autoLockLabel(l10n, value),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13.5,
                        fontWeight: value == selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: t.textPrimary),
                  ),
                ),
                if (value == selected)
                  Icon(Icons.check_rounded, size: 18, color: t.accent),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
