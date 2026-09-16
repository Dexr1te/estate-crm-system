import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/manager_console_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _team = TeamResponse(id: 1, name: 'Almaty Realty', memberCount: 3);

const _manager = TeamMemberResponse(
  id: 1,
  fullName: 'Nurlan Bekov',
  email: 'nurlan@almaty.kz',
  role: Role.MANAGER,
  status: UserAccountStatus.active,
  isActive: true,
  isTeamManager: true,
);

const _agent = TeamMemberResponse(
  id: 2,
  fullName: 'Aigerim Serikbaykyzy',
  email: 'aigerim@almaty.kz',
  role: Role.AGENT,
  status: UserAccountStatus.active,
  isActive: true,
  isTeamManager: false,
);

const _invited = TeamMemberResponse(
  id: 3,
  fullName: 'Daniyar Nurlanuly',
  email: 'daniyar@almaty.kz',
  role: Role.AGENT,
  status: UserAccountStatus.pendingInvite,
  isActive: true,
  isTeamManager: false,
);

final _pending = TeamJoinRequestResponse(
  id: 8,
  teamId: 1,
  teamName: 'Almaty Realty',
  invitedByName: 'Nurlan Bekov',
  userId: 5,
  userFullName: 'Madina Abenova',
  userEmail: 'madina@almaty.kz',
  createdAt: DateTime(2026, 9, 10),
);

FakeTeamsRepository _teams({
  List<TeamMemberResponse> members = const [_manager, _agent],
  List<TeamJoinRequestResponse> requests = const [],
  AddMemberResult? addResult,
}) {
  final repo = FakeTeamsRepository(
    myTeam: _team,
    members: members,
    requests: requests,
    addResult: addResult ?? const AddMemberResult(requestSent: true),
  );
  Injector.teamsRepository = repo;
  return repo;
}

Future<void> _pumpConsole(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double scale = 1.0}) async {
  await expectNoOverflow(tester, const ManagerConsoleScreen(),
      size: size, brightness: brightness, textScale: scale);
  await tester.pumpAndSettle();
}

void main() {
  forEachAcceptanceCase('manager console',
      (tester, size, brightness, scale) async {
    _teams(members: const [_manager, _agent, _invited], requests: [_pending]);
    await _pumpConsole(tester,
        size: size, brightness: brightness, scale: scale);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the team is listed with its manager marked', (tester) async {
    _teams();
    await _pumpConsole(tester);

    expect(find.text('Almaty Realty'), findsOneWidget);
    expect(find.text('Nurlan Bekov'), findsOneWidget);
    expect(find.text('Aigerim Serikbaykyzy'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget,
        reason: 'the manager is marked so a removal cannot be aimed at them');
  });

  testWidgets('an invite nobody has used says so', (tester) async {
    _teams(members: const [_manager, _invited]);
    await _pumpConsole(tester);

    expect(find.text('Invited'), findsOneWidget);
  });

  testWidgets('unanswered requests live on their own tab', (tester) async {
    _teams(requests: [_pending]);
    await _pumpConsole(tester);

    expect(find.text('Madina Abenova'), findsNothing);

    await tester.tap(find.textContaining('Pending'));
    await tester.pumpAndSettle();

    expect(find.text('Madina Abenova'), findsOneWidget);
    expect(find.text('madina@almaty.kz'), findsOneWidget);
  });

  testWidgets('a request can be withdrawn while it is unanswered',
      (tester) async {
    final teams = _teams(requests: [_pending]);
    await _pumpConsole(tester);

    await tester.tap(find.textContaining('Pending'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();

    expect(teams.cancelled, _pending.id);
  });

  testWidgets('adding an agent sends the address that was typed',
      (tester) async {
    final teams = _teams();
    await _pumpConsole(tester);

    await tester.tap(find.text('Add agent'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'name@estatecrm.ru'),
        'madina@almaty.kz');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'), 'Madina Abenova');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(teams.added, ('madina@almaty.kz', 'Madina Abenova'));
  });

  testWidgets('an address with no account is reported as an invite, not a request',
      (tester) async {
    _teams(
        addResult: const AddMemberResult(
      requestSent: false,
      member: TeamMemberResponse(
        id: 9,
        fullName: 'Madina Abenova',
        email: 'madina@almaty.kz',
        role: Role.AGENT,
        status: UserAccountStatus.pendingInvite,
        isActive: true,
        isTeamManager: false,
      ),
    ));
    await _pumpConsole(tester);

    await tester.tap(find.text('Add agent'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'name@estatecrm.ru'),
        'madina@almaty.kz');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'), 'Madina Abenova');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.textContaining('invite has been emailed'), findsOneWidget);
  });

  testWidgets('removing an agent asks who takes over their work',
      (tester) async {
    final teams = _teams();
    await _pumpConsole(tester);

    await tester.tap(find.text('Aigerim Serikbaykyzy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from team'));
    await tester.pumpAndSettle();

    // The picker, then the confirmation: nothing has happened yet.
    expect(teams.removed, isNull);
    expect(find.text('Records go to'), findsOneWidget);
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Remove from team').last);
    await tester.pumpAndSettle();

    expect(teams.removed, (_agent.id, _manager.id));
  });

  testWidgets('the manager cannot be removed from their own team',
      (tester) async {
    _teams();
    await _pumpConsole(tester);

    await tester.tap(find.text('Nurlan Bekov'));
    await tester.pumpAndSettle();

    expect(find.text('Remove from team'), findsNothing);
  });
}
