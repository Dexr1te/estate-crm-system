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
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_form.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/today_tasks_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Every tasks surface at every acceptance size, theme, text scale and
/// language, with the longest titles and names an agency is likely to type:
/// nothing may overflow.

final _now = DateTime(2026, 9, 25, 15, 30);

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

final _long = [
  TaskResponse(
    id: 1,
    title: 'Call Irina Alexandrovna back about the second viewing and the '
        'mortgage pre-approval letter from the bank',
    dueAt: _now.subtract(const Duration(days: 2)),
    clientId: 1,
    clientName: 'Irina Alexandrovna Sokolova-Rozhdestvenskaya',
    assigneeId: 8,
    assigneeName: 'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky',
  ),
  TaskResponse(
    id: 2,
    title: 'Send the contract',
    dueAt: _now.add(const Duration(hours: 2)),
    dealId: 3,
    dealTitle: 'Severny Residence, apartment 214, third floor',
    assigneeId: 7,
  ),
];

Future<void> _case(WidgetTester tester, Widget child, Size size,
    Brightness brightness, double scale) async {
  final auth = AuthBloc(FakeAuthRepository(user: _manager))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  for (final locale in kAcceptanceLocales) {
    await expectNoOverflow(
      tester,
      BlocProvider.value(value: auth, child: child),
      size: size,
      brightness: brightness,
      textScale: scale,
      locale: locale,
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull,
        reason: '${locale.languageCode} after load');
  }
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    Injector.tasksRepository = FakeTasksRepository(List.of(_long));
  });
  tearDown(AppClock.reset);

  forEachAcceptanceCase('the tasks card on a record', (t, size, b, s) async {
    await _case(
        t,
        const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: RecordTasksCard(
                client: PickerItem(id: 1, title: 'Irina Sokolova')),
          ),
        ),
        size,
        b,
        s);
  });

  forEachAcceptanceCase('the dashboard today card', (t, size, b, s) async {
    final bloc = TasksBloc(Injector.tasksRepository)..add(TasksLoadEvent());
    addTearDown(bloc.close);
    await _case(
        t,
        BlocProvider.value(
          value: bloc,
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: TodayTasksCard(onSeeAll: () {}),
            ),
          ),
        ),
        size,
        b,
        s);
  });

  forEachAcceptanceCase('the task sheet', (t, size, b, s) async {
    await _case(
        t,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AppSheetShell(
              title: 'Edit task',
              child: TaskForm(
                task: _long.first,
                client: const PickerItem(
                    id: 1,
                    title: 'Irina Alexandrovna Sokolova-Rozhdestvenskaya'),
                assignee: const PickerItem(
                    id: 8,
                    title:
                        'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky'),
                canAssign: true,
                onSave: (_) async {},
                onDelete: () async {},
              ),
            ),
          ),
        ),
        size,
        b,
        s);
  });

  forEachAcceptanceCase('the tasks screen', (t, size, b, s) async {
    await _case(t, const TasksScreen(), size, b, s);
  });
}
