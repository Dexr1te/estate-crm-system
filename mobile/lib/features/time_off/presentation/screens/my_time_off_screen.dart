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

/// The signed-in user's own time off: what is on now and coming up, soonest
/// first, then what is over, latest first. Adding one, or opening one to
/// change or cancel it, and the way to the team's "who's out".
class MyTimeOffScreen extends StatefulWidget {
  const MyTimeOffScreen({super.key});

  @override
  State<MyTimeOffScreen> createState() => _MyTimeOffScreenState();
}

class _MyTimeOffScreenState extends State<MyTimeOffScreen> {
  late final TimeOffListBloc _bloc = TimeOffListBloc.mine(
      Injector.timeOffRepository, context.currentUserId ?? 0)
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
          title: l10n.timeOffTitle,
          actions: [
            AppIconTile(
              key: const ValueKey('time-off-add'),
              icon: Icons.edit_calendar_outlined,
              tooltip: l10n.timeOffAdd,
              onPressed: () => _open('/time-off/new'),
            ),
          ],
          onRefresh: () async => _bloc.add(TimeOffListLoadEvent()),
          children: [
            SettingsGroup(rows: [
              SettingsRow(
                key: const ValueKey('time-off-whos-out'),
                label: l10n.timeOffWhosOut,
                showChevron: true,
                onTap: () => context.push('/time-off/team'),
              ),
            ]),
            ..._body(context, state, l10n),
          ],
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
      return [for (var i = 0; i < 3; i++) const TimeOffRowBone()];
    }
    if (state.items.isEmpty) {
      return [
        EmptyState(
          icon: Icons.beach_access_outlined,
          title: l10n.timeOffEmpty,
          subtitle: l10n.timeOffEmptyHint,
          action: AppGhostButton(
            key: const ValueKey('time-off-empty-add'),
            label: l10n.timeOffAdd,
            onPressed: () => _open('/time-off/new'),
          ),
        ),
      ];
    }
    final now = AppClock.now();
    final ahead = state.items
        .where((t) => timeOffWhen(t, now) != TimeOffWhen.past)
        .toList();
    final past = state.items
        .where((t) => timeOffWhen(t, now) == TimeOffWhen.past)
        .toList()
        .reversed
        .toList();
    return [
      if (ahead.isNotEmpty) ...[
        SectionHeader(title: l10n.timeOffSectionUpcoming, count: ahead.length),
        for (final t in ahead)
          TimeOffRow(timeOff: t, onTap: () => _open('/time-off/${t.id}')),
      ],
      if (past.isNotEmpty) ...[
        SectionHeader(title: l10n.timeOffSectionPast, count: past.length),
        for (final t in past)
          TimeOffRow(timeOff: t, onTap: () => _open('/time-off/${t.id}')),
      ],
    ];
  }
}
