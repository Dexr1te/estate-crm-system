import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leases/presentation/bloc/leases_ending_bloc.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Every won rent whose lease ends in the next 30 days, soonest first: the
/// tenants and landlords to call about staying on.
class LeasesEndingScreen extends StatefulWidget {
  const LeasesEndingScreen({super.key});

  @override
  State<LeasesEndingScreen> createState() => _LeasesEndingScreenState();
}

class _LeasesEndingScreenState extends State<LeasesEndingScreen> {
  final _bloc = LeasesEndingBloc(Injector.leasesRepository)
    ..add(LeasesEndingLoadEvent());

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
      child: BlocBuilder<LeasesEndingBloc, LeasesEndingState>(
        builder: (context, state) => DetailScaffold(
          title: l10n.leasesEndingTitle,
          trailingLabel:
              state is LeasesEndingLoaded ? '${state.leases.length}' : null,
          onRefresh: () async => _bloc.add(LeasesEndingLoadEvent()),
          children: _body(context, state, l10n),
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, LeasesEndingState state, AppLocalizations l10n) {
    if (state is LeasesEndingError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.leasesEndingLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(LeasesEndingLoadEvent())),
        ),
      ];
    }
    if (state is! LeasesEndingLoaded) {
      return [for (var i = 0; i < 4; i++) const LeaseRowBone()];
    }
    if (state.leases.isEmpty) {
      return [
        EmptyState(
          icon: Icons.key_outlined,
          title: l10n.leasesEndingEmpty,
          subtitle: l10n.leasesEndingEmptyHint,
        ),
      ];
    }
    return [
      for (final lease in state.leases)
        LeaseRow(
          lease: lease,
          onTap: () => context.push('/deals/${lease.dealId}'),
        ),
    ];
  }
}
