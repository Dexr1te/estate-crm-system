import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:real_estate_crm/features/admin/presentation/bloc/admin_users_state.dart';
import 'package:real_estate_crm/features/admin/presentation/screens/admin_console_screen.dart';
import 'package:real_estate_crm/features/admin/presentation/widgets/user_card.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/team_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _users = [
  const AgentResponse(
    id: 1,
    fullName: 'Aisha Karimova-Nurpeisova',
    email: 'aisha.karimova@estatecrm.kz',
    role: Role.ADMIN,
    isActive: true,
    isPrimaryAdmin: true,
  ),
  const AgentResponse(
    id: 2,
    fullName: 'Нурлан Беков',
    email: 'nurlan@estatecrm.kz',
    role: Role.MANAGER,
    isActive: true,
  ),
  const AgentResponse(
    id: 3,
    fullName: 'Дана Сейтқали',
    email: 'dana.seitkali@estatecrm.kz',
    role: Role.AGENT,
    isActive: false,
  ),
];

final _teams = [
  const TeamResponse(
      id: 1,
      name: 'Downtown desk',
      managerName: 'Нурлан Беков',
      memberCount: 6),
  const TeamResponse(id: 2, name: 'Загородная недвижимость', memberCount: 3),
];

final _audit = [
  AuditLogResponse(
    id: 1,
    action: 'USER_DEACTIVATED',
    actorEmail: 'aisha.karimova@estatecrm.kz',
    entityType: 'USER',
    entityId: 3,
    createdAt: DateTime(2026, 8, 14, 9, 30),
  ),
  AuditLogResponse(
    id: 2,
    action: 'TEAM_CREATED',
    actorEmail: 'nurlan@estatecrm.kz',
    entityType: 'TEAM',
    entityId: 2,
    createdAt: DateTime(2026, 8, 13, 17, 5),
  ),
];

/// An agency whose server refuses to create a team.
class _RefusingTeams extends FakeTeamsRepository {
  @override
  Future<TeamResponse> createTeam(Map<String, dynamic> body) =>
      Future.error(DioException(
          requestOptions: RequestOptions(path: '/teams'),
          type: DioExceptionType.connectionError));
}

/// Teams as the server counts them; [joined] moves a person into one.
class _LiveTeams extends FakeTeamsRepository {
  List<TeamResponse> current = List.of(_teams);
  int reads = 0;

  void joined(int teamId) => current = [
        for (final t in current)
          t.id == teamId
              ? TeamResponse(
                  id: t.id,
                  name: t.name,
                  managerName: t.managerName,
                  memberCount: t.memberCount + 1)
              : t,
      ];

  @override
  Future<List<TeamResponse>> getTeams() async {
    reads++;
    return current;
  }
}

class _AssigningAdmin extends FakeAdminRepository {
  _AssigningAdmin(this.teams) : super(users: _users, auditLog: _audit);
  final _LiveTeams teams;

  @override
  Future<AgentResponse> assignTeam(int id, int teamId) async {
    teams.joined(teamId);
    return _users.firstWhere((u) => u.id == id);
  }
}

/// The console builds its blocs from [Injector] rather than taking them in, so
/// the seam for a test is the injector itself.
Widget _console({bool pending = false}) {
  Injector.adminRepository = FakeAdminRepository(
    users: pending ? const [] : _users,
    auditLog: pending ? const [] : _audit,
    pending: pending,
  );
  Injector.teamsRepository = FakeTeamsRepository(
    teams: pending ? const [] : _teams,
    pending: pending,
  );
  return BlocProvider(
    create: (_) => AuthBloc(FakeAuthRepository()),
    child: const AdminConsoleScreen(),
  );
}

void main() {
  forEachAcceptanceCase('admin console',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _console(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // An `IndexedStack` builds all three tabs, so one pass lays out the users,
  // teams and audit skeletons together — every size, both themes.
  forEachAcceptanceCase('admin console skeleton',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _console(pending: true),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    // Not pumpAndSettle: the shimmer sweep never settles.
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('admin console renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _console(),
        size: const Size(375, 667),
        brightness: Brightness.light,
        textScale: 1.5,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('every tab waits behind a skeleton shaped like its own rows',
      (tester) async {
    await expectNoOverflow(
      tester,
      _console(pending: true),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );

    // An IndexedStack lays every tab out but marks the hidden ones offstage,
    // which finders skip by default.
    expect(find.byType(UserCardBone, skipOffstage: false), findsWidgets,
        reason: 'people are announced by a round avatar');
    expect(find.byType(TeamCardBone, skipOffstage: false), findsWidgets,
        reason: 'a team is a square mark and a shorter name');
    expect(find.byType(ShimmerCard, skipOffstage: false), findsWidgets);
    expect(find.byType(CircularProgressIndicator, skipOffstage: false),
        findsNothing,
        reason: 'the console skeletons replaced the spinners');
  });

  testWidgets('the loaded console shows its users, teams and audit trail',
      (tester) async {
    await expectNoOverflow(
      tester,
      _console(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(UserCard), findsNWidgets(_users.length));
    expect(find.byType(TeamCard, skipOffstage: false),
        findsNWidgets(_teams.length));
    expect(find.byType(UserCardBone, skipOffstage: false), findsNothing);
  });

  testWidgets(
      'a first team that fails to save leaves the empty tab and its button',
      (tester) async {
    Injector.adminRepository =
        FakeAdminRepository(users: _users, auditLog: _audit);
    Injector.teamsRepository = _RefusingTeams();
    await expectNoOverflow(
      tester,
      BlocProvider(
        create: (_) => AuthBloc(FakeAuthRepository()),
        child: const AdminConsoleScreen(),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('No teams'), findsOneWidget);

    await tester.tap(find.text('New team'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'North');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(ErrorWidget2), findsNothing,
        reason: 'the list loaded fine; only the save failed');
    expect(find.text('No teams'), findsOneWidget);
    expect(find.text('New team'), findsOneWidget,
        reason: 'the admin can try again');
  });

  testWidgets('assigning someone to a team updates that team\'s count',
      (tester) async {
    final teams = _LiveTeams();
    Injector.teamsRepository = teams;
    Injector.adminRepository = _AssigningAdmin(teams);
    await expectNoOverflow(
      tester,
      BlocProvider(
        create: (_) => AuthBloc(FakeAuthRepository()),
        child: const AdminConsoleScreen(),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(teams.reads, 1);

    await tester.tap(find.descendant(
        of: find.byType(UserCard).at(2),
        matching: find.byType(PopupMenuButton<VoidCallback>)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assign team'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Загородная недвижимость'));
    await tester.pumpAndSettle();

    expect(teams.reads, 2, reason: 'the teams are read again after the move');
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.textContaining('4 members'), findsOneWidget);
    expect(find.textContaining('3 members'), findsNothing);
  });

  test('a refused invite over an empty user list keeps the list', () async {
    final bloc = AdminUsersBloc(FakeAdminRepository())
      ..add(AdminUsersLoadEvent());
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s is AdminUsersLoaded);

    bloc.add(AdminInviteUserEvent(const {'email': 'new@estatecrm.kz'}));
    final next = await bloc.stream.firstWhere(
        (s) => s is AdminUsersActionFailure || s is AdminUsersError);

    expect(next, isA<AdminUsersActionFailure>());
  });

  testWidgets("a team's pencil says it edits the team", (tester) async {
    await expectNoOverflow(
      tester,
      Scaffold(
        body: TeamCard(team: _teams.first, onTap: () {}, onEdit: () {}),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );

    expect(find.byTooltip('Edit team'), findsOneWidget);
  });
}
