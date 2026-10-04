import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';
import 'package:real_estate_crm/features/time_off/presentation/bloc/time_off_list_bloc.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Who's out: the agency's time off over the next three months, as out today,
/// starting this week, and later, each with who covers. Everybody in the
/// agency sees it; a manager writes down anybody's from here.
class TeamTimeOffScreen extends StatefulWidget {
  const TeamTimeOffScreen({super.key});

  @override
  State<TeamTimeOffScreen> createState() => _TeamTimeOffScreenState();
}

class _TeamTimeOffScreenState extends State<TeamTimeOffScreen> {
  final _bloc = TimeOffListBloc.team(Injector.timeOffRepository)
    ..add(TimeOffListLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) _bloc.add(TimeOffListLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<TimeOffListBloc, TimeOffListState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.timeOffWhosOut,
          actions: [
            if (context.isManager)
              AppIconTile(
                key: const ValueKey('time-off-team-add'),
                icon: Icons.edit_calendar_outlined,
                tooltip: l10n.timeOffAdd,
                onPressed: () => _open('/time-off/new'),
              ),
          ],
          onRefresh: () async => _bloc.add(TimeOffListLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, TimeOffListState state, AppLocalizations l10n) {
    if (state is TimeOffListError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.timeOffLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(TimeOffListLoadEvent())),
        ),
      ];
    }
    if (state is! TimeOffListLoaded) {
      return [for (var i = 0; i < 4; i++) const TimeOffRowBone()];
    }
    if (state.items.isEmpty) {
      return [
        EmptyState(
          icon: Icons.groups_outlined,
          title: l10n.timeOffTeamEmpty,
          subtitle: l10n.timeOffTeamEmptyHint,
        ),
      ];
    }
    final now = AppClock.now();
    final sections = <(String, TimeOffWhen)>[
      (l10n.timeOffSectionToday, TimeOffWhen.today),
      (l10n.timeOffSectionThisWeek, TimeOffWhen.thisWeek),
      (l10n.timeOffSectionLater, TimeOffWhen.later),
    ];
    return [
      for (final (title, section) in sections)
        ...() {
          final items =
              state.items.where((t) => timeOffWhen(t, now) == section).toList();
          if (items.isEmpty) return const <Widget>[];
          return <Widget>[
            SectionHeader(
              key: ValueKey('time-off-section-${section.name}'),
              title: title,
              count: items.length,
            ),
            for (final t in items)
              TimeOffRow(
                timeOff: t,
                showPerson: true,
                onTap: () => _open('/time-off/${t.id}'),
              ),
          ];
        }(),
    ];
  }
}
