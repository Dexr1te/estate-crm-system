import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_due_field.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_link_fields.dart';
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
  String? _dueError;
  String? _failure;
  bool _saving = false;

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
    setState(() =>
        _dueError = _dueAt == null ? l10n.meetingsPleaseSelectDateTime : null);
    if (!ok || _dueAt == null) return;
    final note = _noteCtrl.text.trim();
    _run(() => widget.onSave({
          'title': _titleCtrl.text.trim(),
          if (note.isNotEmpty) 'note': note,
          'dueAt': _dueAt!.toIso8601String(),
          if (_client != null) 'clientId': _client!.id,
          if (_deal != null) 'dealId': _deal!.id,
          if (widget.canAssign && _assignee != null)
            'assigneeId': _assignee!.id,
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

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
