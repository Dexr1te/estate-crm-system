import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class TaskDueField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? error;

  const TaskDueField({
    super.key,
    required this.value,
    required this.onChanged,
    this.error,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = AppClock.now();
    final base = value ?? quickDueAt(TaskQuickDue.tomorrowMorning, now);
    final first = base.isBefore(now) ? base : now;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null) return;
    onChanged(
        DateTime(date.year, date.month, date.day, base.hour, base.minute));
  }

  Future<void> _pickTime(BuildContext context) async {
    final base =
        value ?? quickDueAt(TaskQuickDue.tomorrowMorning, AppClock.now());
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;
    onChanged(
        DateTime(base.year, base.month, base.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterPillWrap(pills: [
          for (final quick in TaskQuickDue.values)
            FilterPill(
              label: quickDueLabel(l10n, quick),
              selected: value != null && value == quickDueAt(quick, now),
              onCard: true,
              onTap: () => onChanged(quickDueAt(quick, now)),
            ),
        ]),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabelledField(
                label: l10n.tasksDate,
                required: true,
                child: PickerField(
                  value: value == null ? null : formatDayMonth(value!, locale),
                  placeholder: l10n.tasksDate,
                  onTap: () => _pickDate(context),
                  trailingIcon: Icons.calendar_today_outlined,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: LabelledField(
                label: l10n.tasksTime,
                required: true,
                child: PickerField(
                  value: value == null ? null : formatTimeOfDay(value!),
                  placeholder: l10n.tasksTime,
                  onTap: () => _pickTime(context),
                  trailingIcon: Icons.schedule_rounded,
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
          ),
        ],
      ],
    );
  }
}
