import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/login_screen.dart';
import 'package:real_estate_crm/features/auth/register_screen.dart';
import 'package:real_estate_crm/features/clients/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/clients_screen.dart';
import 'package:real_estate_crm/features/dashboard/dashboard_screen.dart';
import 'package:real_estate_crm/features/deals/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/deals_screen.dart';
import 'package:real_estate_crm/features/meetings/meeting_form_screen.dart';
import 'package:real_estate_crm/features/meetings/meetings_screen.dart';
import 'package:real_estate_crm/features/profile/profile_screen.dart';
import 'package:real_estate_crm/features/properties/properties_screen.dart';
import 'package:real_estate_crm/features/properties/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/property_form_screen.dart';
import 'package:real_estate_crm/features/widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    refreshListenable: authBloc,
    redirect: (context, state) {
      final authed = authBloc.isAuthenticated;
      final onAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');
      if (!authed && !onAuth) return '/login';
      if (authed && onAuth) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      // Profile is outside shell (full screen)
      GoRoute(
          path: '/profile',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const ProfileScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
              path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/clients',
            builder: (_, __) => const ClientsScreen(),
            routes: [
              GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootKey,
                  builder: (_, __) => const ClientFormScreen()),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, s) =>
                    ClientDetailScreen(id: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootKey,
                      builder: (_, s) => ClientFormScreen(
                          clientId: int.parse(s.pathParameters['id']!)))
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/properties',
            builder: (_, __) => const PropertiesScreen(),
            routes: [
              GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootKey,
                  builder: (_, __) => const PropertyFormScreen()),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, s) => PropertyDetailScreen(
                    id: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootKey,
                      builder: (_, s) => PropertyFormScreen(
                          propertyId: int.parse(s.pathParameters['id']!)))
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/deals',
            builder: (_, __) => const DealsScreen(),
            routes: [
              GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootKey,
                  builder: (_, __) => const DealFormScreen()),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                builder: (_, s) =>
                    DealDetailScreen(id: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootKey,
                      builder: (_, s) => DealFormScreen(
                          dealId: int.parse(s.pathParameters['id']!)))
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/meetings',
            builder: (_, __) => const MeetingsScreen(),
            routes: [
              GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootKey,
                  builder: (_, __) => const MeetingFormScreen()),
              GoRoute(
                  path: ':id/edit',
                  parentNavigatorKey: _rootKey,
                  builder: (_, s) => MeetingFormScreen(
                      meetingId: int.parse(s.pathParameters['id']!))),
            ],
          ),
        ],
      ),
    ],
  );
}
