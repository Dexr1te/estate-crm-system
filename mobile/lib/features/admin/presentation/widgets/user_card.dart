import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class UserCard extends StatelessWidget {
  final AgentResponse user;
  final VoidCallback onStats;
  final VoidCallback onChangeRole;
  final VoidCallback onAssignTeam;
  final VoidCallback onToggleActive;
  final VoidCallback onResendInvite;

  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onStats,
    required this.onChangeRole,
    required this.onAssignTeam,
    required this.onToggleActive,
    required this.onResendInvite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Opacity(
      opacity: user.isActive ? 1 : 0.75,
      child: AppCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        onTap: onStats,
        child: Row(
          children: [
            _Avatar(user: user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: t.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 7),
                      if (user.role == Role.ADMIN)
                        BrandChip(label: roleLabel(l10n, user.role))
                      else
                        StatusChip(
                            label: roleLabel(l10n, user.role),
                            hue: StatusHue.neutral),
                      if (!user.isActive) ...[
                        const SizedBox(width: 6),
                        StatusChip(
                            label: l10n.adminInactive,
                            hue: StatusHue.negotiation),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
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
            _Menu(
              user: user,
              onStats: onStats,
              onChangeRole: onChangeRole,
              onAssignTeam: onAssignTeam,
              onToggleActive: onToggleActive,
              onResendInvite: onResendInvite,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final AgentResponse user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (user.isActive) {
      return InitialAvatar(name: user.fullName, size: 40);
    }
    return CustomPaint(
      painter: _DashedCirclePainter(color: t.textHint),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: t.textHint),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final radius = size.width / 2;
    const dashes = 20;
    const sweep = 6.2831853 / dashes;
    for (var i = 0; i < dashes; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 0.5),
        i * sweep,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

class _Menu extends StatelessWidget {
  final AgentResponse user;
  final VoidCallback onStats;
  final VoidCallback onChangeRole;
  final VoidCallback onAssignTeam;
  final VoidCallback onToggleActive;
  final VoidCallback onResendInvite;
  final VoidCallback? onDelete;

  const _Menu({
    required this.user,
    required this.onStats,
    required this.onChangeRole,
    required this.onAssignTeam,
    required this.onToggleActive,
    required this.onResendInvite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<VoidCallback>(
      onSelected: (fn) => fn(),
      tooltip: '',
      icon: Icon(Icons.more_vert_rounded, size: 18, color: t.textHint),
      itemBuilder: (_) => [
        PopupMenuItem(value: onStats, child: Text(l10n.adminViewStats)),
        PopupMenuItem(value: onChangeRole, child: Text(l10n.adminChangeRole)),
        PopupMenuItem(value: onAssignTeam, child: Text(l10n.adminAssignTeam)),
        PopupMenuItem(
            value: onResendInvite, child: Text(l10n.adminResendInvite)),
        PopupMenuItem(
          value: onToggleActive,
          child: Text(
            user.isActive ? l10n.adminDeactivate : l10n.adminActivate,
            style: TextStyle(color: user.isActive ? t.dangerText : null),
          ),
        ),
        if (onDelete != null)
          PopupMenuItem(
            value: onDelete,
            child: Text(l10n.adminDeleteUser,
                style: TextStyle(color: t.dangerText)),
          ),
      ],
    );
  }
}

class UserCardBone extends StatelessWidget {
  const UserCardBone({super.key});

  @override
  Widget build(BuildContext context) =>
      const ShimmerBox(width: double.infinity, height: 66, radius: 14);
}
