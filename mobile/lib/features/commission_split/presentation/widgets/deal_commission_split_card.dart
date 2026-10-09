import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/bloc/commission_split_bloc.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/commission_split_sheet.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/payout_widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/split_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Who gets what of the deal's commission: each party's share and what it
/// comes to, the deal's agent first, and the editor for whoever may change
/// it (the server says who: the deal's agent, a manager or an admin). Once
/// the deal is won each colleague's and co-broker's share says whether it has
/// been paid out, and a manager marks it paid or undoes that. Reads a
/// [CommissionSplitBloc] above it. [onSaved] runs after every write the
/// server took.
class DealCommissionSplitCard extends StatelessWidget {
  final VoidCallback? onSaved;

  const DealCommissionSplitCard({super.key, this.onSaved});

  Future<void> _edit(BuildContext context, CommissionSplit split) async {
    final bloc = context.read<CommissionSplitBloc>();
    final draft = await showCommissionSplitSheet(context, split);
    if (draft != null) bloc.add(CommissionSplitSaveEvent(draft));
  }

  Future<void> _markPaid(BuildContext context, CommissionShare share) async {
    final bloc = context.read<CommissionSplitBloc>();
    final choice = await showMarkPaidSheet(context,
        name: share.name?.trim() ?? '', amount: share.amount);
    if (choice != null) {
      bloc.add(CommissionSplitMarkPaidEvent(share.id!, note: choice.note));
    }
  }

  Future<void> _undoPayout(BuildContext context, CommissionShare share) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<CommissionSplitBloc>();
    final ok = await showConfirmDialog(
      context,
      title: l10n.payoutsUndoTitle,
      content: l10n.payoutsUndoBody(share.name?.trim() ?? ''),
      confirmLabel: l10n.payoutsUndo,
      icon: Icons.undo_rounded,
    );
    if (ok) bloc.add(CommissionSplitUndoPayoutEvent(share.id!));
  }

  /// A share is a payout once the deal is won: a colleague's or a
  /// co-broker's, never the deal agent's, who holds what is left. One paid
  /// before the deal was reopened still says so.
  static bool _showsPayout(CommissionSplit split, CommissionShare share) =>
      share.id != null && (split.won || share.paid);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<CommissionSplitBloc, CommissionSplitState>(
      listenWhen: (prev, next) =>
          next.outcome != null || next.saved != prev.saved,
      listener: (context, state) {
        final failure = state.outcome?.failure;
        if (failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(splitFailureLabel(l10n, failure)),
              backgroundColor: context.tokens.dangerSolid,
            ));
        } else {
          onSaved?.call();
        }
      },
      builder: (context, state) => AppCard(
        key: const Key('deal-split-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EyebrowLabel(l10n.splitsTitle),
            const SizedBox(height: 11),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, CommissionSplitState state, AppLocalizations l10n) {
    final t = context.tokens;
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
    final split = state.split;
    if (state.status == CommissionSplitStatus.loading || split == null) {
      if (state.status == CommissionSplitStatus.error) {
        return [
          Text(l10n.splitsLoadFailed,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
          const SizedBox(height: 10),
          AppGhostButton(
            key: const Key('deal-split-retry'),
            label: l10n.coreRetry,
            height: AppMetrics.buttonHeightInline,
            onPressed: () => context
                .read<CommissionSplitBloc>()
                .add(CommissionSplitLoadEvent()),
          ),
        ];
      }
      return const [
        ShimmerGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShimmerBar(widthFactor: 0.6, height: 14),
              SizedBox(height: 10),
              ShimmerBar(widthFactor: 0.8, height: 12),
            ],
          ),
        ),
      ];
    }

    final agent = split.shares.isEmpty ? null : split.shares.first;
    return [
      for (var i = 0; i < split.shares.length; i++) ...[
        if (i > 0) const SizedBox(height: 11),
        _ShareRow(key: Key('deal-split-share-$i'), share: split.shares[i]),
        if (_showsPayout(split, split.shares[i]))
          _PayoutLine(
            key: Key('deal-split-payout-$i'),
            index: i,
            share: split.shares[i],
            onMark: split.payoutsEditable && split.won && !state.saving
                ? () => _markPaid(context, split.shares[i])
                : null,
            onUndo: split.payoutsEditable && !state.saving
                ? () => _undoPayout(context, split.shares[i])
                : null,
            showAction: split.payoutsEditable,
          ),
      ],
      if (!split.split && agent?.name != null) ...[
        const SizedBox(height: 10),
        Text(l10n.splitsAllToAgent(agent!.name!),
            maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
      ],
      if (split.commission == null) ...[
        const SizedBox(height: 6),
        Text(l10n.splitsAmountUnknown,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: secondary.copyWith(color: t.textHint, fontSize: 11.5)),
      ],
      if (split.editable) ...[
        const SizedBox(height: 12),
        AppGhostButton(
          key: const Key('deal-split-edit'),
          label: split.split ? l10n.splitsEdit : l10n.splitsAdd,
          icon: Icons.call_split_rounded,
          height: AppMetrics.buttonHeightInline,
          loading: state.saving,
          onPressed: state.saving ? null : () => _edit(context, split),
        ),
      ],
    ];
  }
}

class _ShareRow extends StatelessWidget {
  final CommissionShare share;
  const _ShareRow({super.key, required this.share});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final amount = share.amount;
    final name = share.name?.trim() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? l10n.changeLogNoValue : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: share.active ? t.textPrimary : t.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                splitPartyLabel(l10n, share),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.textHint),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                splitPercentLabel(l10n, share.percent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary),
              ),
              if (amount != null) ...[
                const SizedBox(height: 2),
                Text(
                  formatPrice(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Under a colleague's or a co-broker's share of a won deal: paid or not,
/// the note the manager wrote with it, and for a manager the way to mark it
/// paid or undo that.
class _PayoutLine extends StatelessWidget {
  final int index;
  final CommissionShare share;
  final bool showAction;
  final VoidCallback? onMark;
  final VoidCallback? onUndo;

  const _PayoutLine({
    super.key,
    required this.index,
    required this.share,
    required this.showAction,
    this.onMark,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final note = share.payoutNote?.trim() ?? '';
    final action = !showAction
        ? null
        : share.paid
            ? PayoutAction(
                key: Key('deal-split-undo-$index'),
                label: l10n.payoutsUndo,
                onTap: onUndo)
            : PayoutAction(
                key: Key('deal-split-mark-paid-$index'),
                label: l10n.payoutsMarkPaid,
                onTap: onMark);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: action == null ? 2 : 0),
                child: PayoutChip(paid: share.paid, paidAt: share.paidAt),
              ),
              if (action != null) action,
            ],
          ),
          if (share.paid && note.isNotEmpty)
            Text(
              note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  height: 1.4,
                  color: t.textSecondary),
            ),
        ],
      ),
    );
  }
}
