import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/payouts/presentation/bloc/payouts_bloc.dart';
import 'package:real_estate_crm/features/payouts/presentation/widgets/payout_row_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The shares of won deals' commissions and whether each has been paid out.
/// A manager reads the whole agency's, with what each person is still owed;
/// an agent reads what is owed to them. A row opens its deal, where a
/// manager marks the share paid.
class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  final _bloc = PayoutsBloc(Injector.payoutsRepository)
    ..add(PayoutsLoadEvent());

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _open(PayoutItem item) async {
    await context.push('/deals/${item.dealId}');
    if (mounted) _bloc.add(PayoutsLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<PayoutsBloc, PayoutsState>(
      bloc: _bloc,
      builder: (context, state) => DetailScaffold(
        title: l10n.payoutsTitle,
        onRefresh: () async => _bloc.add(PayoutsLoadEvent()),
        children: [
          SegmentedTabs(
            key: const Key('payouts-tabs'),
            labels: [l10n.payoutsUnpaid, l10n.payoutsPaid],
            selectedIndex: state.tab.index,
            onSelected: (i) =>
                _bloc.add(PayoutsTabChanged(PayoutStatus.values[i])),
          ),
          ..._body(state, l10n),
        ],
      ),
    );
  }

  List<Widget> _body(PayoutsState state, AppLocalizations l10n) {
    final list = state.list;
    if (list == null) {
      if (state.load == PayoutsLoad.error) return [_failed(state, l10n)];
      return [
        const ShimmerGroup(child: ShimmerMetricsCard(rows: 1)),
        ..._rowBones(),
      ];
    }

    final t = context.tokens;
    final team = list.wholeTeam;
    return [
      MetricsCard(
        key: const Key('payouts-totals'),
        metrics: [
          Metric(
            value: formatPrice(list.unpaidTotal),
            caption: team ? l10n.payoutsUnpaidTotal : l10n.payoutsOwedToYou,
          ),
          Metric(
            value: formatPrice(list.paidTotal),
            caption: team ? l10n.payoutsPaidTotal : l10n.payoutsPaidToYou,
          ),
        ],
      ),
      if (team &&
          state.tab == PayoutStatus.unpaid &&
          list.byAgent.isNotEmpty) ...[
        SectionHeader(title: l10n.payoutsByAgent, count: list.byAgent.length),
        AppCard(
          key: const Key('payouts-by-agent'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < list.byAgent.length; i++) ...[
                if (i > 0) const SizedBox(height: 11),
                PayoutOwedRow(
                    key: Key('payouts-owed-$i'), total: list.byAgent[i]),
              ],
            ],
          ),
        ),
      ],
      if (team)
        Text(
          l10n.payoutsScopeNote,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12,
              height: 1.4,
              color: t.textSecondary),
        ),
      ..._items(state, list, l10n),
    ];
  }

  List<Widget> _items(
      PayoutsState state, PayoutList list, AppLocalizations l10n) {
    if (state.load == PayoutsLoad.loading) return _rowBones();
    if (state.load == PayoutsLoad.error) return [_failed(state, l10n)];
    if (list.items.isEmpty) {
      final unpaid = state.tab == PayoutStatus.unpaid;
      return [
        EmptyState(
          key: const Key('payouts-empty'),
          icon: unpaid
              ? Icons.task_alt_rounded
              : Icons.account_balance_wallet_outlined,
          title: unpaid ? l10n.payoutsEmptyUnpaid : l10n.payoutsEmptyPaid,
          subtitle:
              unpaid ? l10n.payoutsEmptyUnpaidHint : l10n.payoutsEmptyPaidHint,
        ),
      ];
    }
    return [
      for (final item in list.items)
        PayoutRowCard(
          item: item,
          showParty: list.wholeTeam,
          onTap: () => _open(item),
        ),
    ];
  }

  Widget _failed(PayoutsState state, AppLocalizations l10n) => EmptyState(
        key: const Key('payouts-failed'),
        icon: Icons.cloud_off_outlined,
        title: l10n.payoutsLoadFailed,
        subtitle: state.failure == null
            ? null
            : apiFailureLabel(l10n, state.failure!),
        action: AppGhostButton(
          key: const Key('payouts-retry'),
          label: l10n.coreRetry,
          onPressed: () => _bloc.add(PayoutsLoadEvent()),
        ),
      );

  List<Widget> _rowBones() => [
        for (var i = 0; i < 3; i++)
          const ShimmerGroup(
            child: ShimmerRowCard(
              leading: SizedBox.shrink(),
              trailing: ShimmerBox(width: 64, height: 14, radius: 4),
            ),
          ),
      ];
}
