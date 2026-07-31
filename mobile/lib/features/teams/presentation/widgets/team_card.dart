import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class TeamCard extends StatelessWidget {
  final TeamResponse team;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const TeamCard(
      {super.key, required this.team, required this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final memberText = l10n.teamsMemberCount(team.memberCount);
    final subtitle = team.managerName != null
        ? '$memberText · ${team.managerName}'
        : memberText;

    return AppCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(13),
              border:
                  Border.all(color: t.border, width: AppMetrics.borderWidth),
            ),
            child: Icon(Icons.groups_outlined, size: 18, color: t.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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
          if (onEdit != null)
            AppIconTile(icon: Icons.edit_outlined, onPressed: onEdit!)
          else
            Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
        ],
      ),
    );
  }
}
