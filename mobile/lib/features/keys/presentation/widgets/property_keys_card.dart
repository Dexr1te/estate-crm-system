import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/property_keys_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/hand_over_keys_sheet.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/key_out_row.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/keys_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many past handovers the card shows before "Show all".
const keysHistoryShown = 3;

/// A listing's keys on its detail screen: in the office, or with whom and
/// until when (in the danger hue once overdue), a way to hand them over or
/// take them back, and the last few handovers. Reads on its own, so the
/// detail screen only has to place it.
class PropertyKeysCard extends StatefulWidget {
  final int propertyId;

  const PropertyKeysCard({super.key, required this.propertyId});

  @override
  State<PropertyKeysCard> createState() => _PropertyKeysCardState();
}

class _PropertyKeysCardState extends State<PropertyKeysCard> {
  late final PropertyKeysBloc _bloc =
      PropertyKeysBloc(Injector.keysRepository, propertyId: widget.propertyId)
        ..add(PropertyKeysLoadEvent());
  bool _allHistory = false;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _handOver() async {
    final draft = await showHandOverKeysSheet(context);
    if (draft != null && mounted) _bloc.add(PropertyKeysHandOverEvent(draft));
  }

  Future<void> _return(KeyHandover current) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.keysReturnConfirmTitle,
      content: l10n.keysReturnConfirmBody(current.holderName),
      confirmLabel: l10n.keysReturnConfirm,
      icon: Icons.key_outlined,
    );
    if (ok && mounted) _bloc.add(PropertyKeysReturnEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PropertyKeysBloc, PropertyKeysState>(
        listenWhen: (prev, next) => next.writeFailure != null,
        listener: (context, state) =>
            showActionOutcome(context, _KeysRefusal(state.writeFailure!)),
        builder: (context, state) {
          if (state.status == PropertyKeysStatus.loading) {
            return const ShimmerGroup(
                child: ShimmerInfoCard(rows: 2, heading: true, buttons: 1));
          }
          final current = state.keys.current;
          return AppCard(
            key: const ValueKey('property-keys'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Heading(overdue: current?.overdue ?? false),
                const SizedBox(height: 11),
                ...(state.status == PropertyKeysStatus.error
                    ? _failed(context)
                    : _loaded(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _failed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      Text(l10n.keysLoadFailed,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              color: context.tokens.textSecondary)),
      const SizedBox(height: 10),
      AppGhostButton(
        key: const ValueKey('property-keys-retry'),
        label: l10n.coreRetry,
        height: AppMetrics.buttonHeightInline,
        onPressed: () => _bloc.add(PropertyKeysLoadEvent()),
      ),
    ];
  }

  List<Widget> _loaded(BuildContext context, PropertyKeysState state) {
    final l10n = AppLocalizations.of(context);
    final current = state.keys.current;
    final history = state.keys.history;
    final shown =
        _allHistory ? history : history.take(keysHistoryShown).toList();

    return [
      if (current == null) ...[
        const _InOffice(),
        const SizedBox(height: 12),
        AppGhostButton(
          key: const ValueKey('property-keys-hand-over'),
          label: l10n.keysHandOver,
          icon: Icons.key_outlined,
          onPressed: state.saving ? null : _handOver,
        ),
      ] else ...[
        _Current(handover: current),
        const SizedBox(height: 12),
        AppGhostButton(
          key: const ValueKey('property-keys-return'),
          label: l10n.keysReturn,
          icon: Icons.assignment_return_outlined,
          onPressed: state.saving ? null : () => _return(current),
        ),
      ],
      if (shown.isNotEmpty) ...[
        const SizedBox(height: 14),
        _HistoryHeading(l10n.keysHistory),
        for (final h in shown) ...[
          const SizedBox(height: 8),
          _HistoryRow(handover: h),
        ],
        if (history.length > shown.length) ...[
          const SizedBox(height: 4),
          AppGhostButton(
            key: const ValueKey('property-keys-show-all'),
            label: l10n.keysShowAll,
            height: AppMetrics.minHitTarget,
            fontSize: 12.5,
            onPressed: () => setState(() => _allHistory = true),
          ),
        ],
      ],
    ];
  }
}

/// A refused write, worded with the codes this feature knows.
class _KeysRefusal with ActionFailed {
  final PropertyKeysWriteFailed refusal;
  _KeysRefusal(this.refusal);

  @override
  ApiFailure get failure => refusal.failure;

  @override
  String text(AppLocalizations l10n) => keysFailureLabel(l10n, failure);
}

class _Heading extends StatelessWidget {
  final bool overdue;
  const _Heading({required this.overdue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: EyebrowLabel(l10n.keysCardTitle)),
        if (overdue)
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: StatusChip(
                key: const ValueKey('property-keys-overdue'),
                label: l10n.keysOverdue,
                hue: StatusHue.danger,
              ),
            ),
          ),
      ],
    );
  }
}

class _InOffice extends StatelessWidget {
  const _InOffice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const KeyIconTile(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.keysInOffice,
            key: const ValueKey('property-keys-in-office'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.tokens.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _Current extends StatelessWidget {
  final KeyHandover handover;
  const _Current({required this.handover});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final h = handover;
    final note = h.note?.trim() ?? '';
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12, color: t.textSecondary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyIconTile(alert: h.overdue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                keysHolderLine(l10n, h, now, locale),
                key: const ValueKey('property-keys-holder'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: h.overdue ? t.dangerText : t.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(keysHandedOutLine(l10n, h, now, locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: secondary),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(note,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: secondary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryHeading extends StatelessWidget {
  final String text;
  const _HistoryHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: context.tokens.textSecondary),
      );
}

class _HistoryRow extends StatelessWidget {
  final KeyHandover handover;
  const _HistoryRow({required this.handover});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      key: ValueKey('property-keys-history-${handover.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(handover.holderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: t.textPrimary)),
        const SizedBox(height: 1),
        Text(keysPeriodLabel(l10n, handover, AppClock.now(), locale),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                color: t.textSecondary)),
      ],
    );
  }
}
