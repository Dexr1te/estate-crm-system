import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The line under a phone or email field that says this person is already on
/// someone's books. A warning, never a block: saving still goes ahead.
class DuplicateWarning extends StatelessWidget {
  final List<ClientDuplicate> duplicates;
  final ValueChanged<ClientDuplicate> onOpen;

  /// More than this and the card would push the form off the screen; the
  /// first few are enough to know who to ask.
  static const maxShown = 3;

  const DuplicateWarning({
    super.key,
    required this.duplicates,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final palette = StatusPalette.resolve(t, StatusHue.negotiation);

    return Container(
      key: const ValueKey('duplicate-warning'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.people_alt_outlined, size: 15, color: palette.label),
            const SizedBox(width: 6),
            Expanded(
                child: EyebrowLabel(l10n.clientsDuplicateEyebrow,
                    color: palette.label)),
          ]),
          const SizedBox(height: 6),
          for (final d in duplicates.take(maxShown))
            _DuplicateRow(duplicate: d, onOpen: () => onOpen(d)),
          Text(
            l10n.clientsDuplicateHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                height: 1.35,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// "Already in the agency: <name> (agent X)" for one card.
String duplicateHeadline(AppLocalizations l10n, ClientDuplicate d) {
  final agent = d.agentName;
  return agent == null || agent.trim().isEmpty
      ? l10n.clientsDuplicateUnassigned(d.fullName)
      : l10n.clientsDuplicateHeldBy(agent, d.fullName);
}

String duplicateMatchLabel(AppLocalizations l10n, DuplicateMatch match) {
  switch (match) {
    case DuplicateMatch.PHONE:
      return l10n.clientsDuplicateSamePhone;
    case DuplicateMatch.EMAIL:
      return l10n.clientsDuplicateSameEmail;
    case DuplicateMatch.PHONE_AND_EMAIL:
      return l10n.clientsDuplicateSameBoth;
  }
}

class _DuplicateRow extends StatelessWidget {
  final ClientDuplicate duplicate;
  final VoidCallback onOpen;
  const _DuplicateRow({required this.duplicate, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duplicateHeadline(l10n, duplicate),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  duplicateMatchLabel(l10n, duplicate.matchedOn),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          if (duplicate.visible) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                foregroundColor: t.textPrimary,
                minimumSize: const Size(48, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                l10n.clientsDuplicateOpen,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
