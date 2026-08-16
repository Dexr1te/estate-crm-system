import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
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
        textScale: 1.3,
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
}
