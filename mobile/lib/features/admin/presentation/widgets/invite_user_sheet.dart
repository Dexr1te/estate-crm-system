import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Shows the "Invite user" bottom sheet and returns a CreateAgentRequest body
/// ({fullName, email, phone?, role, dataScope}), or null if cancelled.
Future<Map<String, dynamic>?> showInviteUserSheet(BuildContext context) {
  return showAppBottomSheet<Map<String, dynamic>>(
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
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adminInviteUser,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.adminFullName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.adminRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.adminEmail),
              validator: (v) => (v == null || !v.contains('@'))
                  ? l10n.adminEnterValidEmail
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.adminPhoneOptional),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Role>(
              initialValue: _role,
              decoration: InputDecoration(labelText: l10n.adminRole),
              items: Role.values
                  .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? Role.AGENT),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DataScope>(
              initialValue: _scope,
              decoration: InputDecoration(labelText: l10n.adminDataScope),
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
                  onPressed: _submit, child: Text(l10n.adminCreateInvite)),
            ),
          ],
        ),
      ),
    );
  }
}
