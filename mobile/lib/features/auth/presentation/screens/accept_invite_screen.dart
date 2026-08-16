import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';

class AcceptInviteScreen extends StatefulWidget {
  final String? token;
  const AcceptInviteScreen({super.key, this.token});
  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenCtrl =
      TextEditingController(text: widget.token ?? '');
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<AuthBloc>()
        .add(AuthAcceptInviteEvent(_tokenCtrl.text.trim(), _passCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(ctx)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(apiFailureLabel(l10n, state.failure)),
                    backgroundColor: t.dangerSolid));
            }
          },
          builder: (ctx, state) {
            final loading = state is AuthLoading;
            return AppMetrics.constrain(
              CenteredScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InviteMark(),
                      const SizedBox(height: 22),
                      AuthTitle(
                        title: l10n.authAcceptYourInvite,
                        subtitle: l10n.authAcceptInviteSubtitle,
                      ),
                      const SizedBox(height: 26),
                      AppTextField(
                        controller: _tokenCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authInviteCode,
                        icon: Icons.confirmation_number_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.authInviteCodeRequired
                            : null,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _passCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authNewPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          splashRadius: 20,
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: t.textHint),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? l10n.authPasswordMinLength
                            : null,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _confirmCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authConfirmPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (v) => v != _passCtrl.text
                            ? l10n.authPasswordsDoNotMatch
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          l10n.authPasswordHelp,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11.5,
                              height: 1.5,
                              color: t.textHint),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppFilledButton(
                        label: l10n.authSetPasswordSignIn,
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: loading ? null : () => ctx.go('/login'),
                          child: Text(
                            l10n.authBackToSignIn,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InviteMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: t.border, width: AppMetrics.borderWidth),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.vpn_key_outlined, size: 26, color: t.accent),
    );
  }
}
