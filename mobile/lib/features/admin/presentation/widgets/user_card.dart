import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

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
                    const _Pill(text: 'INACTIVE', color: AppColors.error),
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
              const PopupMenuItem(value: 'stats', child: Text('View stats')),
              const PopupMenuItem(value: 'role', child: Text('Change role')),
              const PopupMenuItem(value: 'team', child: Text('Assign team')),
              const PopupMenuItem(value: 'resend', child: Text('Resend invite')),
              PopupMenuItem(
                  value: 'active',
                  child: Text(user.isActive ? 'Deactivate' : 'Activate',
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
