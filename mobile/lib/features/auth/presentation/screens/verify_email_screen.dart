import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The six digits that prove the address belongs to whoever signed up.
class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _length = 6;
  static const _cooldown = 60;

  final _codeCtrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = _cooldown;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    // The code screen exists to be typed into; nothing else on it takes input.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _submit() {
    final code = _codeCtrl.text.trim();
    if (code.length != _length) return;
    context.read<AuthBloc>().add(AuthVerifyEmailEvent(widget.email, code));
  }

  void _onChanged(String value) {
    setState(() {});
    // Six digits are the whole form: asking for a button press afterwards is a
    // step with nothing left to decide.
    if (value.trim().length == _length) _submit();
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
            showActionOutcome(ctx, state);
            if (state is AuthCodeResent) {
              _startCooldown();
              return;
            }
            if (state is AuthError) {
              // The code stays on screen so a mistyped digit can be corrected
              // rather than retyped from scratch.
              _codeCtrl.selection = TextSelection(
                  baseOffset: 0, extentOffset: _codeCtrl.text.length);
              _focus.requestFocus();
              ScaffoldMessenger.of(ctx)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(apiFailureLabel(l10n, state.failure)),
                    backgroundColor: t.dangerSolid));
            }
          },
          builder: (ctx, state) {
            final loading = state is AuthLoading;
            final complete = _codeCtrl.text.trim().length == _length;
            return AppMetrics.constrain(
              CenteredScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 22),
                    AuthTitle(
                      title: l10n.authVerifyEmailTitle,
                      subtitle: l10n.authVerifyEmailSubtitle(widget.email),
                    ),
                    const SizedBox(height: 26),
                    _CodeField(
                      controller: _codeCtrl,
                      focusNode: _focus,
                      length: _length,
                      enabled: !loading,
                      onChanged: _onChanged,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 18),
                    AppFilledButton(
                      label: l10n.authVerify,
                      loading: loading,
                      onPressed: loading || !complete ? null : _submit,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: AuthTextLink(
                        label: _secondsLeft > 0
                            ? l10n.authResendCodeIn(_secondsLeft)
                            : l10n.authResendCode,
                        onTap: _secondsLeft > 0 || loading
                            ? null
                            : () => ctx
                                .read<AuthBloc>()
                                .add(AuthResendCodeEvent(widget.email)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: AuthTextLink(
                        label: l10n.authChangeEmail,
                        onTap: loading ? null : () => ctx.go('/register'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Six boxes over one field.
///
/// One real [TextField] rather than six: six fields mean six focus nodes, six
/// backspace edge cases, and an autofilled code that lands in the first box.
class _CodeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final digits = controller.text.trim();

    return Stack(
      children: [
        // The field itself carries the keyboard, the autofill and the caret
        // behaviour; it is invisible, and the boxes below are what is read.
        SizedBox(
          height: 58,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofillHints: const [AutofillHints.oneTimeCode],
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
        ),
        IgnorePointer(
          child: Row(
            children: [
              for (var i = 0; i < length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
                      border: Border.all(
                        color: i == digits.length && focusNode.hasFocus
                            ? t.primary
                            : t.border,
                        width: i == digits.length && focusNode.hasFocus
                            ? 1.5
                            : AppMetrics.borderWidth,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      i < digits.length ? digits[i] : '',
                      maxLines: 1,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
