import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';
import 'package:real_estate_crm/features/time_off/presentation/bloc/time_off_editor_bloc.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_conflicts_card.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Writes down time off, or opens one to change or cancel it.
///
/// The kind, the first and the last day, who covers and a note. A manager
/// may write it down for anybody in the agency ([userId] picks them to start
/// with); everybody else writes down their own. An absence the signed-in user
/// may not change reads as a summary. Meetings still on those days show
/// underneath as a warning, with the way to hand the work over for a manager.
class TimeOffFormScreen extends StatefulWidget {
  final int? id;
  final int? userId;

  const TimeOffFormScreen({super.key, this.id, this.userId});

  @override
  State<TimeOffFormScreen> createState() => _TimeOffFormScreenState();
}

/// The cover picker's "nobody" row.
const _kNobody = 0;

class _TimeOffFormScreenState extends State<TimeOffFormScreen> {
  late final _bloc =
      TimeOffEditorBloc(Injector.timeOffRepository, id: widget.id)
        ..add(TimeOffEditorLoadEvent());
  final _noteCtrl = TextEditingController();

  List<AgentOption> _agents = const [];
  TimeOffKind _kind = TimeOffKind.vacation;
  DateTime? _start;
  DateTime? _end;
  int? _personId;
  int? _coverId;
  bool _filled = false;
  String? _datesError;
  String? _personError;

  @override
  void initState() {
    super.initState();
    _personId = widget.userId;
    _loadAgents();
  }

  @override
  void dispose() {
    _bloc.close();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await Injector.agentsRepository.getAgentOptions();
      if (mounted) setState(() => _agents = agents);
    } catch (_) {}
  }

  void _fill(TimeOff t) {
    if (_filled) return;
    _filled = true;
    _kind = t.kind;
    _start = t.startDate;
    _end = t.endDate;
    _personId = t.userId;
    _coverId = t.coverId;
    _noteCtrl.text = t.note ?? '';
  }

  int? get _absentId => _personId ?? context.currentUserId;

  String _nameOf(int? id, String? fallback) {
    for (final a in _agents) {
      if (a.id == id) return a.fullName;
    }
    return fallback ?? '';
  }

  List<PickerItem> _people(
      {required bool withNobody, int? except, required String nobody}) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    return [
      if (withNobody) PickerItem(id: _kNobody, title: nobody),
      for (final a in _agents)
        if (a.id != except)
          PickerItem(
            id: a.id,
            title: a.fullName,
            badge: agentAwayBadge(l10n, a, now, locale),
          ),
    ];
  }

  Future<void> _pickPerson() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.timeOffPerson,
      items: _people(withNobody: false, nobody: ''),
      selectedId: _personId,
      searchHint: l10n.timeOffSearchPeople,
      emptyLabel: l10n.coreNoResults,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _personId = picked.id;
      _personError = null;
      if (_coverId == picked.id) _coverId = null;
    });
  }

  Future<void> _pickCover() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.timeOffCover,
      items: _people(
          withNobody: true, except: _absentId, nobody: l10n.timeOffNoCover),
      selectedId: _coverId ?? _kNobody,
      searchHint: l10n.timeOffSearchPeople,
      emptyLabel: l10n.coreNoResults,
    );
    if (picked == null || !mounted) return;
    setState(() => _coverId = picked.id == _kNobody ? null : picked.id);
  }

  Future<void> _pickDate({required bool first}) async {
    final now = AppClock.now();
    final current = first ? _start : _end;
    final initial = current ?? (first ? null : _start) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (first) {
        _start = picked;
        if (_end == null || _end!.isBefore(picked)) _end = picked;
      } else {
        _end = picked;
      }
      _datesError = null;
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final start = _start;
    final end = _end;
    final creatingForSomeone = widget.id == null && context.isManager;
    setState(() {
      _datesError = start == null || end == null
          ? l10n.timeOffDatesRequired
          : end.isBefore(start)
              ? l10n.timeOffEndBeforeStart
              : timeOffLength(start, end) > kTimeOffMaxDays
                  ? l10n.timeOffErrorTooLong
                  : null;
      _personError = creatingForSomeone && _personId == null
          ? l10n.timeOffPickPerson
          : null;
    });
    if (_datesError != null || _personError != null) return;
    _bloc.add(TimeOffEditorSaveEvent(TimeOffDraft(
      userId: widget.id == null ? _personId : null,
      kind: _kind,
      startDate: start!,
      endDate: end!,
      coverId: _coverId,
      note: _noteCtrl.text,
    )));
  }

  Future<void> _cancelTimeOff() async {
    final l10n = AppLocalizations.of(context);
    final go = await showConfirmDialog(
      context,
      title: l10n.timeOffCancelConfirmTitle,
      content: l10n.timeOffCancelConfirmBody,
      confirmLabel: l10n.timeOffCancelAction,
      cancelLabel: l10n.timeOffKeep,
    );
    if (go && mounted) _bloc.add(TimeOffEditorCancelEvent());
  }

  void _onWrite(BuildContext context, TimeOffEditorState state) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void say(String text, {bool failure = false}) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: failure ? context.tokens.dangerSolid : null));
    switch (state.outcome) {
      case TimeOffEditorOutcome.saved:
        say(l10n.timeOffSaved);
        final saved = state.timeOff;
        if (saved == null || saved.conflictCount == 0) {
          context.pop();
        }
      case TimeOffEditorOutcome.cancelled:
        say(l10n.timeOffCancelled);
        context.pop();
      case TimeOffEditorOutcome.failed:
        final failure = state.failure;
        if (failure != null) {
          say(timeOffFailureLabel(l10n, failure), failure: true);
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<TimeOffEditorBloc, TimeOffEditorState>(
        listenWhen: (a, b) => a.writes != b.writes,
        listener: _onWrite,
        builder: (context, state) {
          final loaded = state.timeOff;
          if (loaded != null) _fill(loaded);
          final editing = widget.id != null || loaded != null;
          final readOnly = loaded != null && !loaded.canEdit;
          return DetailScaffold(
            title: editing ? l10n.timeOffEditTitle : l10n.timeOffNewTitle,
            bottomAction: state.loading || state.loadFailure != null || readOnly
                ? null
                : _actions(context, state, editing),
            children: state.loading
                ? const [
                    ShimmerGroup(
                      child: Column(children: [
                        ShimmerFormCard(fields: 2),
                        SizedBox(height: 14),
                        ShimmerFormCard(fields: 3),
                      ]),
                    )
                  ]
                : state.loadFailure != null
                    ? [
                        EmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: l10n.timeOffLoadFailed,
                          subtitle: apiFailureLabel(l10n, state.loadFailure!),
                          action: AppGhostButton(
                              label: l10n.coreRetry,
                              onPressed: () =>
                                  _bloc.add(TimeOffEditorLoadEvent())),
                        ),
                      ]
                    : [
                        if (readOnly)
                          _Summary(timeOff: loaded)
                        else
                          ..._fields(context, l10n, loaded),
                        if (loaded != null && loaded.conflictCount > 0)
                          TimeOffConflictsCard(
                            timeOff: loaded,
                            onOpenMeeting: (id) =>
                                context.push('/meetings/$id'),
                            onHandOver: context.isManager &&
                                    loaded.userId != context.currentUserId
                                ? () => context
                                    .push('/team-handover/${loaded.userId}')
                                : null,
                          )
                        else if (loaded != null &&
                            context.isManager &&
                            loaded.userId != context.currentUserId)
                          AppGhostButton(
                            key: const ValueKey('time-off-hand-over'),
                            label: l10n.timeOffHandOver,
                            icon: Icons.swap_horiz_rounded,
                            onPressed: () =>
                                context.push('/team-handover/${loaded.userId}'),
                          ),
                      ],
          );
        },
      ),
    );
  }

  Widget _actions(
      BuildContext context, TimeOffEditorState state, bool editing) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFilledButton(
          key: const ValueKey('time-off-save'),
          label: l10n.coreSave,
          loading: state.busy,
          onPressed: state.busy ? null : _save,
        ),
        if (editing) ...[
          const SizedBox(height: 8),
          AppGhostButton(
            key: const ValueKey('time-off-cancel'),
            label: l10n.timeOffCancelAction,
            labelColor: context.tokens.dangerText,
            onPressed: state.busy ? null : _cancelTimeOff,
          ),
        ],
      ],
    );
  }

  List<Widget> _fields(
      BuildContext context, AppLocalizations l10n, TimeOff? loaded) {
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final choosesPerson =
        widget.id == null && loaded == null && context.isManager;
    final errorStyle =
        TextStyle(fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText);
    final start = _start;
    final end = _end;

    return [
      if (choosesPerson || loaded != null)
        FormSectionCard(children: [
          LabelledField(
            label: l10n.timeOffPerson,
            required: choosesPerson,
            child: choosesPerson
                ? PickerField(
                    key: const ValueKey('time-off-person'),
                    value: _personId == null ? null : _nameOf(_personId, null),
                    placeholder: l10n.timeOffPickPerson,
                    onTap: _pickPerson,
                  )
                : Text(
                    _nameOf(loaded!.userId, loaded.userName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
          ),
          if (_personError != null)
            Text(_personError!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: errorStyle),
        ]),
      FormSectionCard(
        eyebrow: l10n.timeOffKind,
        children: [
          FilterPillWrap(pills: [
            for (final k in TimeOffKind.values)
              FilterPill(
                key: ValueKey('time-off-kind-${k.name}'),
                label: timeOffKindLabel(l10n, k),
                selected: _kind == k,
                onCard: true,
                onTap: () => setState(() => _kind = k),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              ),
          ]),
        ],
      ),
      FormSectionCard(
        eyebrow: l10n.timeOffDaysEyebrow,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabelledField(
                  label: l10n.timeOffFirstDay,
                  required: true,
                  child: PickerField(
                    key: const ValueKey('time-off-start'),
                    value: start == null
                        ? null
                        : timeOffDateLabel(start, now, locale),
                    placeholder: l10n.timeOffPickDate,
                    trailingIcon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(first: true),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: LabelledField(
                  label: l10n.timeOffLastDay,
                  required: true,
                  child: PickerField(
                    key: const ValueKey('time-off-end'),
                    value:
                        end == null ? null : timeOffDateLabel(end, now, locale),
                    placeholder: l10n.timeOffPickDate,
                    trailingIcon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(first: false),
                  ),
                ),
              ),
            ],
          ),
          if (_datesError != null)
            Text(_datesError!,
                key: const ValueKey('time-off-dates-error'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: errorStyle)
          else if (start != null && end != null && !end.isBefore(start))
            Text(l10n.timeOffDays(timeOffLength(start, end)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.textSecondary)),
        ],
      ),
      FormSectionCard(
        eyebrow: l10n.timeOffCover,
        children: [
          PickerField(
            key: const ValueKey('time-off-cover'),
            value: _coverId == null
                ? l10n.timeOffNoCover
                : _nameOf(_coverId, loaded?.coverName),
            placeholder: l10n.timeOffNoCover,
            onTap: _pickCover,
          ),
          Text(l10n.timeOffCoverHint,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  height: 1.4,
                  color: t.textSecondary)),
        ],
      ),
      FormSectionCard(
        eyebrow: l10n.timeOffNote,
        children: [
          AppTextField(
            key: const ValueKey('time-off-note'),
            controller: _noteCtrl,
            hint: l10n.timeOffNoteHint,
            maxLines: 3,
            minLines: 2,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    ];
  }
}

/// An absence the signed-in user may not change: who, why, when and who
/// covers, and what was noted.
class _Summary extends StatelessWidget {
  final TimeOff timeOff;
  const _Summary({required this.timeOff});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final note = timeOff.note?.trim() ?? '';
    return AppCard(
      key: const ValueKey('time-off-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: l10n.timeOffPerson, value: timeOff.userName),
          InfoRow(
              label: l10n.timeOffKind,
              value: timeOffKindLabel(l10n, timeOff.kind)),
          InfoRow(
            label: l10n.timeOffDaysEyebrow,
            value: timeOffPeriodLabel(
                timeOff.startDate, timeOff.endDate, now, locale),
          ),
          InfoRow(
              label: l10n.timeOffCover,
              value: timeOff.coverName ?? l10n.timeOffNoCover),
          if (note.isNotEmpty) InfoRow(label: l10n.timeOffNote, value: note),
        ],
      ),
    );
  }
}
