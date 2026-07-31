import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';

class DealDetailScreen extends StatefulWidget {
  final int id;
  const DealDetailScreen({super.key, required this.id});
  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  DealResponse? _d;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await Injector.dealsRepository.getDeal(widget.id);
      if (!mounted) return;
      setState(() {
        _d = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).dealsNotFound;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.dealsDeleteTitle,
      content: l10n.dealsDeleteCascade(_d!.title),
    );
    if (!ok || !mounted) return;
    context.read<DealsBloc>().add(DealsDeleteEvent(widget.id));
    context.go('/deals');
  }

  /// The stage the server last confirmed. The card moves optimistically so
  /// the tap feels instant; if the write is rejected we fall back to this
  /// instead of leaving a stage on screen that was never saved.
  DealStatus? _confirmedStatus;

  void _updateStatus(DealStatus s) {
    if (s == _d?.status) return;
    _confirmedStatus = _d?.status;
    context.read<DealsBloc>().add(DealsUpdateStatusEvent(widget.id, s));
    setState(() => _d = _d?.copyWith(status: s));
  }

  void _onWriteResult(BuildContext _, DealsState state) {
    if (state is DealsActionSuccess) {
      _confirmedStatus = null;
    } else if (state is DealsActionFailure && _confirmedStatus != null) {
      setState(() => _d = _d?.copyWith(status: _confirmedStatus!));
      _confirmedStatus = null;
    }
    // The message itself is surfaced by the list screen's listener, which
    // stays mounted underneath this route.
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: '${widget.id}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).dealsIdCopied),
          duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deal = _d;

    if (_loading || deal == null) {
      return DetailScaffold(
        title: l10n.dealsFallbackTitle,
        children: [
          if (_error != null)
            EmptyState(
              icon: Icons.handshake_outlined,
              title: _error!,
              action: AppGhostButton(label: l10n.coreRetry, onPressed: _load),
            )
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerBox(
                    width: double.infinity,
                    height: 130,
                    radius: AppMetrics.radiusMd),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 150,
                    radius: AppMetrics.radiusMd),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 130,
                    radius: AppMetrics.radiusMd),
              ]),
            ),
        ],
      );
    }

    return BlocListener<DealsBloc, DealsState>(
      listener: _onWriteResult,
      child: DetailScaffold(
        title: l10n.dealsIdLabel(deal.id),
        onRefresh: _load,
        actions: detailActions(
          onEdit: () => context.push('/deals/${widget.id}/edit'),
          onDelete: context.isAdminOrManager ? _delete : null,
          deleteTooltip: l10n.dealsDeleteTitle,
        ),
        children: [
          _SummaryCard(deal: deal, onCopyId: _copyId),
          _StageCard(status: deal.status, onChanged: _updateStatus),
          _ParticipantsCard(deal: deal),
          _TimelineCard(deal: deal),
          if (deal.notes != null && deal.notes!.trim().isNotEmpty)
            _NotesCard(text: deal.notes!),
        ],
      ),
    );
  }
}

// ─── Summary ─────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onCopyId;
  const _SummaryCard({required this.deal, required this.onCopyId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final amount = deal.dealPrice ?? deal.budget ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              DealStatusChip(status: deal.status),
            ],
          ),
          const SizedBox(height: 13),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatPrice(amount),
              maxLines: 1,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: t.textPrimary),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: onCopyId,
            child: Text(
              [
                if (deal.budget != null)
                  l10n.dealsBudgetValue(formatPrice(deal.budget!)),
                l10n.dealsIdLabel(deal.id),
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  color: t.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stage ───────────────────────────────────────────────────────

class _StageCard extends StatelessWidget {
  final DealStatus status;
  final ValueChanged<DealStatus> onChanged;
  const _StageCard({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    // The bar shows where in the funnel this deal sits — not a distribution.
    const track = [
      DealStatus.LEAD,
      DealStatus.NEGOTIATION,
      DealStatus.CLOSED_WON,
    ];
    final reachedTo = track.indexOf(status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dealsPipelineStage),
          const SizedBox(height: 13),
          SizedBox(
            height: 8,
            child: Row(
              children: [
                for (var i = 0; i < track.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: reachedTo >= i
                            ? _stageColor(track[i])
                            : t.surfaceVariant,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 13),
          FilterPillWrap(pills: [
            for (final s in DealStatus.values)
              FilterPill(
                label: dealStatusLabel(l10n, s),
                selected: status == s,
                onCard: true,
                onTap: () => onChanged(s),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              ),
          ]),
        ],
      ),
    );
  }

  static Color _stageColor(DealStatus s) {
    switch (s) {
      case DealStatus.LEAD:
        return AppColors.lead;
      case DealStatus.NEGOTIATION:
        return AppColors.negotiation;
      case DealStatus.CLOSED_WON:
        return AppColors.closedWon;
      case DealStatus.CLOSED_LOST:
        return AppColors.closedLost;
    }
  }
}

// ─── Participants ────────────────────────────────────────────────

class _ParticipantsCard extends StatelessWidget {
  final DealResponse deal;
  const _ParticipantsCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const dash = '—';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dealsPeopleProperty),
          const SizedBox(height: 13),
          InfoRow(
            label: l10n.dealsClient,
            value: deal.clientName.isEmpty ? dash : deal.clientName,
          ),
          const SizedBox(height: 11),
          InfoRow(
            label: l10n.dealsAgent,
            value: deal.agentName.isEmpty ? dash : deal.agentName,
          ),
          const SizedBox(height: 11),
          InfoRow(
            label: l10n.dealsProperty,
            value: deal.propertyTitle ?? dash,
          ),
        ],
      ),
    );
  }
}

// ─── Timeline ────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final DealResponse deal;
  const _TimelineCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final events = <_Event>[
      if (deal.closedAt != null)
        _Event(l10n.dealsTimelineClosed, deal.closedAt!, done: true),
      if (deal.updatedAt != null && deal.updatedAt != deal.createdAt)
        _Event(l10n.dealsTimelineUpdated, deal.updatedAt!),
      if (deal.createdAt != null)
        _Event(l10n.dealsTimelineCreated, deal.createdAt!),
    ];
    if (events.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dealsTimeline),
          const SizedBox(height: 13),
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) const SizedBox(height: 11),
            _TimelineRow(event: events[i], locale: locale),
          ],
        ],
      ),
    );
  }
}

class _Event {
  final String label;
  final DateTime at;

  /// Done events get a status-coloured dot; past ones the border colour.
  final bool done;
  const _Event(this.label, this.at, {this.done = false});
}

class _TimelineRow extends StatelessWidget {
  final _Event event;
  final String locale;
  const _TimelineRow({required this.event, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: event.done ? AppColors.closedWon : t.border,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: t.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                formatWeekdayDate(event.at, locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans, fontSize: 11, color: t.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Notes ───────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  final String text;
  const _NotesCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dealsNotes),
          const SizedBox(height: 9),
          Text(
            text,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.55,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
