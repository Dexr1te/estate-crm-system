import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class RegisterRoleScreen extends StatefulWidget {
  const RegisterRoleScreen({super.key});

  @override
  State<RegisterRoleScreen> createState() => _RegisterRoleScreenState();
}

class _RegisterRoleScreenState extends State<RegisterRoleScreen> {
  Role _role = Role.MANAGER;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: AppMetrics.constrain(
          CenteredScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(),
                const SizedBox(height: 22),
                AuthTitle(
                  title: l10n.authChooseRoleTitle,
                  subtitle: l10n.authChooseRoleSubtitle,
                ),
                const SizedBox(height: 22),
                _RoleOption(
                  icon: Icons.groups_outlined,
                  title: l10n.authRoleManagerTitle,
                  body: l10n.authRoleManagerBody,
                  selected: _role == Role.MANAGER,
                  onTap: () => setState(() => _role = Role.MANAGER),
                ),
                const SizedBox(height: 10),
                _RoleOption(
                  icon: Icons.person_outline_rounded,
                  title: l10n.authRoleAgentTitle,
                  body: l10n.authRoleAgentBody,
                  selected: _role == Role.AGENT,
                  onTap: () => setState(() => _role = Role.AGENT),
                ),
                const SizedBox(height: 22),
                AppFilledButton(
                  label: l10n.authContinue,
                  onPressed: () =>
                      context.go('/register/details?role=${_role.name}'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: AuthTextLink(
                    label: l10n.authBackToSignIn,
                    onTap: () => context.go('/login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        onTap: onTap,
        borderColor: selected ? t.primary : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: t.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 19, color: t.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        height: 1.45,
                        color: t.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? t.primary : t.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
