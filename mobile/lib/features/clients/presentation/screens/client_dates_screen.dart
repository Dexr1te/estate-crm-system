import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/client_dates_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_date_actions.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_date_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Birthdays and purchase anniversaries in the next two weeks, today first,
/// each with a call and a greeting.
class ClientDatesScreen extends StatefulWidget {
  const ClientDatesScreen({super.key});

  @override
  State<ClientDatesScreen> createState() => _ClientDatesScreenState();
}

class _ClientDatesScreenState extends State<ClientDatesScreen> {
  final _bloc = ClientDatesBloc(Injector.clientDatesRepository)
    ..add(ClientDatesLoadEvent());

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
      child: BlocBuilder<ClientDatesBloc, ClientDatesState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.clientsDatesTitle,
          trailingLabel:
              state is ClientDatesLoaded ? '${state.dates.length}' : null,
          onRefresh: () async => _bloc.add(ClientDatesLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, ClientDatesState state, AppLocalizations l10n) {
    if (state is ClientDatesError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.clientsDatesLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(ClientDatesLoadEvent())),
        ),
      ];
    }
    if (state is! ClientDatesLoaded) {
      return [for (var i = 0; i < 4; i++) const ClientDateRowBone()];
    }
    if (state.dates.isEmpty) {
      return [
        EmptyState(
          icon: Icons.cake_outlined,
          title: l10n.clientsDatesEmpty,
          subtitle: l10n.clientsDatesEmptyHint,
        ),
      ];
    }
    final showAgent = seesAgencyDates(context);
    return [
      for (final date in state.dates)
        ClientDateRow(
          date: date,
          showAgent: showAgent,
          onTap: () => context.push('/clients/${date.clientId}'),
          onCall: () => callClientDate(context, date),
          onGreet: () => greetClientDate(context, date),
        ),
    ];
  }
}
