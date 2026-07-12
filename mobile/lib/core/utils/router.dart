import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_bloc.dart';
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

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child})
      : super(
          transitionsBuilder: _noTransition,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

  static Widget _noTransition(_, __, ___, Widget child) => child;
}

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
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, __) => const NoTransitionPage(child: RegisterScreen()),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ClientsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ClientFormScreen()),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: ClientDetailScreen(
                      id: int.parse(s.pathParameters['id']!)),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: ClientFormScreen(
                          clientId: int.parse(s.pathParameters['id']!)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/properties',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PropertiesScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: PropertyFormScreen()),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: PropertyDetailScreen(
                      id: int.parse(s.pathParameters['id']!)),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: PropertyFormScreen(
                          propertyId: int.parse(s.pathParameters['id']!)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/deals',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DealsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: DealFormScreen()),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child:
                      DealDetailScreen(id: int.parse(s.pathParameters['id']!)),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: DealFormScreen(
                          dealId: int.parse(s.pathParameters['id']!)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/meetings',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: MeetingsScreen()),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: MeetingFormScreen()),
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: MeetingFormScreen(
                      meetingId: int.parse(s.pathParameters['id']!)),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
