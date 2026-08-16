import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Spending a reset code on a new password.
///
/// Reached two ways, like accepting an invite: the link in the email, which
/// arrives with the code already filled in, or by hand from the sign-in screen
/// for someone whose mail client swallowed the link. A successful reset signs
/// them straight in — they have just proved they hold the address.
class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  const ResetPasswordScreen({super.key, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
        .add(AuthResetPasswordEvent(_tokenCtrl.text.trim(), _passCtrl.text));
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
                      AuthTitle(
                        title: l10n.authResetPasswordTitle,
                        subtitle: l10n.authResetPasswordSubtitle,
                      ),
                      const SizedBox(height: 26),
                      AppTextField(
                        controller: _tokenCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authResetCode,
                        icon: Icons.confirmation_number_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.authResetCodeRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _passCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authNewPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: t.textHint,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.authPasswordRequired;
                          }
                          if (v.length < 6) return l10n.authPasswordMinLength;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _confirmCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authConfirmPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => loading ? null : _submit(),
                        validator: (v) => v != _passCtrl.text
                            ? l10n.authPasswordsDoNotMatch
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authPasswordHelp,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppFilledButton(
                        label: l10n.authSetPasswordSignIn,
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: AuthTextLink(
                          label: l10n.authBackToSignIn,
                          onTap: loading ? null : () => ctx.go('/login'),
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
