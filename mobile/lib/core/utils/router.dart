import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/main_scaffold.dart';
import 'package:real_estate_crm/features/admin/presentation/screens/admin_console_screen.dart';
import 'package:real_estate_crm/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/accept_invite_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/create_team_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_form_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_role_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/splash_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/waiting_for_team_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:real_estate_crm/features/profile/presentation/screens/profile_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/search/presentation/screens/search_screen.dart';
import 'package:real_estate_crm/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/manager_console_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootKey;

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child})
      : super(
          transitionsBuilder: _noTransition,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

  static Widget _noTransition(_, __, ___, Widget child) => child;
}

String? resolveRedirect({
  required String location,
  required bool sessionResolved,
  required bool authenticated,
  required Role? role,
  required bool hasTeam,
}) {
  if (!sessionResolved) return location == '/splash' ? null : '/splash';
  if (location == '/splash') return authenticated ? '/dashboard' : '/login';

  const authLocations = [
    '/login',
    '/register',
    '/verify-email',
    '/accept-invite',
    '/forgot-password',
    '/reset-password',
  ];
  final onAuth = authLocations.any(location.startsWith);
  if (!authenticated && !onAuth) return '/login';
  if (authenticated && onAuth) return '/dashboard';

  final needsTeam = authenticated && !hasTeam && role != Role.ADMIN;
  final onboarding = needsTeam
      ? (role == Role.MANAGER ? '/onboarding/team' : '/onboarding/waiting')
      : null;
  if (onboarding != null) {
    if (location.startsWith('/profile')) return null;
    return location.startsWith(onboarding) ? null : onboarding;
  }
  if (location.startsWith('/onboarding')) return '/dashboard';

  if (location.startsWith('/admin') && role != Role.ADMIN) return '/dashboard';
  if (location.startsWith('/team-console') && role != Role.MANAGER) {
    return '/dashboard';
  }
  return null;
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    refreshListenable: authBloc,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      sessionResolved: authBloc.isSessionResolved,
      authenticated: authBloc.isAuthenticated,
      role: authBloc.currentUser?.role,
      hasTeam: authBloc.currentUser?.teamId != null,
    ),
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: RegisterRoleScreen()),
        routes: [
          GoRoute(
            path: 'details',
            pageBuilder: (_, s) => NoTransitionPage(
              child: RegisterFormScreen(
                role: s.uri.queryParameters['role'] == Role.MANAGER.name
                    ? Role.MANAGER
                    : Role.AGENT,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (_, s) => NoTransitionPage(
          child: VerifyEmailScreen(
            email: s.uri.queryParameters['email'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding/team',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: CreateTeamScreen()),
      ),
      GoRoute(
        path: '/onboarding/waiting',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: WaitingForTeamScreen()),
      ),
      GoRoute(
        path: '/accept-invite',
        pageBuilder: (_, s) => NoTransitionPage(
          child: AcceptInviteScreen(token: s.uri.queryParameters['token']),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (_, s) => NoTransitionPage(
          child: ResetPasswordScreen(token: s.uri.queryParameters['token']),
        ),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: SearchScreen()),
      ),
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: AnalyticsScreen()),
      ),
      GoRoute(
        path: '/tasks',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: TasksScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: AdminConsoleScreen()),
          ),
          GoRoute(
            path: '/team-console',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ManagerConsoleScreen()),
          ),
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
            pageBuilder: (_, s) => NoTransitionPage(
              child: DealsScreen(
                initialStatus:
                    DealsScreen.parseStatus(s.uri.queryParameters['status']),
              ),
            ),
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
                pageBuilder: (_, s) => NoTransitionPage(
                  child: MeetingFormScreen(
                    initialClientId:
                        int.tryParse(s.uri.queryParameters['clientId'] ?? ''),
                    initialPropertyId:
                        int.tryParse(s.uri.queryParameters['propertyId'] ?? ''),
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: MeetingDetailScreen(
                      id: int.parse(s.pathParameters['id']!)),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
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
      ),
    ],
  );
}
