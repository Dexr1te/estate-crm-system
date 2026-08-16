import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the edit sheet hands back when it is saved.
class ProfileEdit {
  final String fullName;
  final String email;
  const ProfileEdit({required this.fullName, required this.email});
}

/// Correcting your own name and the address you sign in with.
///
/// The address is not cosmetic — the backend signs tokens with it and reissues
/// them on change — so this is deliberately a deliberate act: a sheet you open,
/// not a field you can brush against on the settings list.
Future<ProfileEdit?> showProfileEditSheet(
  BuildContext context, {
  required AuthResponse user,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<ProfileEdit>(
    context,
    title: l10n.profileEditProfile,
    builder: (_) => _ProfileEditForm(user: user),
  );
}

class _ProfileEditForm extends StatefulWidget {
  final AuthResponse user;
  const _ProfileEditForm({required this.user});

  @override
  State<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<_ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.user.fullName);
  late final _emailCtrl = TextEditingController(text: widget.user.email);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ProfileEdit(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      ),
    );
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
            label: l10n.profileFullName,
            child: AppTextField(
              controller: _nameCtrl,
              hint: l10n.profileFullName,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.clientsNameRequired
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          LabelledField(
            label: l10n.profileEmail,
            child: AppTextField(
              controller: _emailCtrl,
              hint: l10n.profileEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.authEmailRequired;
                }
                if (!v.contains('@')) return l10n.authEmailInvalid;
                return null;
              },
            ),
          ),
          const SizedBox(height: 18),
          AppFilledButton(label: l10n.profileSave, onPressed: _submit),
        ],
      ),
    );
  }
}
