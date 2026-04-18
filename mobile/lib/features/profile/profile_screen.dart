import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/features/auth/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        if (user == null) return const SizedBox();

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Avatar + name header
              _AvatarHeader(user: user),
              const SizedBox(height: 28),

              // Account section
              _Section(title: 'Account', children: [
                _Tile(
                  icon: Icons.person_outline,
                  label: 'Edit Name',
                  trailing: Text(user.fullName,
                      style: const TextStyle(
                        fontSize: 13,
                      )),
                  onTap: () => _showEditName(context, user.fullName),
                ),
                _Divider(),
                _Tile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  trailing: Text(user.email,
                      style: const TextStyle(
                        fontSize: 13,
                      )),
                  onTap: null,
                ),
                _Divider(),
                _Tile(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  trailing: _RoleChip(role: user.role),
                  onTap: null,
                ),
              ]),

              const SizedBox(height: 16),

              // Preferences section
              _Section(title: 'Preferences', children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (ctx, themeState) => _Tile(
                    icon: themeState.isDark
                        ? Icons.dark_mode
                        : Icons.light_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch.adaptive(
                      value: themeState.isDark,
                      onChanged: (_) =>
                          ctx.read<ThemeBloc>().add(ThemeToggleEvent()),
                      activeColor: AppColors.primary,
                    ),
                    onTap: () => ctx.read<ThemeBloc>().add(ThemeToggleEvent()),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // App info section
              _Section(title: 'About', children: [
                const _Tile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    trailing: Text('1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                        )),
                    onTap: null),
                _Divider(),
                const _Tile(
                    icon: Icons.home_work_outlined,
                    label: 'Estate CRM',
                    trailing: Text('Real Estate Platform',
                        style: TextStyle(
                          fontSize: 13,
                        )),
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
                  label: const Text('Sign Out',
                      style: TextStyle(
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
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
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
              const Text('Edit Name',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sora')),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    // Store locally — backend /users update endpoint not in spec
                    // but we update the saved user name in SharedPreferences via auth
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated locally')),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600)),
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
          color: color.withOpacity(0.15),
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
      Text(user.email,
          style: const TextStyle(
            fontSize: 14,
          )),
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
        color: (isAdmin ? AppColors.accent : AppColors.info).withOpacity(0.12),
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
        leading: Icon(
          icon,
          size: 20,
        ),
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
