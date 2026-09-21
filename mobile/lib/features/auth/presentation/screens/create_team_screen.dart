import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthBloc>();
    final danger = context.tokens.dangerSolid;

    setState(() => _saving = true);
    try {
      await Injector.teamsRepository.createMyTeam(_nameCtrl.text.trim());

      auth.add(AuthRefreshMeEvent());
    } catch (err) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(apiFailureLabel(l10n, ApiFailure.from(err))),
            backgroundColor: danger));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AppMetrics.constrain(
          CenteredScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 22),
                  AuthTitle(
                    title: l10n.authCreateTeamTitle,
                    subtitle: l10n.authCreateTeamSubtitle,
                  ),
                  const SizedBox(height: 26),
                  AppTextField(
                    controller: _nameCtrl,
                    skin: FieldSkin.page,
                    hint: l10n.authCreateTeamName,
                    icon: Icons.apartment_outlined,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.authCreateTeamNameRequired
                        : null,
                  ),
                  const SizedBox(height: 18),
                  AppFilledButton(
                    label: l10n.authCreateTeamAction,
                    loading: _saving,
                    onPressed: _saving ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AuthTextLink(
                      label: l10n.profileTitle,
                      onTap: _saving ? null : () => context.go('/profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
