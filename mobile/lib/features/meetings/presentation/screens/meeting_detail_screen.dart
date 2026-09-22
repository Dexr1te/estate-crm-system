import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MeetingDetailScreen extends StatefulWidget {
  final int id;
  const MeetingDetailScreen({super.key, required this.id});
  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  MeetingResponse? _m;
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
      final m = await Injector.meetingsRepository.getMeeting(widget.id);
      if (!mounted) return;
      setState(() {
        _m = m;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).meetingsNoMeetings;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.meetingsDeleteMeeting,
      content: l10n.meetingsDeleteCascade(_m!.title),
    );
    if (!ok || !mounted) return;
    context.read<MeetingsBloc>().add(MeetingsDeleteEvent(widget.id));
    context.go('/meetings');
  }

  Future<void> _directions() async {
    final l10n = AppLocalizations.of(context);
    if (!await ContactActions.directions(_m?.location) && mounted) {
      showActionUnavailable(context, l10n.meetingsNoLocation);
    }
  }

  Future<void> _call() async {
    final l10n = AppLocalizations.of(context);
    String? phone;
    try {
      phone = (await Injector.clientsRepository.getClient(_m!.clientId)).phone;
    } catch (_) {
      phone = null;
    }
    if (!mounted) return;
    if (!await ContactActions.call(phone) && mounted) {
      showActionUnavailable(context, l10n.clientsNoPhone);
    }
  }

  bool? _confirmedCompleted;

  void _recordOutcome(ViewingOutcome outcome, String? note) {
    context
        .read<MeetingsBloc>()
        .add(MeetingsOutcomeEvent(widget.id, outcome, note));
    setState(() => _m = _m?.copyWith(
        outcome: outcome,
        outcomeNote: note == null || note.trim().isEmpty ? null : note.trim(),
        completed: outcome != ViewingOutcome.NO_SHOW));
  }

  void _setCompleted(bool completed) {
    if (completed == _m?.completed) return;
    _confirmedCompleted = _m?.completed;
    if (completed) {
      context.read<MeetingsBloc>().add(MeetingsCompleteEvent(widget.id));
    } else {
      context
          .read<MeetingsBloc>()
          .add(MeetingsUpdateEvent(widget.id, {'completed': false}));
    }
    setState(() => _m = _m?.copyWith(completed: completed));
  }

  void _onWriteResult(BuildContext _, MeetingsState state) {
    if (state is MeetingsActionSuccess) {
      _confirmedCompleted = null;
    } else if (state is MeetingsActionFailure && _confirmedCompleted != null) {
      setState(() => _m = _m?.copyWith(completed: _confirmedCompleted!));
      _confirmedCompleted = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meeting = _m;

    if (_loading || meeting == null) {
      return DetailScaffold(
        title: l10n.meetingsTitle,
        children: [
          if (_error != null)
            EmptyState(
              icon: Icons.event_busy_outlined,
              title: _error!,
              action: AppGhostButton(label: l10n.coreRetry, onPressed: _load),
            )
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerHeroCard(),
                SizedBox(height: 14),
                ShimmerInfoCard(rows: 4, heading: true),
                SizedBox(height: 14),
                ShimmerRowCard(
                  leading: ShimmerBox(width: 34, height: 34, radius: 11),
                  trailing: ShimmerBox(width: 44, height: 26, radius: 13),
                  titleFactor: 0.44,
                  subtitleFactor: 0.66,
                ),
              ]),
            ),
        ],
      );
    }

    return BlocListener<MeetingsBloc, MeetingsState>(
      listener: _onWriteResult,
      child: DetailScaffold(
        title: l10n.meetingsTitle,
        onRefresh: _load,
        actions: detailActions(
          onEdit: () => context.push('/meetings/${widget.id}/edit'),
          onDelete: _delete,
          editTooltip: l10n.meetingsEdit,
          deleteTooltip: l10n.meetingsDelete,
        ),
        children: [
          NextMeetingHero(
            meeting: meeting,
            eyebrow: meeting.location ?? l10n.meetingsSchedule,
            primaryLabel: l10n.meetingsDirections,
            onPrimary: _directions,
            secondaryLabel: l10n.coreCall,
            onSecondary: _call,
          ),
          _DetailsCard(meeting: meeting),
          _StatusCard(completed: meeting.completed, onChanged: _setCompleted),
          if (meeting.propertyId != null)
            _OutcomeCard(meeting: meeting, onRecord: _recordOutcome),
          if (meeting.description != null &&
              meeting.description!.trim().isNotEmpty)
            _NoteCard(text: meeting.description!),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final MeetingResponse meeting;
  const _DetailsCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const dash = '—';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.meetingsDetails),
          const SizedBox(height: 13),
          InfoRow(
              label: l10n.meetingsClient,
              value: meeting.clientName.isEmpty ? dash : meeting.clientName),
          const SizedBox(height: 11),
          InfoRow(
              label: l10n.meetingsAgent,
              value: meeting.agentName.isEmpty ? dash : meeting.agentName),
          const SizedBox(height: 11),
          InfoRow(label: l10n.meetingsDeal, value: meeting.dealTitle ?? dash),
          const SizedBox(height: 11),
          InfoRow(
              label: l10n.meetingsLocation, value: meeting.location ?? dash),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatefulWidget {
  final MeetingResponse meeting;
  final void Function(ViewingOutcome, String?) onRecord;

  const _OutcomeCard({required this.meeting, required this.onRecord});

  @override
  State<_OutcomeCard> createState() => _OutcomeCardState();
}

class _OutcomeCardState extends State<_OutcomeCard> {
  late final TextEditingController _noteCtrl =
      TextEditingController(text: widget.meeting.outcomeNote ?? '');
  late ViewingOutcome? _outcome = widget.meeting.outcome;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _changed =>
      _outcome != widget.meeting.outcome ||
      _noteCtrl.text.trim() != (widget.meeting.outcomeNote ?? '').trim();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.meetingsOutcome),
          const SizedBox(height: 12),
          FilterPillWrap(pills: [
            for (final outcome in ViewingOutcome.values)
              FilterPill(
                label: viewingOutcomeLabel(l10n, outcome),
                selected: _outcome == outcome,
                onCard: true,
                onTap: () => setState(() => _outcome = outcome),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              ),
          ]),
          if (_outcome == ViewingOutcome.REJECTED) ...[
            const SizedBox(height: 10),
            Text(
              l10n.meetingsOutcomeRejectedHint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  height: 1.35,
                  color: t.textSecondary),
            ),
          ],
          if (_outcome != null) ...[
            const SizedBox(height: 14),
            LabelledField(
              label: l10n.meetingsOutcomeNote,
              child: AppTextField(
                controller: _noteCtrl,
                hint: l10n.meetingsOutcomeNoteHint,
                maxLines: 3,
                minLines: 2,
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_changed) ...[
              const SizedBox(height: 12),
              AppFilledButton(
                label: l10n.meetingsOutcomeSave,
                onPressed: () => widget.onRecord(_outcome!, _noteCtrl.text),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool completed;
  final ValueChanged<bool> onChanged;
  const _StatusCard({required this.completed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.meetingsStatus),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterPill(
                  label: l10n.meetingsStatusScheduled,
                  selected: !completed,
                  onCard: true,
                  onTap: () => onChanged(false),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterPill(
                  label: l10n.meetingsStatusHeld,
                  selected: completed,
                  onCard: true,
                  onTap: () => onChanged(true),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.meetingsNote),
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
