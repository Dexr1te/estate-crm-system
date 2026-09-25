import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/contact_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

typedef LogContactSave = Future<void> Function(ActivityType type, String? note);

Future<bool> showLogContactSheet(
  BuildContext context, {
  required LogContactSave onSave,
}) async {
  final l10n = AppLocalizations.of(context);
  final saved = await showAppBottomSheet<bool>(
    context,
    title: l10n.clientsLogContact,
    builder: (_) => LogContactForm(onSave: onSave),
  );
  return saved ?? false;
}

class LogContactForm extends StatefulWidget {
  final LogContactSave onSave;
  const LogContactForm({super.key, required this.onSave});

  @override
  State<LogContactForm> createState() => _LogContactFormState();
}

class _LogContactFormState extends State<LogContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  ActivityType _type = ActivityType.CALL;
  bool _saving = false;
  String? _failure;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final note = _noteCtrl.text.trim();
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await widget.onSave(_type, note.isEmpty ? null : note);
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
