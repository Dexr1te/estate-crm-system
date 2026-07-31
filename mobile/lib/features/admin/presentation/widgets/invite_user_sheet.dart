import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<Map<String, dynamic>?> showInviteUserSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<Map<String, dynamic>>(
    context,
    title: l10n.adminInviteUser,
    subtitle: l10n.adminInviteHelper,
    builder: (_) => const _InviteUserForm(),
  );
}

String dataScopeLabel(AppLocalizations l10n, DataScope scope) {
  switch (scope) {
    case DataScope.OWN:
      return l10n.coreDataScopeOwn;
    case DataScope.TEAM:
      return l10n.coreDataScopeTeam;
    case DataScope.ALL:
      return l10n.coreDataScopeAll;
  }
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

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabelledField(
            label: l10n.adminFullName,
            child: AppTextField(
              controller: _name,
              hint: l10n.adminFullName,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.adminRequired : null,
            ),
          ),
          const SizedBox(height: 9),
          LabelledField(
            label: l10n.adminEmail,
            child: AppTextField(
              controller: _email,
              hint: 'name@estatecrm.ru',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || !v.contains('@'))
                  ? l10n.adminEnterValidEmail
                  : null,
            ),
          ),
          const SizedBox(height: 9),
          LabelledField(
            label: l10n.adminPhoneOptional,
            child: AppTextField(
              controller: _phone,
              hint: '+7 ___ ___-__-__',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 12),
          _PillGroup(
            label: l10n.adminRole,
            options: [
              for (final r in Role.values)
                (
                  label: roleLabel(l10n, r),
                  selected: _role == r,
                  onTap: () {
                    setState(() => _role = r);
                  }
                ),
            ],
          ),
          const SizedBox(height: 12),
          _PillGroup(
            label: l10n.adminDataScope,
            options: [
              for (final s in DataScope.values)
                (
                  label: dataScopeLabel(l10n, s),
                  selected: _scope == s,
                  onTap: () {
                    setState(() => _scope = s);
                  }
                ),
            ],
          ),
          const SizedBox(height: 18),
          AppFilledButton(label: l10n.adminCreateInvite, onPressed: _submit),
        ],
      ),
    );
  }
}

class _PillGroup extends StatelessWidget {
  final String label;
  final List<({String label, bool selected, VoidCallback onTap})> options;
  const _PillGroup({required this.label, required this.options});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          FilterPillWrap(pills: [
            for (final o in options)
              FilterPill(
                label: o.label,
                selected: o.selected,
                onCard: true,
                onTap: o.onTap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              ),
          ]),
        ],
      );
}
