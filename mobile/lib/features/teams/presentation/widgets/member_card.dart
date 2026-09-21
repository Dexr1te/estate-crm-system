import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MemberCard extends StatelessWidget {
  final TeamMemberResponse member;
  final VoidCallback? onTap;

  const MemberCard({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          InitialAvatar(name: member.fullName, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary),
                      ),
                    ),
                    if (member.isTeamManager) ...[
                      const SizedBox(width: 8),
                      BrandChip(label: l10n.teamsManagerChip),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12.5,
                      color: t.textSecondary),
                ),
                if (_note(l10n) case final String note) ...[
                  const SizedBox(height: 7),
                  StatusChip(label: note, hue: StatusHue.neutral),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
          ],
        ],
      ),
    );
  }

  String? _note(AppLocalizations l10n) {
    if (!member.isActive) return l10n.adminInactive;
    switch (member.status) {
      case UserAccountStatus.pendingInvite:
        return l10n.teamsStatusPendingInvite;
      case UserAccountStatus.pendingVerification:
        return l10n.teamsStatusPendingVerification;
      case UserAccountStatus.active:
        return null;
    }
  }
}

class MemberCardBone extends StatelessWidget {
  const MemberCardBone({super.key});

  @override
  Widget build(BuildContext context) => const AppCard(
        child: Row(
          children: [
            ShimmerBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 13),
                  SizedBox(height: 8),
                  ShimmerBox(width: 180, height: 11),
                ],
              ),
            ),
          ],
        ),
      );
}
