import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DraftRestoredNotice extends StatelessWidget {
  final VoidCallback onDiscard;

  const DraftRestoredNotice({super.key, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppMetrics.radiusSm);

    return Container(
      key: const ValueKey('draft-restored-notice'),
      padding: const EdgeInsetsDirectional.only(start: 14, end: 2),
      decoration: BoxDecoration(
        color: t.primary.withValues(alpha: t.isDark ? 0.16 : 0.06),
        borderRadius: radius,
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 18, color: t.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                l10n.coreDraftRestored,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: AppType.subhead,
                    height: 1.35,
                    color: t.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppMetrics.minHitTarget,
              minHeight: AppMetrics.minHitTarget,
              maxWidth: 140,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: const ValueKey('draft-discard'),
                borderRadius: radius,
                onTap: onDiscard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      l10n.coreDraftDiscard,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: AppType.body,
                          fontWeight: FontWeight.w600,
                          color: t.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
