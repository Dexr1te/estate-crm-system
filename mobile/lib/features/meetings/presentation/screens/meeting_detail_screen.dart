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
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';

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
                ShimmerBox(
                    width: double.infinity,
                    height: 165,
                    radius: AppMetrics.radiusLg),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 170,
                    radius: AppMetrics.radiusMd),
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
