import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

/// A navigation destination in the app shell.
class _Dest {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Dest(this.route, this.icon, this.activeIcon, this.label);
}

const _baseDests = [
  _Dest('/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
  _Dest('/clients', Icons.people_outline, Icons.people, 'Clients'),
  _Dest('/properties', Icons.home_work_outlined, Icons.home_work, 'Properties'),
  _Dest('/deals', Icons.handshake_outlined, Icons.handshake, 'Deals'),
  _Dest('/meetings', Icons.calendar_today_outlined, Icons.calendar_today,
      'Meetings'),
];

/// Destinations for the given [role]: agents get the base five; admins get an
/// extra "Admin" tab, managers an extra "Team" tab.
List<_Dest> _destsFor(Role? role) {
  final dests = [..._baseDests];
  if (role == Role.ADMIN) {
    dests.add(
        const _Dest('/admin', Icons.shield_outlined, Icons.shield, 'Admin'));
  } else if (role == Role.MANAGER) {
    dests.add(const _Dest(
        '/team-console', Icons.groups_outlined, Icons.groups, 'Team'));
  }
  return dests;
}

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationIndex(List<_Dest> dests, String loc) {
    final i = dests.indexWhere((d) => loc.startsWith(d.route));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.runtimeType != c.runtimeType,
      builder: (context, authState) {
        final role =
            authState is AuthAuthenticated ? authState.user.role : null;
        final dests = _destsFor(role);
        final location = GoRouterState.of(context).matchedLocation;
        final index = _locationIndex(dests, location);
        final isWide = MediaQuery.of(context).size.width >= 800;

        void onTap(int i) => context.go(dests[i].route);

        if (isWide) {
          return Scaffold(
            body: Row(children: [
              _SideNav(dests: dests, selectedIndex: index, onTap: onTap),
              VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
              Expanded(child: child),
            ]),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor))),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                for (final d in dests)
                  BottomNavigationBarItem(
                      icon: Icon(d.icon),
                      activeIcon: Icon(d.activeIcon),
                      label: d.label),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  final List<_Dest> dests;
  final int selectedIndex;
  final void Function(int) onTap;
  const _SideNav(
      {required this.dests, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
      final user = state is AuthAuthenticated ? state.user : null;
      return Container(
        width: 220,
        color: Theme.of(context).cardColor,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 48),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.home_work,
                        color: Colors.white, size: 18)),
                const SizedBox(width: 10),
                Text('Estate CRM',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: cs.onSurface)),
              ])),
          const SizedBox(height: 32),
          for (var i = 0; i < dests.length; i++)
            _NavItem(
                icon: dests[i].icon,
                activeIcon: dests[i].activeIcon,
                label: dests[i].label,
                selected: selectedIndex == i,
                onTap: () => onTap(i)),
          const Spacer(),
          Divider(color: Theme.of(context).dividerColor),
          Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: cs.primary,
                    child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w600))),
                title: Text(user?.fullName ?? '',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: cs.onSurface),
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(user?.role.name ?? '',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withAlpha(128))),
                trailing: IconButton(
                    icon: Icon(Icons.logout,
                        size: 18, color: cs.onSurface.withAlpha(128)),
                    onPressed: () => ctx.read<AuthBloc>().add(AuthLogoutEvent()),
                    tooltip: 'Logout'),
                onTap: () => context.push('/profile'),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 8),
        ]),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withAlpha(26) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(selected ? activeIcon : icon,
                size: 20,
                color: selected ? cs.primary : cs.onSurface.withAlpha(102)),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        selected ? cs.primary : cs.onSurface.withAlpha(153))),
          ]),
        ),
      ),
    );
  }
}
