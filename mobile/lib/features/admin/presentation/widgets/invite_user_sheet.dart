import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';

/// Shows the "Invite user" bottom sheet and returns a CreateAgentRequest body
/// ({fullName, email, phone?, role, dataScope}), or null if cancelled.
Future<Map<String, dynamic>?> showInviteUserSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _InviteUserForm(),
  );
}

class _InviteUserForm extends StatefulWidget {
  const _InviteUserForm();
  @override
  State<_InviteUserForm> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<_InviteUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  Role _role = Role.AGENT;
  DataScope _scope = DataScope.OWN;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'fullName': _name.text.trim(),
      'email': _email.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
      'role': _role.name,
      'dataScope': _scope.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite user', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Role>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: Role.values
                  .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? Role.AGENT),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DataScope>(
              initialValue: _scope,
              decoration: const InputDecoration(labelText: 'Data scope'),
              items: DataScope.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _scope = v ?? DataScope.OWN),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _submit, child: const Text('Send invite')),
            ),
          ],
        ),
      ),
    );
  }
}
