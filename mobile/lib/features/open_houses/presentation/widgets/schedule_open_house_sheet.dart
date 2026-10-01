import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/open_houses/domain/repositories/open_houses_repository.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/open_house_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The longest open house the server takes.
const openHouseMaxLength = Duration(hours: 12);

/// Schedules an open house on [propertyId], or moves [existing]. Resolves to
/// what was saved, or null when the sheet was dismissed.
Future<OpenHouse?> showScheduleOpenHouseSheet(
  BuildContext context, {
  required int propertyId,
  OpenHouse? existing,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<OpenHouse>(
    context,
    title: existing == null ? l10n.openHouseSchedule : l10n.openHouseEdit,
    builder: (_) =>
        ScheduleOpenHouseForm(propertyId: propertyId, existing: existing),
  );
}

class ScheduleOpenHouseForm extends StatefulWidget {
  final int propertyId;
  final OpenHouse? existing;

  const ScheduleOpenHouseForm(
      {super.key, required this.propertyId, this.existing});

  @override
  State<ScheduleOpenHouseForm> createState() => _ScheduleOpenHouseFormState();
}

class _ScheduleOpenHouseFormState extends State<ScheduleOpenHouseForm> {
  late final _noteCtrl = TextEditingController(text: widget.existing?.note);
  late DateTime _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _day = DateTime(existing.startsAt.year, existing.startsAt.month,
          existing.startsAt.day);
      _start = TimeOfDay.fromDateTime(existing.startsAt);
      _end = TimeOfDay.fromDateTime(existing.endsAt);
    } else {
      final tomorrow = AppClock.now().add(const Duration(days: 1));
      _day = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      _start = const TimeOfDay(hour: 12, minute: 0);
      _end = const TimeOfDay(hour: 14, minute: 0);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  DateTime _at(TimeOfDay time) =>
      DateTime(_day.year, _day.month, _day.day, time.hour, time.minute);

  Future<void> _pickDay() async {
    final now = AppClock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _day = picked;
      _error = null;
    });
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
        context: context, initialTime: start ? _start : _end);
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        final length = _at(_end).difference(_at(_start));
        _start = picked;
        if (length > Duration.zero) {
          _end = TimeOfDay.fromDateTime(_at(picked).add(length));
        }
      } else {
        _end = picked;
      }
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final startsAt = _at(_start);
    final endsAt = _at(_end);
    if (!endsAt.isAfter(startsAt)) {
      setState(() => _error = l10n.openHouseEndsBeforeStart);
      return;
    }
    if (endsAt.difference(startsAt) > openHouseMaxLength) {
      setState(() => _error = l10n.openHouseTooLong);
      return;
    }
    final note = _noteCtrl.text.trim();
    final draft = OpenHouseDraft(
        startsAt: startsAt, endsAt: endsAt, note: note.isEmpty ? null : note);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = widget.existing;
      final saved = existing == null
          ? await Injector.openHousesRepository.create(widget.propertyId, draft)
          : await Injector.openHousesRepository.update(existing.id, draft);
      if (mounted) Navigator.pop(context, saved);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = openHouseFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: l10n.openHouseDate,
          child: PickerField(
            key: const ValueKey('open-house-day'),
            value: formatWeekdayDate(_day, locale),
            placeholder: l10n.openHouseDate,
            onTap: _pickDay,
            trailingIcon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabelledField(
                label: l10n.openHouseStarts,
                child: PickerField(
                  key: const ValueKey('open-house-start'),
                  value: formatTimeOfDay(_at(_start)),
                  placeholder: l10n.openHouseStarts,
                  onTap: () => _pickTime(start: true),
                  trailingIcon: Icons.schedule_rounded,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: LabelledField(
                label: l10n.openHouseEnds,
                child: PickerField(
                  key: const ValueKey('open-house-end'),
                  value: formatTimeOfDay(_at(_end)),
                  placeholder: l10n.openHouseEnds,
                  onTap: () => _pickTime(start: false),
                  trailingIcon: Icons.schedule_rounded,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.openHouseNoteLabel,
          child: AppTextField(
            controller: _noteCtrl,
            hint: l10n.openHouseNoteHint,
            maxLines: 4,
            minLines: 2,
            keyboardType: TextInputType.multiline,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            key: const ValueKey('open-house-error'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                height: 1.35,
                color: t.dangerText),
          ),
        ],
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('open-house-save'),
          label: l10n.openHouseSave,
          loading: _saving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
