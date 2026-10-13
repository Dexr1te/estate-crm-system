import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/navigation/active_tab.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum RoleHub {
  team(ShellTabs.teamConsole, Icons.groups_outlined, Icons.groups),
  admin(ShellTabs.admin, Icons.shield_outlined, Icons.shield);

  final String route;
  final IconData icon;
  final IconData activeIcon;

  const RoleHub(this.route, this.icon, this.activeIcon);

  String label(AppLocalizations l10n) => switch (this) {
        RoleHub.team => l10n.coreNavTeam,
        RoleHub.admin => l10n.coreNavAdmin,
      };

  static RoleHub? of(AuthResponse? user) => switch (user?.role) {
        Role.ADMIN => RoleHub.admin,
        Role.MANAGER when user?.teamId != null => RoleHub.team,
        _ => null,
      };

  static bool isHubRoute(String route) =>
      RoleHub.values.any((hub) => hub.route == route);
}
