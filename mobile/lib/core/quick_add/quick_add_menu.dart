import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/quick_add/quick_add.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The body of the quick-add sheet: one row per action, in the order given.
class QuickAddMenu extends StatelessWidget {
  final List<QuickAddAction> actions;
  final QuickAddAction? lastUsed;
  final Future<String?>? linkedTo;
  final ValueChanged<QuickAddAction> onPick;

  const QuickAddMenu({
    super.key,
    required this.actions,
    required this.onPick,
    this.lastUsed,
    this.linkedTo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (linkedTo != null)
          FutureBuilder<String?>(
            future: linkedTo,
            builder: (context, snap) {
              final name = snap.data;
              if (name == null || name.isEmpty) {
                return const SizedBox(height: 14);
              }
              return _LinkedTo(label: l10n.quickAddFor(name));
            },
          )
        else
          const SizedBox(height: 14),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _Row(
            key: ValueKey('quick-add-${actions[i].name}'),
            icon: quickAddIcon(actions[i]),
            label: quickAddLabel(l10n, actions[i]),
            tag:
                i == 0 && actions[i] == lastUsed ? l10n.quickAddLastUsed : null,
            onTap: () => onPick(actions[i]),
          ),
        ],
      ],
    );
  }
}

class _LinkedTo extends StatelessWidget {
  final String label;
  const _LinkedTo({required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 16, color: t.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tag;
  final VoidCallback onTap;

  const _Row({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
        child: Row(
          children: [
            Icon(icon, size: 22, color: t.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tag!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textHint),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: t.textHint),
          ],
        ),
      ),
    );
  }
}
