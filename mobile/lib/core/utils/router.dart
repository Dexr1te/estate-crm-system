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
import 'package:real_estate_crm/features/change_log/presentation/screens/change_history_screen.dart';
import 'package:real_estate_crm/features/change_log/presentation/screens/team_change_log_screen.dart';
import 'package:real_estate_crm/features/checklist/presentation/screens/checklist_template_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_dates_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/cold_clients_screen.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/screens/compare_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deals_screen.dart';
import 'package:real_estate_crm/features/deposits/presentation/screens/deposits_ending_screen.dart';
import 'package:real_estate_crm/features/goals/presentation/screens/team_goals_screen.dart';
import 'package:real_estate_crm/features/imports/presentation/screens/import_screen.dart';
import 'package:real_estate_crm/features/keys/presentation/screens/keys_out_screen.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:real_estate_crm/features/leases/presentation/screens/leases_ending_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';
import 'package:real_estate_crm/features/message_templates/presentation/screens/message_templates_screen.dart';
import 'package:real_estate_crm/features/mortgage/presentation/screens/mortgage_screen.dart';
import 'package:real_estate_crm/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:real_estate_crm/features/offers/presentation/screens/offer_screen.dart';
import 'package:real_estate_crm/features/open_houses/presentation/screens/open_house_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partner_detail_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partner_form_screen.dart';
import 'package:real_estate_crm/features/partners/presentation/screens/partners_screen.dart';
import 'package:real_estate_crm/features/profile/presentation/screens/profile_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/mandates_ending_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/seller_report_screen.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/presentation/screens/route_screen.dart';
import 'package:real_estate_crm/features/search/presentation/screens/search_screen.dart';
import 'package:real_estate_crm/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/handover_screen.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/manager_console_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/my_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/team_time_off_screen.dart';
import 'package:real_estate_crm/features/time_off/presentation/screens/time_off_form_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootKey;

/// The page on top right now. The router's own uri stops at the last `go`,
/// so a record opened with `push` is only found on the match that pushed it.
Uri currentLocationOf(GoRouter router) {
  final config = router.routerDelegate.currentConfiguration;
  final last = config.lastOrNull;
  return last is ImperativeRouteMatch ? last.matches.uri : config.uri;
}

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
  if (location.startsWith('/checklist-template') && role != Role.MANAGER) {
    return '/dashboard';
  }
  if (location.startsWith('/message-templates') && role != Role.MANAGER) {
    return '/dashboard';
  }
  if (location.startsWith('/leaderboard') && role != Role.MANAGER) {
    return '/dashboard';
  }
  if (location.startsWith('/team-goals') && role != Role.MANAGER) {
    return '/dashboard';
  }
  if (location.startsWith('/audit') &&
      role != Role.MANAGER &&
      role != Role.ADMIN) {
    return '/dashboard';
  }
  if (location.startsWith('/team-handover') && role != Role.MANAGER) {
    return '/dashboard';
  }
  if (location.startsWith('/import') &&
      role != Role.MANAGER &&
      role != Role.ADMIN) {
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
        path: '/notifications',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: NotificationsScreen()),
      ),
      GoRoute(
        path: '/checklist-template',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: ChecklistTemplateScreen()),
      ),
      GoRoute(
        path: '/message-templates',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MessageTemplatesScreen()),
      ),
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: LeaderboardScreen()),
      ),
      GoRoute(
        path: '/team-goals',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: TeamGoalsScreen()),
      ),
      GoRoute(
        path: '/audit',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: TeamChangeLogScreen()),
      ),
      GoRoute(
        path: '/team-handover/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, s) => NoTransitionPage(
          child: HandoverScreen(agentId: int.parse(s.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/time-off',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MyTimeOffScreen()),
        routes: [
          GoRoute(
            path: 'team',
            parentNavigatorKey: _rootKey,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: TeamTimeOffScreen()),
          ),
          GoRoute(
            path: 'new',
            parentNavigatorKey: _rootKey,
            pageBuilder: (_, s) => NoTransitionPage(
              child: TimeOffFormScreen(
                  userId: int.tryParse(s.uri.queryParameters['user'] ?? '')),
            ),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            pageBuilder: (_, s) => NoTransitionPage(
              child: TimeOffFormScreen(
                  key: ValueKey(s.pathParameters['id']),
                  id: int.parse(s.pathParameters['id']!)),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/import',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: ImportScreen()),
      ),
      GoRoute(
        path: '/route',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, s) => NoTransitionPage(
          child:
              RouteScreen(day: parseRouteDate(s.uri.queryParameters['date'])),
        ),
      ),
      GoRoute(
        path: '/compare',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => CompareScreen(
          key: ValueKey(s.uri.query),
          ids: parseCompareIds(s.uri.queryParameters['ids']),
          clientId: int.tryParse(s.uri.queryParameters['client'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/tasks',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: TasksScreen()),
      ),
      GoRoute(
        path: '/open-houses/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, s) => NoTransitionPage(
          child: OpenHouseScreen(id: int.parse(s.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/partners',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, __) => const NoTransitionPage(child: PartnersScreen()),
        routes: [
          GoRoute(
            path: 'new',
            parentNavigatorKey: _rootKey,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PartnerFormScreen()),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            pageBuilder: (_, s) => NoTransitionPage(
              child:
                  PartnerDetailScreen(id: int.parse(s.pathParameters['id']!)),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: PartnerFormScreen(
                      partnerId: int.parse(s.pathParameters['id']!)),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/offers/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, s) => NoTransitionPage(
          child: OfferScreen(id: int.parse(s.pathParameters['id']!)),
        ),
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
                path: 'cold',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ColdClientsScreen()),
              ),
              GoRoute(
                path: 'dates',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ClientDatesScreen()),
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
                  GoRoute(
                    path: 'changes',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: ChangeHistoryScreen(
                          type: ChangeEntityType.client,
                          id: int.parse(s.pathParameters['id']!)),
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
                path: 'mandates',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: MandatesEndingScreen()),
              ),
              GoRoute(
                path: 'keys',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: KeysOutScreen()),
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
                  GoRoute(
                    path: 'changes',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: ChangeHistoryScreen(
                          type: ChangeEntityType.property,
                          id: int.parse(s.pathParameters['id']!)),
                    ),
                  ),
                  GoRoute(
                    path: 'report',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: SellerReportScreen(
                          propertyId: int.parse(s.pathParameters['id']!)),
                    ),
                  ),
                  GoRoute(
                    path: 'mortgage',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: MortgageScreen(
                        price: double.tryParse(
                                s.uri.queryParameters['price'] ?? '') ??
                            0,
                        title: s.uri.queryParameters['title'],
                      ),
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
                pageBuilder: (_, s) => NoTransitionPage(
                  child: DealFormScreen(
                    initialClientId:
                        int.tryParse(s.uri.queryParameters['clientId'] ?? ''),
                    initialPropertyId:
                        int.tryParse(s.uri.queryParameters['propertyId'] ?? ''),
                  ),
                ),
              ),
              GoRoute(
                path: 'deposits',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: DepositsEndingScreen()),
              ),
              GoRoute(
                path: 'leases',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: LeasesEndingScreen()),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (_, s) => NoTransitionPage(
                  child: DealDetailScreen(
                    id: int.parse(s.pathParameters['id']!),
                    focusDiscussion:
                        s.uri.queryParameters['focus'] == 'discussion',
                  ),
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
                  GoRoute(
                    path: 'changes',
                    parentNavigatorKey: _rootKey,
                    pageBuilder: (_, s) => NoTransitionPage(
                      child: ChangeHistoryScreen(
                          type: ChangeEntityType.deal,
                          id: int.parse(s.pathParameters['id']!)),
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
                    initialDate:
                        DateTime.tryParse(s.uri.queryParameters['date'] ?? ''),
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
