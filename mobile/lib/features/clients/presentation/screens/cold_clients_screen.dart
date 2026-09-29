import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_actions.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Everyone going cold, at a threshold of 7, 14 or 30 days.
class ColdClientsScreen extends StatefulWidget {
  const ColdClientsScreen({super.key});

  @override
  State<ColdClientsScreen> createState() => _ColdClientsScreenState();
}

class _ColdClientsScreenState extends State<ColdClientsScreen>
    with ColdClientActions<ColdClientsScreen> {
  final _bloc = ColdClientsBloc(
    Injector.coldClientsRepository,
    Injector.tasksRepository,
    limit: 100,
  )..add(ColdClientsLoadEvent());

  @override
  ColdClientsBloc get coldBloc => _bloc;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ColdClientsBloc, ColdClientsState>(
        listener: onColdState,
        builder: (context, state) => DetailScaffold(
          title: l10n.clientsColdTitle,
          trailingLabel:
              state is ColdClientsLoaded ? '${state.clients.length}' : null,
          onRefresh: () async => _bloc.add(ColdClientsLoadEvent()),
          children: [
            Text(l10n.clientsColdSubtitle(state.days),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: context.tokens.textSecondary)),
            FilterPillRow(
              padding: EdgeInsets.zero,
              pills: [
                for (final days in ColdClientsRepository.thresholds)
                  FilterPill(
                    key: ValueKey('cold-days-$days'),
                    label: l10n.clientsColdDaysOption(days),
                    selected: state.days == days,
                    onTap: () => _bloc.add(ColdClientsLoadEvent(days: days)),
                  ),
              ],
            ),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, ColdClientsState state, AppLocalizations l10n) {
    if (state is ColdClientsError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.clientsColdLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(ColdClientsLoadEvent())),
        ),
      ];
    }
    if (state is! ColdClientsLoaded) {
      return [for (var i = 0; i < 4; i++) const ColdClientRowBone()];
    }
    if (state.clients.isEmpty) {
      return [
        EmptyState(
          icon: Icons.local_fire_department_outlined,
          title: l10n.clientsColdEmpty,
          subtitle: l10n.clientsColdEmptyHint(state.days),
        ),
      ];
    }
    return [
      for (final client in state.clients)
        ColdClientRow(
          client: client,
          onTap: () => context.push('/clients/${client.id}'),
          onCall: () => callCold(client),
          onRemind: () => remindCold(client),
        ),
    ];
  }
}
