import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// The details a new account is made of.
///
/// Nothing is signed in at the end of this: the backend mails a code and the
/// next screen takes it, which is what keeps someone from signing up on an
/// address that is not theirs.
class RegisterFormScreen extends StatefulWidget {
  final Role role;
  const RegisterFormScreen({super.key, required this.role});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;
  bool _acceptedMissing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _acceptedMissing = !_accepted);
    if (!_formKey.currentState!.validate() || !_accepted) return;
    context.read<AuthBloc>().add(AuthRegisterEvent(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: widget.role,
          phone: _phoneCtrl.text.trim(),
        ));
  }

  /// An address that already has an invite waiting cannot be registered again —
  /// the invite is the way in, so offer it instead of repeating the refusal.
  Future<void> _offerInvite(BuildContext context, AppLocalizations l10n) async {
    final go = await showConfirmDialog(
      context,
      title: l10n.authInvitePendingTitle,
      content: l10n.authInvitePendingBody,
      confirmLabel: l10n.authActivate,
      icon: Icons.vpn_key_outlined,
    );
    if (go && context.mounted) context.go('/accept-invite');
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
            if (state is AuthVerificationRequired) {
              ctx.go('/verify-email?email=${Uri.encodeComponent(state.email)}');
              return;
            }
            if (state is! AuthError) return;
            if (state.failure.serverCode == 'INVITE_PENDING') {
              _offerInvite(ctx, l10n);
              return;
            }
            ScaffoldMessenger.of(ctx)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                  content: Text(state.failure.serverCode == 'EMAIL_TAKEN'
                      ? l10n.authEmailTaken
                      : apiFailureLabel(l10n, state.failure)),
                  backgroundColor: t.dangerSolid));
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
                        title: l10n.authCreateAccountTitle,
                        subtitle: l10n.authCreateAccountSubtitle,
                      ),
                      const SizedBox(height: 22),
                      AppTextField(
                        controller: _nameCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authFullName,
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.authFullNameRequired
                            : null,
                      ),
                      const SizedBox(height: 10),
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
                          return v.contains('@') ? null : l10n.authEmailInvalid;
                        },
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _phoneCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authPhoneOptional,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: _passCtrl,
                        skin: FieldSkin.page,
                        hint: l10n.authPassword,
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
                        validator: (v) => (v == null || v.length < 8)
                            ? l10n.authPasswordMinLength8
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
                      const SizedBox(height: 14),
                      _PrivacyConsent(
                        accepted: _accepted,
                        missing: _acceptedMissing,
                        onChanged: (value) => setState(() {
                          _accepted = value;
                          if (value) _acceptedMissing = false;
                        }),
                      ),
                      const SizedBox(height: 16),
                      AppFilledButton(
                        label: l10n.authSignUp,
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                      const SizedBox(height: 16),
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

/// Apple wants the policy reachable before an account exists, and so does
/// anyone typing their phone number into a stranger's app.
class _PrivacyConsent extends StatelessWidget {
  final bool accepted;
  final bool missing;
  final ValueChanged<bool> onChanged;

  const _PrivacyConsent({
    required this.accepted,
    required this.missing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final base = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.5,
        height: 1.45,
        color: t.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppMetrics.minHitTarget,
              height: AppMetrics.minHitTarget,
              child: Checkbox(
                value: accepted,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: t.primary,
                side: BorderSide(
                    color: missing ? t.dangerBorder : t.border, width: 1.5),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text.rich(
                  TextSpan(
                    text: '${l10n.authAcceptTerms} ',
                    style: base,
                    children: [
                      TextSpan(
                        text: l10n.authPrivacyPolicy,
                        style: base.copyWith(
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(backendPageUrl('/privacy'),
                              mode: LaunchMode.externalApplication),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        if (missing)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: Text(
              l10n.authAcceptTermsRequired,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: base.copyWith(fontSize: 11.5, color: t.dangerText),
            ),
          ),
      ],
    );
  }
}
