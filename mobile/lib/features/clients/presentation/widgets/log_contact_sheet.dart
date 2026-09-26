import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

typedef LogContactSave = Future<void> Function(
    ActivityType type, String? note, DateTime occurredAt);

/// The quick answers to "when was this?" — most contacts are logged right
/// after, an hour later, or the next morning.
enum ContactWhen { justNow, hourAgo, yesterday }

DateTime contactWhenAt(ContactWhen when, DateTime now) => switch (when) {
      ContactWhen.justNow => now,
      ContactWhen.hourAgo => now.subtract(const Duration(hours: 1)),
      ContactWhen.yesterday => now.subtract(const Duration(days: 1)),
    };

String contactWhenLabel(AppLocalizations l10n, ContactWhen when) =>
    switch (when) {
      ContactWhen.justNow => l10n.clientsActivityWhenJustNow,
      ContactWhen.hourAgo => l10n.clientsActivityWhenHourAgo,
      ContactWhen.yesterday => l10n.clientsActivityWhenYesterday,
    };

/// The server takes a phone clock running a little ahead; anything further
/// in the future than this has not happened yet.
const _clockSkew = Duration(minutes: 5);

Future<bool> showLogContactSheet(
  BuildContext context, {
  required LogContactSave onSave,
  ActivityType initialType = ActivityType.CALL,
  DateTime? initialOccurredAt,
  String? initialNote,
  String? title,
  String? subtitle,
}) async {
  final l10n = AppLocalizations.of(context);
  final saved = await showAppBottomSheet<bool>(
    context,
    title: title ?? l10n.clientsLogContact,
    subtitle: subtitle,
    builder: (_) => LogContactForm(
      onSave: onSave,
      initialType: initialType,
      initialOccurredAt: initialOccurredAt,
      initialNote: initialNote,
    ),
  );
  return saved ?? false;
}

class LogContactForm extends StatefulWidget {
  final LogContactSave onSave;
  final ActivityType initialType;

  /// When the contact happened, if already known — the moment a call was
  /// started from the app, or the time of an entry being corrected. Without
  /// it the form starts at "Just now".
  final DateTime? initialOccurredAt;
  final String? initialNote;

  const LogContactForm({
    super.key,
    required this.onSave,
    this.initialType = ActivityType.CALL,
    this.initialOccurredAt,
    this.initialNote,
  });

  @override
  State<LogContactForm> createState() => _LogContactFormState();
}

class _LogContactFormState extends State<LogContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final _noteCtrl = TextEditingController(text: widget.initialNote);
  late ActivityType _type = widget.initialType;

  /// A quick choice, resolved against the clock at the moment of saving; or
  /// null when a date and time were picked.
  late ContactWhen? _quick =
      widget.initialOccurredAt == null ? ContactWhen.justNow : null;
  late DateTime? _picked = widget.initialOccurredAt;
  bool _saving = false;
  String? _failure;
  String? _whenError;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  DateTime _occurredAt(DateTime now) =>
      _quick != null ? contactWhenAt(_quick!, now) : (_picked ?? now);

  void _choose(ContactWhen when) => setState(() {
        _quick = when;
        _picked = null;
        _whenError = null;
      });

  void _pick(DateTime value) => setState(() {
        _quick = null;
        _picked = value;
        _whenError = null;
      });

  Future<void> _pickDate() async {
    final now = AppClock.now();
    final base = _occurredAt(now);
    final date = await showDatePicker(
      context: context,
      initialDate: base.isAfter(now) ? now : base,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (date == null || !mounted) return;
    _pick(DateTime(date.year, date.month, date.day, base.hour, base.minute));
  }

  Future<void> _pickTime() async {
    final base = _occurredAt(AppClock.now());
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    _pick(DateTime(base.year, base.month, base.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final note = _noteCtrl.text.trim();
    final now = AppClock.now();
    final occurredAt = _occurredAt(now);
    if (occurredAt.isAfter(now.add(_clockSkew))) {
      setState(() => _whenError = l10n.clientsActivityInFuture);
      return;
    }
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await widget.onSave(_type, note.isEmpty ? null : note, occurredAt);
      if (mounted) Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failure = apiFailureLabel(l10n, ApiFailure.from(err));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shown = _occurredAt(AppClock.now());

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabelledField(
            label: l10n.clientsActivityKind,
            child: FilterPillWrap(pills: [
              for (final type in ActivityType.values)
                FilterPill(
                  label: activityTypeLabel(l10n, type),
                  selected: _type == type,
                  onCard: true,
                  onTap: () => setState(() => _type = type),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          LabelledField(
            label: l10n.clientsActivityWhen,
            child: FilterPillWrap(pills: [
              for (final when in ContactWhen.values)
                FilterPill(
                  key: ValueKey('contact-when-${when.name}'),
                  label: contactWhenLabel(l10n, when),
                  selected: _quick == when,
                  onCard: true,
                  onTap: () => _choose(when),
                ),
            ]),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PickerField(
                  key: const ValueKey('contact-when-date'),
                  value: formatDayMonth(shown, locale),
                  placeholder: l10n.clientsActivityDate,
                  onTap: _pickDate,
                  trailingIcon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PickerField(
                  key: const ValueKey('contact-when-time'),
                  value: formatTimeOfDay(shown),
                  placeholder: l10n.clientsActivityTime,
                  onTap: _pickTime,
                  trailingIcon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          if (_whenError != null) ...[
            const SizedBox(height: 6),
            Text(
              _whenError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
            ),
          ],
          const SizedBox(height: 14),
          LabelledField(
            label: l10n.clientsActivityNoteLabel,
            required: _type == ActivityType.NOTE,
            child: AppTextField(
              controller: _noteCtrl,
              hint: l10n.clientsActivityNoteHint,
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              validator: (v) =>
                  _type == ActivityType.NOTE && (v == null || v.trim().isEmpty)
                      ? l10n.clientsActivityNoteRequired
                      : null,
            ),
          ),
          if (_failure != null) ...[
            const SizedBox(height: 10),
            Text(
              _failure!,
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
            label: l10n.clientsActivitySave,
            loading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
