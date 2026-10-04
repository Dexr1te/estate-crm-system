import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// Monday 5 October 2026, ten in the morning.
final timeOffNow = DateTime(2026, 10, 5, 10);

DateTime offDay(int days) =>
    DateTime(timeOffNow.year, timeOffNow.month, timeOffNow.day + days);

const timeOffManager = AuthResponse(
    userId: 1,
    fullName: 'Marat Manager',
    role: Role.MANAGER,
    teamId: 1,
    teamName: 'Almaty Realty');

const timeOffAgent = AuthResponse(
    userId: 2,
    fullName: 'Aigul Bekova',
    role: Role.AGENT,
    teamId: 1,
    teamName: 'Almaty Realty');

/// The agency as the agents list sends it: Aigul away until Friday, Timur
/// off for a day next week, and a name long enough to wrap.
final timeOffAgents = [
  const AgentOption(id: 1, fullName: 'Marat Manager'),
  AgentOption(
    id: 2,
    fullName: 'Aigul Bekova',
    awayUntil: offDay(4),
    timeOff: [
      AgentAway(
          kind: TimeOffKind.vacation,
          startDate: offDay(-2),
          endDate: offDay(4)),
    ],
  ),
  AgentOption(
    id: 3,
    fullName: 'Timur Aliev',
    timeOff: [
      AgentAway(
          kind: TimeOffKind.dayOff, startDate: offDay(9), endDate: offDay(9)),
    ],
  ),
  const AgentOption(id: 4, fullName: 'Aigerim Serikbaykyzy-Nurmukhambetova'),
];

/// Aigul's holiday, on now, with two meetings still on its days.
final aigulHoliday = TimeOff(
  id: 11,
  userId: 2,
  userName: 'Aigul Bekova',
  kind: TimeOffKind.vacation,
  startDate: offDay(-2),
  endDate: offDay(4),
  days: 7,
  note: 'Phone off, Timur has the keys to Dostyk 5',
  coverId: 3,
  coverName: 'Timur Aliev',
  createdById: 2,
  createdByName: 'Aigul Bekova',
  current: true,
  canEdit: true,
  conflictCount: 2,
  conflicts: [
    TimeOffConflict(
      meetingId: 41,
      title: 'Viewing at Esentai Park, apartment 12 with a long name',
      scheduledAt: offDay(1).add(const Duration(hours: 15)),
      clientName: 'Irina Sokolova-Bekmukhambetova',
      propertyTitle: 'Esentai Park, apartment 12',
    ),
    TimeOffConflict(
      meetingId: 42,
      title: 'Signing',
      scheduledAt: offDay(3).add(const Duration(hours: 11)),
      clientName: 'Bolat Ospanov',
    ),
  ],
);

/// Timur's day off next week; nobody covers.
final timurDayOff = TimeOff(
  id: 12,
  userId: 3,
  userName: 'Timur Aliev',
  kind: TimeOffKind.dayOff,
  startDate: offDay(2),
  endDate: offDay(2),
  days: 1,
  createdById: 3,
);

/// A long sick leave a month out, by somebody with a long name.
final longSickLeave = TimeOff(
  id: 13,
  userId: 4,
  userName: 'Aigerim Serikbaykyzy-Nurmukhambetova',
  kind: TimeOffKind.sickLeave,
  startDate: offDay(30),
  endDate: offDay(44),
  days: 15,
  coverId: 2,
  coverName: 'Aigul Bekova',
);

/// Aigul's day off back in the summer: over.
final aigulPast = TimeOff(
  id: 14,
  userId: 2,
  userName: 'Aigul Bekova',
  kind: TimeOffKind.dayOff,
  startDate: offDay(-40),
  endDate: offDay(-40),
  days: 1,
  canEdit: true,
);

final timeOffItems = [aigulHoliday, timurDayOff, longSickLeave, aigulPast];

/// [child] signed in as [user], shown once the session is: the app never
/// opens these screens before it knows who is signed in.
Widget signedIn(Widget child, {AuthResponse user = timeOffManager}) =>
    BlocProvider(
      create: (_) =>
          AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (_, state) =>
            state is AuthAuthenticated ? child : const SizedBox.shrink(),
      ),
    );

/// [start] under a router that names where a tap went, signed in as [user].
/// A [form] opens on top of a "home" page, so leaving it has somewhere to go.
Widget timeOffApp(Widget? start,
        {Widget? form,
        AuthResponse user = timeOffManager,
        Locale locale = const Locale('en')}) =>
    signedIn(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: form == null ? '/' : '/form',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => start ?? const Scaffold(body: Text('home')),
              routes: [
                if (form != null)
                  GoRoute(path: 'form', builder: (_, __) => form),
              ],
            ),
            GoRoute(
                path: '/time-off/team',
                builder: (_, __) => const Scaffold(body: Text('team list'))),
            GoRoute(
                path: '/time-off/new',
                builder: (_, __) => const Scaffold(body: Text('new time off'))),
            GoRoute(
                path: '/time-off/:id',
                builder: (_, s) =>
                    Scaffold(body: Text('time off ${s.pathParameters['id']}'))),
            GoRoute(
                path: '/team-handover/:id',
                builder: (_, s) =>
                    Scaffold(body: Text('handover ${s.pathParameters['id']}'))),
            GoRoute(
                path: '/meetings/:id',
                builder: (_, s) =>
                    Scaffold(body: Text('meeting ${s.pathParameters['id']}'))),
          ],
        ),
      ),
      user: user,
    );
