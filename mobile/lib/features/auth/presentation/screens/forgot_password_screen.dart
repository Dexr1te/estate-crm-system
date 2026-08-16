import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Asking for a reset link.
///
/// There is no sign-up in this app, so for someone who already has an account
/// this is the only way back in that does not go through an administrator.
///
/// It never says whether the address exists. A sign-in screen that answers that
/// question is a way to find out who works at an agency, and the honest-looking
/// answer costs nothing: the mail either arrives or it does not.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _sending = false;
  String? _sentTo;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailCtrl.text.trim();

    setState(() => _sending = true);
    try {
      await Injector.authRepository.requestPasswordReset(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
    } catch (err) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(apiFailureLabel(l10n, ApiFailure.from(err))),
          backgroundColor: context.tokens.dangerSolid,
        ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sentTo = _sentTo;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AppMetrics.constrain(
          CenteredScrollView(
            child: sentTo != null
                ? _Sent(email: sentTo)
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthTitle(
                          title: l10n.authForgotPasswordTitle,
                          subtitle: l10n.authForgotPasswordSubtitle,
                        ),
                        const SizedBox(height: 26),
                        AppTextField(
                          controller: _emailCtrl,
                          skin: FieldSkin.page,
                          hint: l10n.authEmail,
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _sending ? null : _submit(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.authEmailRequired;
                            }
                            if (!v.contains('@')) return l10n.authEmailInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        AppFilledButton(
                          label: l10n.authSendResetLink,
                          loading: _sending,
                          onPressed: _sending ? null : _submit,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: AuthTextLink(
                            label: l10n.authBackToSignIn,
                            onTap: () => context.go('/login'),
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

class _Sent extends StatelessWidget {
  final String email;
  const _Sent({required this.email});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              shape: BoxShape.circle,
              border:
                  Border.all(color: t.border, width: AppMetrics.borderWidth),
            ),
            child:
                Icon(Icons.mark_email_read_outlined, size: 24, color: t.accent),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.authResetLinkSentTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: t.textPrimary),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authResetLinkSentBody(email),
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13,
              height: 1.5,
              color: t.textSecondary),
        ),
        const SizedBox(height: 26),
        AppFilledButton(
          label: l10n.authBackToSignIn,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
