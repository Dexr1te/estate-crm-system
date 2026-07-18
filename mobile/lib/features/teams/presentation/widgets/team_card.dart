import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

/// List-item card for a team. Tap opens stats; [onEdit] (admin) is optional.
class TeamCard extends StatelessWidget {
  final TeamResponse team;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const TeamCard({super.key, required this.team, required this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: cs.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.groups_outlined, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name,
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${team.memberCount} member${team.memberCount == 1 ? '' : 's'}'
                    '${team.managerName != null ? ' • ${team.managerName}' : ''}',
                    style: tt.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: tt.bodySmall?.color),
                  onPressed: onEdit)
            else
              Icon(Icons.chevron_right, color: tt.bodySmall?.color),
          ]),
        ),
      ),
    );
  }
}
