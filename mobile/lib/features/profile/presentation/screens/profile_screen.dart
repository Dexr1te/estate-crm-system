import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        final l10n = AppLocalizations.of(ctx);
        final user = state is AuthAuthenticated ? state.user : null;
        if (user == null) return const SizedBox();

        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTitle)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Avatar + name header
              _AvatarHeader(user: user),
              const SizedBox(height: 28),

              // Account section
              _Section(title: l10n.profileAccount, children: [
                _Tile(
                  icon: Icons.person_outline,
                  label: l10n.profileEditName,
                  trailing:
                      Text(user.fullName, style: const TextStyle(fontSize: 13)),
                  onTap: () => _showEditName(context, user.fullName),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.email_outlined,
                  label: l10n.profileEmail,
                  trailing:
                      Text(user.email, style: const TextStyle(fontSize: 13)),
                  onTap: null,
                ),
                _Divider(),
                _Tile(
                  icon: Icons.badge_outlined,
                  label: l10n.profileRole,
                  trailing: _RoleChip(role: user.role),
                  onTap: null,
                ),
                _Divider(),
                // ── Agent ID row (tap to copy) ──
                _Tile(
                  icon: Icons.fingerprint,
                  label: l10n.profileAgentId,
                  trailing: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: user.userId.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.profileAgentIdCopied),
                            duration: const Duration(seconds: 1)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.success.withAlpha(51))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${user.userId}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                fontFamily: 'Sora')),
                        const SizedBox(width: 5),
                        const Icon(Icons.copy,
                            size: 13, color: AppColors.success),
                      ]),
                    ),
                  ),
                  onTap: null,
                ),
              ]),

              const SizedBox(height: 16),

              // Preferences section
              _Section(title: l10n.profilePreferences, children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (ctx, themeState) => _Tile(
                    icon: themeState.isDark
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    label: l10n.profileDarkMode,
                    trailing: Switch.adaptive(
                      value: themeState.isDark,
                      onChanged: (_) =>
                          ctx.read<ThemeBloc>().add(ThemeToggleEvent()),
                      // ignore: deprecated_member_use
                      activeColor: AppColors.primary,
                    ),
                    onTap: () => ctx.read<ThemeBloc>().add(ThemeToggleEvent()),
                  ),
                ),
                _Divider(),
                BlocBuilder<LocaleBloc, LocaleState>(
                  builder: (ctx, localeState) => _Tile(
                    icon: Icons.translate_outlined,
                    label: l10n.profileLanguage,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_languageLabel(l10n, localeState.locale),
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppColors.textHint),
                    ]),
                    onTap: () => _showLanguagePicker(ctx, localeState.locale),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // App info section
              _Section(title: l10n.profileAbout, children: [
                _Tile(
                    icon: Icons.info_outline,
                    label: l10n.profileVersion,
                    trailing:
                        const Text('1.0.0', style: TextStyle(fontSize: 13)),
                    onTap: null),
                _Divider(),
                _Tile(
                    icon: Icons.home_work_outlined,
                    label: l10n.profileEstateCrm,
                    onTap: null),
              ]),

              const SizedBox(height: 28),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout,
                      size: 18, color: AppColors.error),
                  label: Text(l10n.profileSignOut,
                      style: const TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        );
      },
    );
  }

  void _showEditName(BuildContext context, String current) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: current);
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.profileEditName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sora')),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: l10n.profileFullName,
                    prefixIcon: const Icon(Icons.person_outline, size: 20)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.profileNameUpdated)),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: Text(l10n.profileSave),
              ),
            ]),
      ),
    );
  }

  // Endonyms — a language is always shown written in itself.
  static const _endonyms = {'en': 'English', 'ru': 'Русский', 'kk': 'Қазақша'};

  String _languageLabel(AppLocalizations l10n, Locale? locale) =>
      locale == null
          ? l10n.profileSystemDefault
          : _endonyms[locale.languageCode] ?? locale.languageCode;

  void _showLanguagePicker(BuildContext context, Locale? current) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<LocaleBloc>();
    showAppBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(l10n.profileLanguage,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sora')),
            ),
            _LanguageOption(
              label: l10n.profileSystemDefault,
              selected: current == null,
              onTap: () {
                bloc.add(LocaleChangedEvent(null));
                Navigator.pop(ctx);
              },
            ),
            for (final locale in LocaleBloc.supported)
              _LanguageOption(
                label: _endonyms[locale.languageCode] ?? locale.languageCode,
                selected: current?.languageCode == locale.languageCode,
                onTap: () {
                  bloc.add(LocaleChangedEvent(locale));
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.profileSignOut,
            style: const TextStyle(
                fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        content: Text(l10n.profileSignOutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.profileCancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.profileSignOut,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final AuthResponse user;
  const _AvatarHeader({required this.user});

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF4A7FD4),
      const Color(0xFFD4A843),
      const Color(0xFF22C55E),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(user.fullName);
    return Column(children: [
      Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(38),
          border: Border.all(color: color, width: 2.5),
        ),
        child: Center(
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Sora'),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(user.fullName,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
      const SizedBox(height: 4),
      Text(user.email, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 8),
      _RoleChip(role: user.role),
    ]);
  }
}

class _RoleChip extends StatelessWidget {
  final Role role;
  const _RoleChip({required this.role});
  @override
  Widget build(BuildContext context) {
    final isAdmin = role == Role.ADMIN;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isAdmin ? AppColors.accent : AppColors.info).withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.name,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isAdmin ? AppColors.accent : AppColors.info),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
                letterSpacing: 1.2)),
      ),
      Card(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: children))),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile(
      {required this.icon, required this.label, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing,
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 52);
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageOption(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : null)),
        trailing: selected
            ? const Icon(Icons.check, color: AppColors.primary, size: 20)
            : null,
        onTap: onTap,
      );
}
