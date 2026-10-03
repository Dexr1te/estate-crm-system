import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_state.dart';
import 'package:real_estate_crm/features/teams/presentation/widgets/handover_client_picker.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A manager hands some of an agent's work to a colleague while both stay:
/// who takes it, what moves, how much that is, and a confirmation.
class HandoverScreen extends StatelessWidget {
  final int agentId;

  const HandoverScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => HandoverBloc(
            Injector.teamsRepository, Injector.clientsRepository,
            fromId: agentId)
          ..add(HandoverLoadEvent()),
        child: const _HandoverView(),
      );
}

class _HandoverView extends StatelessWidget {
  const _HandoverView();

  Future<void> _pickTarget(BuildContext context, HandoverState state) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<HandoverBloc>();
    final picked = await showEntityPicker(
      context,
      title: l10n.handoverTo,
      searchHint: l10n.teamsFullName,
      emptyLabel: l10n.handoverNoColleagues,
      selectedId: state.toId,
      items: [
        for (final m in state.candidates)
          PickerItem(
            id: m.id,
            title: m.isTeamManager ? l10n.teamsSuccessorMe : m.fullName,
            subtitle: m.email,
          ),
      ],
    );
    if (picked != null && !bloc.isClosed) {
      bloc.add(HandoverTargetEvent(picked.id));
    }
  }

  Future<void> _pickClients(BuildContext context, HandoverState state) async {
    final bloc = context.read<HandoverBloc>();
    final answer = await showHandoverClientPicker(context,
        clients: state.clients, picked: state.picked);
    if (answer != null && !bloc.isClosed) {
      bloc.add(HandoverClientsEvent(answer.ids));
    }
  }

  Future<void> _confirm(BuildContext context, HandoverState state) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<HandoverBloc>();
    final to = state.to;
    final from = state.from;
    if (to == null || from == null) return;
    final ok = await showConfirmDialog(
      context,
      title: l10n.handoverConfirmTitle(to.fullName),
      content: l10n.handoverConfirmBody(from.fullName, to.fullName),
      confirmLabel: l10n.handoverConfirm,
      icon: Icons.swap_horiz_rounded,
    );
    if (ok && !bloc.isClosed) bloc.add(HandoverConfirmEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HandoverBloc, HandoverState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final bloc = context.read<HandoverBloc>();
        final result = state.result;

        if (result != null) {
          return DetailScaffold(
            title: l10n.handoverAction,
            bottomAction: AppFilledButton(
              key: const Key('handover-done'),
              label: l10n.handoverDoneAction,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            children: [_HandoverDone(result: result)],
          );
        }

        return DetailScaffold(
          title: l10n.handoverAction,
          bottomAction: state.status == HandoverStatus.ready
              ? AppFilledButton(
                  key: const Key('handover-confirm'),
                  label: l10n.handoverConfirm,
                  loading: state.saving,
                  onPressed:
                      state.canConfirm ? () => _confirm(context, state) : null,
                )
              : null,
          children: [
            if (state.status == HandoverStatus.loading) ...const [
              ShimmerInfoCard(rows: 2),
              ShimmerInfoCard(rows: 4, heading: true),
            ],
            if (state.status == HandoverStatus.error)
              EmptyState(
                icon: Icons.groups_outlined,
                title: l10n.handoverLoadFailed,
                subtitle: state.loadFailure == null
                    ? null
                    : apiFailureLabel(l10n, state.loadFailure!),
                action: AppGhostButton(
                  label: l10n.coreRetry,
                  onPressed: () => bloc.add(HandoverLoadEvent()),
                ),
              ),
            if (state.status == HandoverStatus.ready) ...[
              _Intro(name: state.from?.fullName ?? ''),
              SettingsGroup(rows: [
                SettingsRow(
                  label: l10n.handoverFrom,
                  value: state.from?.fullName ?? '',
                ),
                SettingsRow(
                  key: const Key('handover-target'),
                  label: l10n.handoverTo,
                  value: state.to == null
                      ? l10n.handoverChooseColleague
                      : state.to!.isTeamManager
                          ? l10n.teamsSuccessorMe
                          : state.to!.fullName,
                  showChevron: true,
                  onTap:
                      state.saving ? null : () => _pickTarget(context, state),
                ),
              ]),
              EyebrowLabel(l10n.handoverWhat),
              SettingsGroup(rows: [
                _PartRow(
                  part: HandoverPart.clients,
                  label: l10n.handoverPartClients,
                  hint: l10n.handoverPartClientsHint,
                  on: state.clientsOn,
                ),
                if (state.clientsOn)
                  SettingsRow(
                    key: const Key('handover-pick-clients'),
                    label: l10n.handoverPickClients,
                    value: state.picked == null
                        ? l10n.handoverAllClients
                        : l10n.handoverSomeClients(state.picked!.length),
                    showChevron: true,
                    onTap: state.saving
                        ? null
                        : () => _pickClients(context, state),
                  ),
                _PartRow(
                  part: HandoverPart.listings,
                  label: l10n.handoverPartListings,
                  hint: l10n.handoverPartListingsHint,
                  on: state.listings,
                ),
                _PartRow(
                  part: HandoverPart.deals,
                  label: l10n.handoverPartDeals,
                  hint: l10n.handoverPartDealsHint,
                  on: state.deals,
                ),
                _PartRow(
                  part: HandoverPart.upcoming,
                  label: l10n.handoverPartUpcoming,
                  hint: l10n.handoverPartUpcomingHint,
                  on: state.upcoming,
                ),
              ]),
              _PreviewCard(state: state),
            ],
          ],
        );
      },
    );
  }
}

class _Intro extends StatelessWidget {
  final String name;
  const _Intro({required this.name});

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context).handoverIntro(name),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12.5,
            height: 1.45,
            color: context.tokens.textSecondary),
      );
}

class _PartRow extends StatelessWidget {
  final HandoverPart part;
  final String label;
  final String hint;
  final bool on;

  const _PartRow({
    required this.part,
    required this.label,
    required this.hint,
    required this.on,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HandoverBloc>();
    final saving = context.select<HandoverBloc, bool>((b) => b.state.saving);
    return SettingsRow(
      key: Key('handover-part-${part.name}'),
      label: label,
      subLabel: hint,
      onTap: saving ? null : () => bloc.add(HandoverPartEvent(part, !on)),
      trailing: AppSwitch(
        value: on,
        onChanged: (v) {
          if (!saving) bloc.add(HandoverPartEvent(part, v));
        },
      ),
    );
  }
}

/// The counts as the server has them for the current choice.
class _PreviewCard extends StatelessWidget {
  final HandoverState state;
  const _PreviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    if (state.previewing) return const ShimmerInfoCard(rows: 4, heading: true);

    final preview = state.preview;
    String? message;
    Widget? action;
    if (state.toId == null) {
      message = l10n.handoverPickTarget;
    } else if (state.selection == null) {
      message = l10n.handoverNothingSelected;
    } else if (state.previewFailure != null) {
      message = l10n.handoverPreviewFailed;
      action = AppGhostButton(
        key: const Key('handover-preview-retry'),
        label: l10n.coreRetry,
        height: AppMetrics.buttonHeightInline,
        fontSize: 12,
        onPressed: () =>
            context.read<HandoverBloc>().add(HandoverTargetEvent(state.toId!)),
      );
    } else if (preview != null && preview.total == 0) {
      message = l10n.handoverNothingToMove;
    }

    return AppCard(
      key: const Key('handover-preview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.handoverPreview),
          const SizedBox(height: 10),
          if (message != null) ...[
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.textSecondary),
            ),
            if (action != null) ...[const SizedBox(height: 10), action],
          ] else if (preview != null)
            _Counts(summary: preview),
        ],
      ),
    );
  }
}

class _Counts extends StatelessWidget {
  final HandoverSummary summary;
  const _Counts({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <(String, int)>[
      (l10n.handoverPartClients, summary.clients),
      (l10n.handoverPartListings, summary.listings),
      (l10n.handoverCountDeals, summary.deals),
      (l10n.handoverCountMeetings, summary.meetings),
      (l10n.handoverCountTasks, summary.tasks),
      if (summary.openHouses > 0)
        (l10n.handoverCountOpenHouses, summary.openHouses),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, count) in rows)
          InfoRow(label: label, value: '$count'),
      ],
    );
  }
}

class _HandoverDone extends StatelessWidget {
  final HandoverSummary result;
  const _HandoverDone({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return AppCard(
      key: const Key('handover-result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: t.surfaceVariant, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 18, color: t.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.handoverDoneTitle(result.toAgentName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Counts(summary: result),
          const SizedBox(height: 10),
          Text(
            l10n.handoverDoneBody(result.toAgentName),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.45,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
