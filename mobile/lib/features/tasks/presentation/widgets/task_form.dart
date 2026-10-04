import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/domain/task_repeat_rule.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_due_field.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_link_fields.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_repeat_labels.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_repeat_sheet.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

typedef TaskSave = Future<void> Function(Map<String, dynamic> data);

class TaskForm extends StatefulWidget {
  final TaskResponse? task;
  final PickerItem? client;
  final PickerItem? deal;
  final PickerItem? assignee;
  final bool canAssign;
  final TaskSave onSave;
  final Future<void> Function()? onDelete;

  /// Offered on a task that repeats: its series writes nothing more.
  final Future<void> Function()? onStopRepeating;
  final DateTime? initialDueAt;

  const TaskForm({
    super.key,
    this.task,
    this.initialDueAt,
    this.client,
    this.deal,
    this.assignee,
    this.canAssign = false,
    required this.onSave,
    this.onDelete,
    this.onStopRepeating,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.task?.title);
  late final _noteCtrl = TextEditingController(text: widget.task?.note);
  late DateTime? _dueAt = widget.task?.dueAt ?? widget.initialDueAt;
  late PickerItem? _client = widget.client;
  late PickerItem? _deal = widget.deal;
  late PickerItem? _assignee = widget.assignee;
  late TaskRepeat? _repeat = widget.task?.repeat;
  String? _dueError;
  String? _repeatError;
  String? _failure;
  bool _saving = false;

  bool get _repeats =>
      _repeat != null && _repeat!.frequency != RepeatFrequency.none;

  /// The rule as it will read once saved: a moved due time moves the day the
  /// pattern counts from.
  TaskRepeat? get _shownRepeat {
    final repeat = _repeat;
    if (repeat == null) return null;
    final task = widget.task;
    return task != null && _dueAt != task.dueAt
        ? repeat.copyWith(anchorAt: null)
        : repeat;
  }

  DateTime get _dueOrDefault =>
      _dueAt ?? quickDueAt(TaskQuickDue.tomorrowMorning, AppClock.now());

  Future<void> _pickRepeat() async {
    final picked = await showTaskRepeatSheet(context,
        initial: _shownRepeat, due: _dueOrDefault);
    if (picked == null || !mounted) return;
    setState(() {
      _repeat = picked.frequency == RepeatFrequency.none ? null : picked;
      _repeatError = null;
    });
  }

  Future<void> _stopRepeating() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(context,
        title: l10n.tasksRepeatStopTitle,
        content: l10n.tasksRepeatStopBody,
        confirmLabel: l10n.tasksRepeatStop,
        icon: Icons.repeat_rounded);
    if (ok && mounted) await _run(widget.onStopRepeating!);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await action();
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failure = apiFailureLabel(l10n, ApiFailure.from(err));
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final ok = _formKey.currentState!.validate();
    final until = _repeats ? _repeat!.until : null;
    setState(() {
      _dueError = _dueAt == null ? l10n.meetingsPleaseSelectDateTime : null;
      _repeatError = until != null &&
              _dueAt != null &&
              until.isBefore(DateTime(_dueAt!.year, _dueAt!.month, _dueAt!.day))
          ? l10n.tasksRepeatUntilBeforeDue
          : null;
    });
    if (!ok || _dueAt == null || _repeatError != null) return;
    final note = _noteCtrl.text.trim();
    // A plain task says nothing about repeats, as before; an edited one that
    // repeated says NONE when the picker took its rule away.
    final sendRepeat = _repeats || (widget.task?.repeats ?? false);
    _run(() => widget.onSave({
          'title': _titleCtrl.text.trim(),
          if (note.isNotEmpty) 'note': note,
          'dueAt': _dueAt!.toIso8601String(),
          if (_client != null) 'clientId': _client!.id,
          if (_deal != null) 'dealId': _deal!.id,
          if (widget.canAssign && _assignee != null)
            'assigneeId': _assignee!.id,
          if (sendRepeat) 'repeat': repeatRequest(_repeat),
        }));
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(context,
        title: l10n.tasksDeleteTitle, content: l10n.tasksDeleteBody);
    if (ok && mounted) await _run(widget.onDelete!);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final saved = widget.task;
    final shown = _shownRepeat;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saved != null && saved.repeats) ...[
            TaskRepeatLine(
              text: repeatLabel(l10n, saved.repeat!, saved.dueAt, locale),
              emphasised: true,
            ),
            const SizedBox(height: 14),
          ],
          LabelledField(
            label: l10n.tasksFieldTitle,
            required: true,
            child: AppTextField(
              controller: _titleCtrl,
              hint: l10n.tasksTitleHint,
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.tasksTitleRequired
                  : v.trim().length > 200
                      ? l10n.tasksTitleTooLong
                      : null,
            ),
          ),
          const SizedBox(height: 14),
          EyebrowLabel(l10n.tasksDue),
          const SizedBox(height: 10),
          TaskDueField(
            value: _dueAt,
            error: _dueError,
            onChanged: (v) => setState(() {
              _dueAt = v;
              _dueError = null;
            }),
          ),
          const SizedBox(height: 14),
          LabelledField(
            label: l10n.tasksRepeat,
            child: PickerField(
              value: shown == null || !_repeats
                  ? null
                  : repeatLabel(l10n, shown, _dueOrDefault, locale),
              placeholder: l10n.tasksRepeatNone,
              onTap: _pickRepeat,
              trailingIcon: Icons.repeat_rounded,
            ),
          ),
          if (_repeatError != null) ...[
            const SizedBox(height: 6),
            Text(
              _repeatError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
            ),
          ],
          const SizedBox(height: 14),
          TaskLinkFields(
            client: _client,
            deal: _deal,
            assignee: widget.canAssign ? _assignee : null,
            showAssignee: widget.canAssign,
            loadClients: () async => [
              for (final c in await Injector.clientsRepository.getClients())
                PickerItem(id: c.id, title: c.fullName, subtitle: c.phone),
            ],
            loadDeals: () async => [
              for (final d in await Injector.dealsRepository.getDeals())
                PickerItem(id: d.id, title: d.title, subtitle: d.clientName),
            ],
            loadAgents: () async => [
              for (final a in await Injector.agentsRepository.getAgentOptions())
                PickerItem(id: a.id, title: a.fullName, subtitle: a.email),
            ],
            onClient: (v) => setState(() => _client = v),
            onDeal: (v) => setState(() => _deal = v),
            onAssignee: (v) => setState(() => _assignee = v),
          ),
          const SizedBox(height: 14),
          LabelledField(
            label: l10n.tasksNote,
            child: AppTextField(
              controller: _noteCtrl,
              hint: l10n.tasksNoteHint,
              maxLines: 4,
              minLines: 2,
              keyboardType: TextInputType.multiline,
              validator: (v) => v != null && v.trim().length > 2000
                  ? l10n.coreErrorBadRequest
                  : null,
            ),
          ),
          if (_failure != null) ...[
            const SizedBox(height: 10),
            Text(_failure!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.dangerText)),
          ],
          const SizedBox(height: 18),
          AppFilledButton(
              label: l10n.tasksSave, loading: _saving, onPressed: _submit),
          if (widget.onStopRepeating != null &&
              (widget.task?.repeats ?? false)) ...[
            const SizedBox(height: 8),
            AppGhostButton(
                label: l10n.tasksRepeatStop,
                onPressed: _saving ? null : _stopRepeating),
          ],
          if (widget.onDelete != null) ...[
            const SizedBox(height: 8),
            AppGhostButton(
                label: l10n.tasksDelete,
                onPressed: _saving ? null : _delete,
                labelColor: t.dangerText),
          ],
        ],
      ),
    );
  }
}
