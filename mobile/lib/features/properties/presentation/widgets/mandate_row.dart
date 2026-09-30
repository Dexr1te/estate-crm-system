import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/domain/mandate.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_badge.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One listing whose seller agreement is running out: which listing, how
/// long is left (or how long ago it ended), the agreement and its agent.
class MandateRow extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap;
  final bool nested;

  const MandateRow({
    super.key,
    required this.property,
    required this.onTap,
    this.nested = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = mandateDaysLeft(property, now);
    final meta = [
      mandateBadgeLabel(l10n, property, now, locale),
      property.agentName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

    return AppCard(
      key: ValueKey('mandate-row-${property.id}'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PropertyCover.of(property, size: 38, radius: 11),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                if (days != null) ...[
                  const SizedBox(height: 2),
                  Text(mandateTimeLeftLabel(l10n, days),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: t.dangerText)),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11.5,
                          color: t.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The skeleton of a [MandateRow], shaped like one.
class MandateRowBone extends StatelessWidget {
  const MandateRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          titleFactor: 0.55,
          subtitleFactor: 0.4,
        ),
      );
}
