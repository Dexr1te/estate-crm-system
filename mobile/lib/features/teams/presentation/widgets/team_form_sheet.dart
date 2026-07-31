import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Shows the create/edit team sheet. Returns a TeamRequest body
/// ({name, managerId?}) or null if cancelled. [managers] populates the
/// optional manager picker.
Future<Map<String, dynamic>?> showTeamFormSheet(
  BuildContext context, {
  TeamResponse? existing,
  List<AgentResponse> managers = const [],
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<Map<String, dynamic>>(
    context,
    title: existing == null ? l10n.teamsCreateTeam : l10n.teamsEditTeam,
    builder: (_) => _TeamForm(existing: existing, managers: managers),
  );
}

class _TeamForm extends StatefulWidget {
  final TeamResponse? existing;
  final List<AgentResponse> managers;
  const _TeamForm({this.existing, required this.managers});
  @override
  State<_TeamForm> createState() => _TeamFormState();
}

class _TeamFormState extends State<_TeamForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  int? _managerId;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _managerId = widget.existing?.managerId;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'name': _name.text.trim(),
      if (_managerId != null) 'managerId': _managerId,
    });
  }

  Future<void> _pickManager() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.teamsManagerOptional,
      items: [
        for (final m in widget.managers)
          PickerItem(id: m.id, title: m.fullName, subtitle: m.email),
      ],
      selectedId: _managerId,
      searchHint: l10n.teamsManagerOptional,
      emptyLabel: l10n.teamsNoManager,
    );
    if (picked != null && mounted) setState(() => _managerId = picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Only resolve a name for a manager still present in the list.
    final selected = widget.managers
        .where((m) => m.id == _managerId)
        .map((m) => m.fullName)
        .firstOrNull;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabelledField(
            label: l10n.teamsTeamName,
            required: true,
            child: AppTextField(
              controller: _name,
              hint: l10n.teamsTeamName,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.teamsRequired : null,
            ),
          ),
          const SizedBox(height: 9),
          LabelledField(
            label: l10n.teamsManagerOptional,
            child: PickerField(
              value: selected,
              placeholder: l10n.teamsNoManager,
              onTap: _pickManager,
            ),
          ),
          const SizedBox(height: 18),
          AppFilledButton(
            label: widget.existing == null ? l10n.teamsCreate : l10n.teamsSave,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
