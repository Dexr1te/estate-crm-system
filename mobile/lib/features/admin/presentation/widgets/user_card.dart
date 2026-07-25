import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// List-item card for a managed user (admin Users tab).
class UserCard extends StatelessWidget {
  final AgentResponse user;
  final VoidCallback onStats;
  final VoidCallback onChangeRole;
  final VoidCallback onAssignTeam;
  final VoidCallback onToggleActive;
  final VoidCallback onResendInvite;

  const UserCard({
    super.key,
    required this.user,
    required this.onStats,
    required this.onChangeRole,
    required this.onAssignTeam,
    required this.onToggleActive,
    required this.onResendInvite,
  });

  Color _roleColor(Role r) => switch (r) {
        Role.ADMIN => AppColors.accent,
        Role.MANAGER => AppColors.info,
        Role.AGENT => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final roleColor = _roleColor(user.role);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.primary.withAlpha(26),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(user.fullName,
                        style:
                            tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  _Pill(text: user.role.name, color: roleColor),
                  if (!user.isActive) ...[
                    const SizedBox(width: 6),
                    _Pill(text: l10n.adminInactive, color: AppColors.error),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(user.email, style: tt.bodySmall),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'stats':
                  onStats();
                case 'role':
                  onChangeRole();
                case 'team':
                  onAssignTeam();
                case 'active':
                  onToggleActive();
                case 'resend':
                  onResendInvite();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'stats', child: Text(l10n.adminViewStats)),
              PopupMenuItem(value: 'role', child: Text(l10n.adminChangeRole)),
              PopupMenuItem(value: 'team', child: Text(l10n.adminAssignTeam)),
              PopupMenuItem(
                  value: 'resend', child: Text(l10n.adminResendInvite)),
              PopupMenuItem(
                  value: 'active',
                  child: Text(user.isActive ? l10n.adminDeactivate : l10n.adminActivate,
                      style: TextStyle(
                          color: user.isActive
                              ? AppColors.error
                              : AppColors.success))),
            ],
            child: Icon(Icons.more_vert, color: tt.bodySmall?.color, size: 20),
          ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sora')),
      );
}
