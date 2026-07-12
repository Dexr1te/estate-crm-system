import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_state.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationIndex(String loc) {
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/clients')) return 1;
    if (loc.startsWith('/properties')) return 2;
    if (loc.startsWith('/deals')) return 3;
    if (loc.startsWith('/meetings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    const routes = [
      '/dashboard',
      '/clients',
      '/properties',
      '/deals',
      '/meetings'
    ];
    context.go(routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _locationIndex(location);
    final isWide = MediaQuery.of(context).size.width >= 800;

    if (isWide) {
      return Scaffold(
        body: Row(children: [
          _SideNav(selectedIndex: index, onTap: (i) => _onTap(context, i)),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
          Expanded(child: child),
        ]),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => _onTap(context, i),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Clients'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_work_outlined),
                activeIcon: Icon(Icons.home_work),
                label: 'Properties'),
            BottomNavigationBarItem(
                icon: Icon(Icons.handshake_outlined),
                activeIcon: Icon(Icons.handshake),
                label: 'Deals'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Meetings'),
          ],
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _SideNav({required this.selectedIndex, required this.onTap});

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
          _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Dashboard',
              selected: selectedIndex == 0,
              onTap: () => onTap(0)),
          _NavItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Clients',
              selected: selectedIndex == 1,
              onTap: () => onTap(1)),
          _NavItem(
              icon: Icons.home_work_outlined,
              activeIcon: Icons.home_work,
              label: 'Properties',
              selected: selectedIndex == 2,
              onTap: () => onTap(2)),
          _NavItem(
              icon: Icons.handshake_outlined,
              activeIcon: Icons.handshake,
              label: 'Deals',
              selected: selectedIndex == 3,
              onTap: () => onTap(3)),
          _NavItem(
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              label: 'Meetings',
              selected: selectedIndex == 4,
              onTap: () => onTap(4)),
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
                    onPressed: () =>
                        ctx.read<AuthBloc>().add(AuthLogoutEvent()),
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
