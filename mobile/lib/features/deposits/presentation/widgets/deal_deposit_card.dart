import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deal_deposits_bloc.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_labels.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_sheets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The deal's deposit: the active one with what it is, who holds it and how
/// long the listing is held, or a way to record one; the ones that ended
/// below. Reads a [DealDepositsBloc] above it. [onSaved] runs after every
/// write the server took.
class DealDepositCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback? onSaved;

  const DealDepositCard({super.key, required this.deal, this.onSaved});

  bool _canEdit(BuildContext context) =>
      context.isAdminOrManager || deal.agentId == context.currentUserId;

  bool get _dealOpen =>
      deal.status != DealStatus.CLOSED_WON &&
      deal.status != DealStatus.CLOSED_LOST;

  Future<void> _record(BuildContext context) async {
    final bloc = context.read<DealDepositsBloc>();
    final draft = await showDepositSheet(context);
    if (draft != null) bloc.add(DealDepositsRecordEvent(draft));
  }

  Future<void> _edit(BuildContext context, DealDeposit d) async {
    final bloc = context.read<DealDepositsBloc>();
    final draft = await showDepositSheet(context, initial: d);
    if (draft != null) bloc.add(DealDepositsUpdateEvent(d.id, draft));
  }

  Future<void> _close(BuildContext context, DealDeposit d) async {
    final bloc = context.read<DealDepositsBloc>();
    final closing = await showCloseDepositSheet(context, d);
    if (closing != null) bloc.add(DealDepositsCloseEvent(d.id, closing));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<DealDepositsBloc, DealDepositsState>(
      listenWhen: (prev, next) =>
          next.outcome != null || next.saved != prev.saved,
      listener: (context, state) {
        if (state.outcome != null) {
          showActionOutcome(context, state.outcome);
        } else {
          onSaved?.call();
        }
      },
      builder: (context, state) => AppCard(
        key: const Key('deal-deposit-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EyebrowLabel(l10n.depositsTitle),
            const SizedBox(height: 11),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, DealDepositsState state, AppLocalizations l10n) {
    final t = context.tokens;
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
    switch (state.status) {
      case DealDepositsStatus.loading:
        return const [
          ShimmerGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerBar(widthFactor: 0.5, height: 14),
                SizedBox(height: 10),
                ShimmerBar(widthFactor: 0.7, height: 12),
              ],
            ),
          ),
        ];
      case DealDepositsStatus.error:
        return [
          Text(l10n.depositsLoadFailed,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
          const SizedBox(height: 10),
          AppGhostButton(
            key: const Key('deal-deposit-retry'),
            label: l10n.coreRetry,
            height: AppMetrics.buttonHeightInline,
            onPressed: () =>
                context.read<DealDepositsBloc>().add(DealDepositsLoadEvent()),
          ),
        ];
      case DealDepositsStatus.loaded:
        final active = state.active;
        final past = state.deposits.where((d) => !d.active).toList();
        final canEdit = _canEdit(context);
        return [
          if (active != null)
            ..._active(context, active, l10n, canEdit && !state.saving)
          else ...[
            Text(l10n.depositsNone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary)),
            const SizedBox(height: 4),
            Text(
                _dealOpen ? l10n.depositsNoneHint : l10n.depositsDealClosedHint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: secondary),
            if (canEdit && _dealOpen) ...[
              const SizedBox(height: 10),
              AppGhostButton(
                key: const Key('deal-deposit-record'),
                label: l10n.depositsRecord,
                height: AppMetrics.buttonHeightInline,
                onPressed: state.saving ? null : () => _record(context),
              ),
            ],
          ],
          if (past.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l10n.depositsHistory,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.textHint)),
            for (final d in past) ...[
              const SizedBox(height: 6),
              _PastRow(deposit: d),
            ],
          ],
        ];
    }
  }

  List<Widget> _active(BuildContext context, DealDeposit d,
      AppLocalizations l10n, bool canEdit) {
    final t = context.tokens;
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = depositDaysLeft(d.holdUntil, now);
    final ending = depositEnding(d, now);
    final note = d.note?.trim() ?? '';

    return [
      InfoRow(label: l10n.depositsAmount, value: formatPrice(d.amount)),
      const SizedBox(height: 11),
      InfoRow(
          label: l10n.depositsReceivedOn,
          value: depositDateLabel(d.receivedOn, now, locale)),
      const SizedBox(height: 11),
      InfoRow(
          label: l10n.depositsHoldUntil,
          value: depositDateLabel(d.holdUntil, now, locale)),
      const SizedBox(height: 4),
      Text(
        depositTimeLeftLabel(l10n, days),
        key: Key('deal-deposit-left${ending ? '-warning' : ''}'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: ending ? t.dangerText : t.textHint),
      ),
      const SizedBox(height: 11),
      InfoRow(
          label: l10n.depositsHolder,
          value: depositHolderLabel(l10n, d.holder)),
      if (note.isNotEmpty) ...[
        const SizedBox(height: 11),
        Text(note,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.5,
                color: t.textSecondary)),
      ],
      if (canEdit) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: AppGhostButton(
              key: const Key('deal-deposit-edit'),
              label: l10n.depositsEdit,
              height: AppMetrics.buttonHeightInline,
              onPressed: () => _edit(context, d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppGhostButton(
              key: const Key('deal-deposit-close'),
              label: l10n.depositsCloseAction,
              height: AppMetrics.buttonHeightInline,
              onPressed: () => _close(context, d),
            ),
          ),
        ]),
      ],
    ];
  }
}

class _PastRow extends StatelessWidget {
  final DealDeposit deposit;
  const _PastRow({required this.deposit});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final outcome = deposit.outcome;
    final closed = deposit.closedOn;
    final text = [
      if (outcome != null) depositOutcomeLabel(l10n, outcome),
      if (closed != null) depositDateLabel(closed, AppClock.now(), locale),
      formatPrice(deposit.amount),
    ].join(' · ');
    return Text(
      text,
      key: Key('deal-deposit-past-${deposit.id}'),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily: AppFonts.sans, fontSize: 12, color: t.textSecondary),
    );
  }
}
