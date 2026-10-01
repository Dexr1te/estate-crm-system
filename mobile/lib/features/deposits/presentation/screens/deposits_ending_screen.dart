import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deposits_ending_bloc.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Every active deposit whose hold ends within a week or has ended, soonest
/// first: the buyers to chase for a decision.
class DepositsEndingScreen extends StatefulWidget {
  const DepositsEndingScreen({super.key});

  @override
  State<DepositsEndingScreen> createState() => _DepositsEndingScreenState();
}

class _DepositsEndingScreenState extends State<DepositsEndingScreen> {
  final _bloc = DepositsEndingBloc(Injector.depositsRepository)
    ..add(DepositsEndingLoadEvent());

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
      child: BlocBuilder<DepositsEndingBloc, DepositsEndingState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.depositsEndingTitle,
          trailingLabel:
              state is DepositsEndingLoaded ? '${state.deposits.length}' : null,
          onRefresh: () async => _bloc.add(DepositsEndingLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, DepositsEndingState state, AppLocalizations l10n) {
    if (state is DepositsEndingError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.depositsEndingLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(DepositsEndingLoadEvent())),
        ),
      ];
    }
    if (state is! DepositsEndingLoaded) {
      return [for (var i = 0; i < 4; i++) const DepositRowBone()];
    }
    if (state.deposits.isEmpty) {
      return [
        EmptyState(
          icon: Icons.savings_outlined,
          title: l10n.depositsEndingEmpty,
          subtitle: l10n.depositsEndingEmptyHint,
        ),
      ];
    }
    return [
      for (final deposit in state.deposits)
        DepositRow(
          deposit: deposit,
          onTap: () => context.push('/deals/${deposit.dealId}'),
        ),
    ];
  }
}
