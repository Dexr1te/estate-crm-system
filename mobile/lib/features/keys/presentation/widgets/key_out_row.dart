import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/keys_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The square a key sits in, beside a listing's keys and in the lists.
class KeyIconTile extends StatelessWidget {
  final bool alert;
  const KeyIconTile({super.key, this.alert = false});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: alert ? t.dangerFill : t.surfaceVariant,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(Icons.key_outlined,
          size: 19, color: alert ? t.dangerText : t.textSecondary),
    );
  }
}

/// One listing whose keys are out: which listing, who has them until when
/// (in the danger hue once overdue), and where it is.
class KeyOutRow extends StatelessWidget {
  final KeyHandover handover;
  final VoidCallback onTap;
  final bool nested;

  const KeyOutRow({
    super.key,
    required this.handover,
    required this.onTap,
    this.nested = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final h = handover;
    final title = h.propertyTitle?.trim().isNotEmpty == true
        ? h.propertyTitle!.trim()
        : l10n.propertiesPropertyIdLabel(h.propertyId);
    final place = [h.propertyAddress, h.propertyCity]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');

    return AppCard(
      key: ValueKey('key-out-row-${h.id}'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          KeyIconTile(alert: h.overdue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary)),
                const SizedBox(height: 2),
                Text(keysHolderLine(l10n, h, AppClock.now(), locale),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: h.overdue ? t.dangerText : t.textSecondary)),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(place,
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
          if (h.overdue) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: StatusChip(label: l10n.keysOverdue, hue: StatusHue.danger),
            ),
          ],
        ],
      ),
    );
  }
}

/// The skeleton of a [KeyOutRow], shaped like one.
class KeyOutRowBone extends StatelessWidget {
  const KeyOutRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          titleFactor: 0.55,
          subtitleFactor: 0.4,
        ),
      );
}
