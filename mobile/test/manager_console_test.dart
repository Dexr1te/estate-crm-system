import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
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

// Tall enough that the whole settings segment shows without scrolling; the
// acceptance cases still pass their own sizes.
Future<void> _pumpConsole(WidgetTester tester,
    {Size size = const Size(390, 1400),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  // Signed in as the manager: the console's export card follows the session.
  await expectNoOverflow(
      tester,
      BlocProvider(
          create: (_) => AuthBloc(FakeAuthRepository(
              user: const AuthResponse(
                  userId: 1,
                  fullName: 'Nurlan Bekov',
                  role: Role.MANAGER,
                  teamId: 1)))
            ..add(AuthCheckEvent()),
          // A fresh console each time, so a second pump reads the team the
          // repository holds now rather than keeping the first one's.
          child: ManagerConsoleScreen(key: UniqueKey())),
      size: size,
      brightness: brightness,
      textScale: scale,
      locale: locale);
  await tester.pumpAndSettle();
}

/// The console's segments, in order.
Finder _segment(int index) => find
    .descendant(
        of: find.byKey(const ValueKey('console-tabs')),
        matching: find.byType(InkWell))
    .at(index);

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(_segment(2));
  await tester.pumpAndSettle();
}

/// Everything the settings segment holds, and nothing the members tab may.
const _toolKeys = <Key>[
  Key('currency-row'),
  Key('checklist-template-row'),
  Key('message-templates-row'),
  Key('team-goals-row'),
  Key('leaderboard-row'),
  Key('payouts-row'),
  ValueKey('import-entry'),
  Key('change-log-row'),
  ValueKey('export-console'),
];

void main() {
  forEachAcceptanceCase('manager console',
      (tester, size, brightness, scale) async {
    _teams(members: const [_manager, _agent, _invited], requests: [_pending]);
    for (final locale in kAcceptanceLocales) {
      await _pumpConsole(tester,
          size: size, brightness: brightness, scale: scale, locale: locale);
      for (var tab = 0; tab < 3; tab++) {
        await tester.tap(_segment(tab));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${locale.languageCode}, segment $tab');
      }
    }
  });

  testWidgets('the members tab holds people only', (tester) async {
    _teams();
    await _pumpConsole(tester);

    expect(find.byKey(const ValueKey('console-members')), findsOneWidget);
    for (final key in _toolKeys) {
      expect(find.byKey(key, skipOffstage: false), findsNothing,
          reason: '$key belongs under Settings');
    }

    _teams(members: const []);
    await _pumpConsole(tester);
    expect(find.text('Nobody here yet'), findsOneWidget);
    for (final key in _toolKeys) {
      expect(find.byKey(key, skipOffstage: false), findsNothing,
          reason: '$key belongs under Settings, empty team or not');
    }
  });

  testWidgets('the settings segment holds every tool, in a team or not',
      (tester) async {
    for (final members in const [
      [_manager, _agent],
      <TeamMemberResponse>[],
    ]) {
      _teams(members: members);
      await _pumpConsole(tester);
      expect(find.text('Settings'), findsOneWidget);
      await _openSettings(tester);

      expect(find.byKey(const ValueKey('console-settings')), findsOneWidget);
      for (final key in _toolKeys) {
        expect(find.byKey(key), findsOneWidget, reason: '$key');
      }
      expect(find.text('Aigerim Serikbaykyzy'), findsNothing,
          reason: 'people stay on the members tab');
    }
  });

  testWidgets('the settings run agency, then performance, then data',
      (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);

    double top(Key key) => tester.getTopLeft(find.byKey(key)).dy;
    final order = [for (final key in _toolKeys) top(key)];
    expect(order, [...order]..sort(), reason: 'in the order of _toolKeys');
    for (final eyebrow in ['AGENCY', 'PERFORMANCE', 'DATA']) {
      expect(find.text(eyebrow), findsOneWidget);
    }
  });

  testWidgets('the members header says it opens the team stats',
      (tester) async {
    _teams();
    await _pumpConsole(tester);

    expect(find.text('Agents'), findsNothing,
        reason: 'it opened the stats, not a list of agents');
    await tester.tap(find.text('Team stats'));
    await tester.pumpAndSettle();
    expect(find.byType(MetricsCard), findsOneWidget);
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

  testWidgets('the agency deal checklist is edited from here', (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('checklist-template-row')), findsOneWidget);
    expect(find.text('Deal checklist'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('checklist-template-row')), findsOneWidget);
  });

  testWidgets('the agency message templates are kept from here',
      (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('message-templates-row')), findsOneWidget);
    expect(find.text('Message templates'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('message-templates-row')), findsOneWidget);
  });

  testWidgets('the monthly goals are set from here', (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('team-goals-row')), findsOneWidget);
    expect(find.text('Monthly goals'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('team-goals-row')), findsOneWidget);
  });

  testWidgets('what the agency owes from split commissions is read from here',
      (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('payouts-row')), findsOneWidget);
    expect(find.text('Payouts'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('payouts-row')), findsOneWidget);
  });

  testWidgets("the agency's change log is read from here", (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('change-log-row')), findsOneWidget);
    expect(find.text('Change log'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const Key('change-log-row')), findsOneWidget);
  });

  testWidgets('bringing the book in from a spreadsheet starts here',
      (tester) async {
    _teams();
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const ValueKey('import-entry')), findsOneWidget);
    expect(find.text('Import from a spreadsheet'), findsOneWidget);

    _teams(members: const []);
    await _pumpConsole(tester);
    await _openSettings(tester);
    expect(find.byKey(const ValueKey('import-entry')), findsOneWidget,
        reason: 'a new agency with nobody in it yet is who needs it most');
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

  testWidgets('adding an agent sits by the team name, not in a bottom bar',
      (tester) async {
    _teams();
    await _pumpConsole(tester);

    final add = find.widgetWithText(AppHeaderAction, 'Add agent');
    expect(add, findsOneWidget);
    expect(tester.getTopLeft(add).dy,
        lessThan(tester.getTopLeft(find.byType(SegmentedTabs)).dy));
    expect(find.widgetWithText(AppFilledButton, 'Add agent'), findsNothing);
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

  testWidgets(
      'an address with no account is reported as an invite, not a request',
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
