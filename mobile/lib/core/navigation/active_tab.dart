import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

class ShellTabs {
  const ShellTabs._();

  static const dashboard = '/dashboard';
  static const clients = '/clients';
  static const properties = '/properties';
  static const deals = '/deals';
  static const meetings = '/meetings';
  static const admin = '/admin';
  static const teamConsole = '/team-console';

  static const routes = [
    dashboard,
    clients,
    properties,
    deals,
    meetings,
    admin,
    teamConsole,
  ];
}

class ActiveTab extends InheritedWidget {
  final String route;

  const ActiveTab({super.key, required this.route, required super.child});

  static String? routeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActiveTab>()?.route;

  @override
  bool updateShouldNotify(ActiveTab oldWidget) => oldWidget.route != route;
}

mixin RefreshOnTabReturn<T extends StatefulWidget> on State<T> {
  static const refreshAfter = Duration(seconds: 10);

  String get tabRoute;

  void refreshTab();

  DateTime _refreshedAt = AppClock.now();
  bool _active = true;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () {
      if (_active) _refreshIfStale();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ActiveTab.routeOf(context);
    final active = route == null || route == tabRoute;
    if (active && !_active) _refreshIfStale();
    _active = active;
  }

  void _refreshIfStale() {
    final now = AppClock.now();
    if (now.difference(_refreshedAt) < refreshAfter) return;
    _refreshedAt = now;
    refreshTab();
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }
}
