import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/navigation/active_tab.dart';
import 'package:real_estate_crm/core/navigation/role_hub.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class _Dest {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Dest(this.route, this.icon, this.activeIcon, this.label);
}

List<_Dest> _tabs(AppLocalizations l10n) => [
      _Dest(ShellTabs.dashboard, Icons.dashboard_outlined, Icons.dashboard,
          l10n.coreNavDashboard),
      _Dest(ShellTabs.clients, Icons.people_outline, Icons.people,
          l10n.coreNavClients),
      _Dest(ShellTabs.properties, Icons.home_work_outlined, Icons.home_work,
          l10n.coreNavProperties),
      _Dest(ShellTabs.deals, Icons.handshake_outlined, Icons.handshake,
          l10n.coreNavDeals),
      _Dest(ShellTabs.meetings, Icons.calendar_month_outlined,
          Icons.calendar_month, l10n.coreNavCalendar),
    ];

const _fabGap = 12.0;

AuthResponse? _userOf(AuthState state) =>
    state is AuthAuthenticated ? state.user : null;

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainScaffold({super.key, required this.shell});

  String get _route => ShellTabs.routes[shell.currentIndex];

  void _goTo(String route) {
    final branch = ShellTabs.routes.indexOf(route);
    if (branch != shell.currentIndex) HapticFeedback.selectionClick();
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  Future<bool> _backFromHub(BuildContext context) async {
    if (!RoleHub.isHubRoute(_route)) return false;
    if (ModalRoute.isCurrentOf(context) == false) return false;
    _goTo(ShellTabs.dashboard);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.runtimeType != c.runtimeType ||
          RoleHub.of(_userOf(p)) != RoleHub.of(_userOf(c)),
      builder: (context, authState) {
        final l10n = AppLocalizations.of(context);
        final hub = RoleHub.of(_userOf(authState));
        final tabs = _tabs(l10n);
        final route = _route;
        final found = tabs.indexWhere((d) => d.route == route);
        final selected = found < 0 ? null : found;
        final isWide =
            MediaQuery.sizeOf(context).width >= AppMetrics.railBreakpoint;
        final child = BackButtonListener(
          onBackButtonPressed: () => _backFromHub(context),
          child: ActiveTab(route: route, child: shell),
        );

        if (isWide) {
          return Scaffold(
            body: Row(children: [
              _SideNav(
                dests: [
                  ...tabs,
                  if (hub != null)
                    _Dest(hub.route, hub.icon, hub.activeIcon, hub.label(l10n)),
                ],
                selectedRoute: route,
                hubFrom: tabs.length,
                onTap: _goTo,
              ),
              VerticalDivider(width: 1, color: context.tokens.border),
              Expanded(child: child),
            ]),
          );
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: child,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _FloatingAdd(),
              AppBottomNav(
                currentIndex: selected,
                onTap: (i) => _goTo(tabs[i].route),
                items: [
                  for (final d in tabs)
                    AppNavItem(
                        icon: d.icon, activeIcon: d.activeIcon, label: d.label),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingAdd extends StatelessWidget {
  const _FloatingAdd();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppMetrics.navIslandInset, 0, AppMetrics.navIslandInset, _fabGap),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppMetrics.navIslandMaxWidth),
          child: const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: QuickAddButton.floating(),
          ),
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final List<_Dest> dests;
  final String selectedRoute;
  final int hubFrom;
  final ValueChanged<String> onTap;
  const _SideNav(
      {required this.dests,
      required this.selectedRoute,
      required this.hubFrom,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
                Flexible(
                  child: Text('Estate CRM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontWeight: FontWeight.w700,
                          fontSize: AppType.body,
                          color: cs.onSurface)),
                ),
              ])),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: QuickAddButton.rail(),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < dests.length; i++) ...[
            if (i == hubFrom) const SizedBox(height: 16),
            _NavItem(
                icon: dests[i].icon,
                activeIcon: dests[i].activeIcon,
                label: dests[i].label,
                selected: selectedRoute == dests[i].route,
                onTap: () => onTap(dests[i].route)),
          ],
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
                            fontFamily: AppFonts.sans,
                            fontWeight: FontWeight.w600))),
                title: Text(user?.fullName ?? '',
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontWeight: FontWeight.w600,
                        fontSize: AppType.subhead,
                        color: cs.onSurface),
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(user == null ? '' : roleLabel(l10n, user.role),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: AppType.caption,
                        color: context.tokens.textSecondary)),
                trailing: IconButton(
                    icon: Icon(Icons.logout,
                        size: 18, color: cs.onSurface.withAlpha(128)),
                    onPressed: () =>
                        ctx.read<AuthBloc>().add(AuthLogoutEvent()),
                    tooltip: l10n.coreLogout),
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
                    fontFamily: AppFonts.sans,
                    fontSize: AppType.subhead,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        selected ? cs.primary : cs.onSurface.withAlpha(153))),
          ]),
        ),
      ),
    );
  }
}
