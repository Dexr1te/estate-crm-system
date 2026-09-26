import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:real_estate_crm/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/record_tasks_card.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/today_tasks_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Tasks on the phone: the card on a client or deal, the sheet that writes
/// one, the dashboard's list of what is due today and the screen with all of
/// them. What matters is that ticking a task takes it off the list, that a new
/// task is tied to the record it was added from, that only someone running the
/// team is asked who should do it, and that overdue work is called out.

final _now = DateTime(2026, 9, 25, 15, 30);

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);
const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

TaskResponse _task(int id, String title, Duration fromNow,
        {int? clientId, bool done = false, int assignee = 5}) =>
    TaskResponse(
      id: id,
      title: title,
      dueAt: _now.add(fromNow),
      clientId: clientId,
      clientName: clientId == null ? null : 'Irina Sokolova',
      assigneeId: assignee,
      assigneeName: assignee == 5 ? 'Maria Kim' : 'Timur Aliev',
      completedAt: done ? _now.subtract(const Duration(hours: 1)) : null,
    );

late FakeTasksRepository _tasks;

Future<void> _pump(WidgetTester tester, Widget child,
    {AuthResponse me = _agent, Size size = const Size(390, 844)}) async {
  final auth = AuthBloc(FakeAuthRepository(user: me))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  await expectNoOverflow(
    tester,
    BlocProvider.value(value: auth, child: child),
    size: size,
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

Widget _record() => const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child:
            RecordTasksCard(client: PickerItem(id: 1, title: 'Irina Sokolova')),
      ),
    );

Widget _today(TasksBloc bloc) => BlocProvider.value(
      value: bloc,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TodayTasksCard(onSeeAll: () {}),
        ),
      ),
    );

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _tasks = FakeTasksRepository([
      _task(1, 'Call Irina back', const Duration(hours: -3), clientId: 1),
      _task(2, 'Send the contract', const Duration(days: 2), clientId: 1),
      _task(3, 'Somebody else\'s client', const Duration(hours: 1)),
      _task(4, 'Already done', const Duration(days: -1),
          clientId: 1, done: true),
    ]);
    Injector.tasksRepository = _tasks;
    Injector.agentsRepository = const FakeAgentsRepository([
      AgentOption(id: 5, fullName: 'Maria Kim'),
      AgentOption(id: 8, fullName: 'Timur Aliev'),
    ]);
  });
  tearDown(AppClock.reset);

  group('the card on a client', () {
    testWidgets('lists that client\'s open tasks, overdue ones flagged',
        (tester) async {
      await _pump(tester, _record());

      expect(find.text('Call Irina back'), findsOneWidget);
      expect(find.text('Send the contract'), findsOneWidget);
      expect(find.text('Somebody else\'s client'), findsNothing);
      expect(find.text('Already done'), findsNothing);
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('ticking a task completes it and takes it off the card',
        (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.byTooltip('Mark done').first);
      await tester.pumpAndSettle();

      expect(_tasks.tasks.firstWhere((t) => t.id == 1).isDone, isTrue);
      expect(find.text('Call Irina back'), findsNothing);
      expect(find.text('Task done'), findsOneWidget);
    });

    testWidgets('a task added here is tied to the client', (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      expect(find.text('Irina Sokolova'), findsOneWidget,
          reason: 'the sheet starts linked to the record it came from');
      expect(find.text('Who does it'), findsNothing,
          reason: 'an agent does their own tasks');

      await tester.enterText(find.byType(TextFormField).first, 'Book a notary');
      await tester.tap(find.text('Today evening'));
      await tester.pump();
      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();

      final sent = _tasks.sent.single;
      expect(sent['title'], 'Book a notary');
      expect(sent['clientId'], 1);
      expect(sent['dueAt'], DateTime(2026, 9, 25, 18).toIso8601String());
      expect(sent.containsKey('assigneeId'), isFalse);
      expect(find.text('Book a notary'), findsOneWidget);
      expect(find.text('Task added'), findsOneWidget);
    });

    testWidgets('a task needs a title and a time before it is sent',
        (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save task'));
      await tester.tap(find.text('Save task'));
      await tester.pumpAndSettle();

      expect(find.text('Say what needs doing'), findsOneWidget);
      expect(find.text('Please select a date and time'), findsOneWidget);
      expect(_tasks.sent, isEmpty);
    });

    testWidgets('a manager is asked who should do it', (tester) async {
      await _pump(tester, _record(), me: _manager);

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();

      expect(find.text('Who does it'), findsOneWidget);
      expect(find.text('Asel Nurlanovna'), findsOneWidget,
          reason: 'it goes to whoever writes it until someone else is picked');
    });

    testWidgets('tapping a task edits it; deleting asks first', (tester) async {
      await _pump(tester, _record());

      await tester.tap(find.text('Send the contract'));
      await tester.pumpAndSettle();
      expect(find.text('Edit task'), findsOneWidget);

      await tester.ensureVisible(find.text('Delete task'));
      await tester.tap(find.text('Delete task'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this task?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(_tasks.tasks.map((t) => t.id), isNot(contains(2)));
      expect(find.text('Send the contract'), findsNothing);
    });

    testWidgets('a failed read says so and offers to try again',
        (tester) async {
      _tasks.readError = Exception('offline');
      await _pump(tester, _record());

      expect(find.text('Could not load tasks'), findsOneWidget);
      _tasks.readError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Call Irina back'), findsOneWidget);
    });
  });

  group('the dashboard', () {
    testWidgets('shows what is overdue or due today, not tomorrow\'s work',
        (tester) async {
      final bloc = TasksBloc(_tasks)..add(TasksLoadEvent());
      addTearDown(bloc.close);
      await _pump(tester, _today(bloc));

      expect(find.text('Call Irina back'), findsOneWidget);
      expect(find.text('Somebody else\'s client'), findsOneWidget);
      expect(find.text('Send the contract'), findsNothing);
      expect(find.text('1 overdue'), findsOneWidget);

      await tester.tap(find.byTooltip('Mark done').first);
      await tester.pumpAndSettle();
      expect(find.text('Call Irina back'), findsNothing);
      expect(find.text('1 overdue'), findsNothing);
    });

    testWidgets('a clear day says so', (tester) async {
      _tasks.tasks = const [];
      final bloc = TasksBloc(_tasks)..add(TasksLoadEvent());
      addTearDown(bloc.close);
      await _pump(tester, _today(bloc));

      expect(find.text('Nothing due today'), findsOneWidget);
      expect(find.text('All tasks'), findsOneWidget);
    });
  });

  group('all tasks', () {
    testWidgets('open soonest first, done on its own tab, and reopenable',
        (tester) async {
      await _pump(tester, const TasksScreen());

      expect(find.text('3 open'), findsOneWidget);
      expect(find.text('Already done'), findsNothing);
      final first = tester.getTopLeft(find.text('Call Irina back')).dy;
      final later = tester.getTopLeft(find.text('Send the contract')).dy;
      expect(first, lessThan(later));

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Already done'), findsOneWidget);
      expect(find.text('Call Irina back'), findsNothing);

      await tester.tap(find.byTooltip('Reopen'));
      await tester.pumpAndSettle();
      expect(_tasks.tasks.firstWhere((t) => t.id == 4).isDone, isFalse);
      expect(find.text('Already done'), findsNothing);
    });

    testWidgets('a colleague\'s task says whose it is', (tester) async {
      _tasks.tasks = [
        _task(9, 'Visit the flat', const Duration(hours: 2), assignee: 8),
      ];
      await _pump(tester, const TasksScreen(), me: _manager);

      expect(find.textContaining('for Timur Aliev'), findsOneWidget);
    });
  });
}
