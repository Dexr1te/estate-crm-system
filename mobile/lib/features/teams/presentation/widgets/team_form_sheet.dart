import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

/// Shows the create/edit team sheet. Returns a TeamRequest body
/// ({name, managerId?}) or null if cancelled. [managers] populates the
/// optional manager picker.
Future<Map<String, dynamic>?> showTeamFormSheet(
  BuildContext context, {
  TeamResponse? existing,
  List<AgentResponse> managers = const [],
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    // Manager options: only include the current managerId if it's present in
    // the list, to satisfy the dropdown's single-selection invariant.
    final managerIds = widget.managers.map((m) => m.id).toSet();
    final selected =
        (_managerId != null && managerIds.contains(_managerId)) ? _managerId : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'Create team' : 'Edit team',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Team name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Manager (optional)'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('No manager')),
                ...widget.managers.map((m) =>
                    DropdownMenuItem<int?>(value: m.id, child: Text(m.fullName))),
              ],
              onChanged: (v) => setState(() => _managerId = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.existing == null ? 'Create' : 'Save')),
            ),
          ],
        ),
      ),
    );
  }
}
