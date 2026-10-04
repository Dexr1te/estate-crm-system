import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/domain/task_repeat_rule.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_repeat_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Picks how a task due at [due] repeats. Resolves to the rule chosen — one
/// with [RepeatFrequency.none] when the task should not repeat — or null when
/// the sheet was dismissed.
Future<TaskRepeat?> showTaskRepeatSheet(
  BuildContext context, {
  required TaskRepeat? initial,
  required DateTime due,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<TaskRepeat>(
    context,
    title: l10n.tasksRepeat,
    builder: (sheet) => TaskRepeatForm(
      initial: initial,
      due: due,
      onDone: (repeat) => Navigator.pop(sheet, repeat),
    ),
  );
}

enum _End { never, onDay, after }

class TaskRepeatForm extends StatefulWidget {
  final TaskRepeat? initial;
  final DateTime due;
  final ValueChanged<TaskRepeat> onDone;

  const TaskRepeatForm({
    super.key,
    required this.initial,
    required this.due,
    required this.onDone,
  });

  @override
  State<TaskRepeatForm> createState() => _TaskRepeatFormState();
}

class _TaskRepeatFormState extends State<TaskRepeatForm> {
  final _formKey = GlobalKey<FormState>();
  late RepeatFrequency _frequency =
      widget.initial?.frequency ?? RepeatFrequency.none;
  late Set<int> _days = {
    ...weekdayNumbers(widget.initial?.weekdays ?? const []),
  };
  late _End _end = widget.initial?.until != null
      ? _End.onDay
      : widget.initial?.count != null
          ? _End.after
          : _End.never;
  late DateTime? _until = widget.initial?.until;
  late final _countCtrl =
      TextEditingController(text: widget.initial?.count?.toString() ?? '5');
  String? _untilError;

  /// The day the pattern counts from: a rule being edited keeps its own.
  DateTime get _anchor => _repeat.anchorAt ?? widget.due;

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  TaskRepeat get _repeat => TaskRepeat(
        frequency: _frequency,
        weekdays: _frequency == RepeatFrequency.weekly
            ? [for (final d in _days.toList()..sort()) weekdayNames[d - 1]]
            : const [],
        until: _end == _End.onDay ? _until : null,
        count: _end == _End.after ? int.tryParse(_countCtrl.text.trim()) : null,
        // A new pattern counts from the task's own due time, as the server
        // will have it; the same one keeps the day it counts from.
        anchorAt: _frequency == widget.initial?.frequency
            ? widget.initial?.anchorAt
            : null,
      );

  void _pickFrequency(RepeatFrequency frequency) => setState(() {
        _frequency = frequency;
        if (frequency == RepeatFrequency.weekly && _days.isEmpty) {
          _days = {_anchor.weekday};
        }
      });

  void _toggleDay(int day) => setState(() {
        if (_days.contains(day)) {
          // A weekly rule falls on at least one day.
          if (_days.length > 1) _days.remove(day);
        } else {
          _days.add(day);
        }
      });

  Future<void> _pickUntil() async {
    final first = DateTime(widget.due.year, widget.due.month, widget.due.day);
    final initial = _until != null && !_until!.isBefore(first)
        ? _until!
        : first.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() {
      _until = picked;
      _untilError = null;
    });
  }

  void _done() {
    final l10n = AppLocalizations.of(context);
    if (_frequency == RepeatFrequency.none) {
      widget.onDone(const TaskRepeat());
      return;
    }
    final ok = _formKey.currentState!.validate();
    setState(() => _untilError =
        _end == _End.onDay && _until == null ? l10n.tasksRepeatPickDay : null);
    if (!ok || _untilError != null) return;
    widget.onDone(_repeat);
  }

  String _endLabel(AppLocalizations l10n, _End end) {
    switch (end) {
      case _End.never:
        return l10n.tasksRepeatEndNever;
      case _End.onDay:
        return l10n.tasksRepeatEndOn;
      case _End.after:
        return l10n.tasksRepeatEndAfter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final repeats = _frequency != RepeatFrequency.none;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterPillWrap(pills: [
            for (final frequency in RepeatFrequency.values)
              FilterPill(
                label: repeatOptionLabel(l10n, frequency),
                selected: _frequency == frequency,
                onCard: true,
                onTap: () => _pickFrequency(frequency),
              ),
          ]),
          if (_frequency == RepeatFrequency.weekly) ...[
            const SizedBox(height: 16),
            EyebrowLabel(l10n.tasksRepeatDays),
            const SizedBox(height: 10),
            FilterPillWrap(pills: [
              for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                FilterPill(
                  label: weekdayShort(day, locale),
                  selected: _days.contains(day),
                  onCard: true,
                  onTap: () => _toggleDay(day),
                ),
            ]),
          ],
          if (repeats) ...[
            const SizedBox(height: 16),
            EyebrowLabel(l10n.tasksRepeatEnds),
            const SizedBox(height: 10),
            FilterPillWrap(pills: [
              for (final end in _End.values)
                FilterPill(
                  label: _endLabel(l10n, end),
                  selected: _end == end,
                  onCard: true,
                  onTap: () => setState(() {
                    _end = end;
                    _untilError = null;
                  }),
                ),
            ]),
            if (_end == _End.onDay) ...[
              const SizedBox(height: 12),
              PickerField(
                value: _until == null ? null : formatFullDate(_until!, locale),
                placeholder: l10n.tasksRepeatPickDay,
                onTap: _pickUntil,
                trailingIcon: Icons.calendar_today_outlined,
              ),
              if (_untilError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _untilError!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      color: t.dangerText),
                ),
              ],
            ],
            if (_end == _End.after) ...[
              const SizedBox(height: 12),
              LabelledField(
                label: l10n.tasksRepeatCount,
                child: AppTextField(
                  controller: _countCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    return n == null || n < 1 || n > 999
                        ? l10n.tasksRepeatCountInvalid
                        : null;
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            TaskRepeatLine(
              text: repeatLabel(l10n, _repeat, widget.due, locale),
              emphasised: true,
            ),
          ],
          const SizedBox(height: 18),
          AppFilledButton(label: l10n.tasksRepeatUse, onPressed: _done),
        ],
      ),
    );
  }
}

/// "Repeats ..." with its icon, under a task's title and in its sheet.
class TaskRepeatLine extends StatelessWidget {
  final String text;

  /// Larger and darker where the rule is the subject, as in the picker.
  final bool emphasised;

  const TaskRepeatLine(
      {super.key, required this.text, this.emphasised = false});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = emphasised ? t.textSecondary : t.textHint;
    final size = emphasised ? 12.5 : 11.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.repeat_rounded, size: size + 2, color: color),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: size, color: color),
          ),
        ),
      ],
    );
  }
}
