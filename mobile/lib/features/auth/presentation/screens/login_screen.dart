import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<AuthBloc>()
        .add(AuthLoginEvent(_emailCtrl.text.trim(), _passCtrl.text));
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
                      const BrandMark(),
                      const SizedBox(height: 22),
                      AuthTitle(
                        title: l10n.authWelcomeBack,
                        subtitle: l10n.authSignInSubtitle,
                      ),
                      const SizedBox(height: 26),
                      AppTextField(
                        controller: _emailCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authEmail,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.authEmailRequired;
                          }
                          if (!v.contains('@')) return l10n.authEmailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _passCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffix: _ObscureToggle(
                          obscured: _obscure,
                          onTap: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? l10n.authPasswordRequired
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: AuthTextLink(
                          label: l10n.authForgotPassword,
                          onTap:
                              loading ? null : () => ctx.go('/forgot-password'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppFilledButton(
                        label: l10n.authSignIn,
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                      const SizedBox(height: 18),
                      AuthFooterLink(
                        question: l10n.authHaveAnInvite,
                        action: l10n.authActivate,
                        onTap: loading ? null : () => ctx.go('/accept-invite'),
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

/// A plain tappable line of text — "Forgot password?", "Back to sign in".
class AuthTextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const AuthTextLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Keeps the tap target at the design system's minimum without moving
        // the text off the line it belongs on.
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: onTap == null ? t.textHint : t.textPrimary),
        ),
      ),
    );
  }
}

class AuthTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: t.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13.5,
              height: 1.5,
              color: t.textSecondary),
        ),
      ],
    );
  }
}

class _ObscureToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;
  const _ObscureToggle({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IconButton(
      onPressed: onTap,
      splashRadius: 20,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: t.textHint,
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;
  const AuthFooterLink(
      {super.key,
      required this.question,
      required this.action,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(question,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  color: t.textSecondary)),
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary)),
          ),
        ],
      ),
    );
  }
}
