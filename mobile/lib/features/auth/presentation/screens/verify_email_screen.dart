import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  static const _cooldown = 60;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (context.read<AuthBloc>().state is! AuthLinkFailed) _startCooldown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context
          .read<AuthBloc>()
          .add(AuthConfirmEmailEvent(widget.email, silent: true));
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            showActionOutcome(ctx, state);
            if (state is AuthLinkResent) _startCooldown();
          },
          builder: (ctx, state) {
            final checking = state is AuthVerificationChecking;
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
                    AppFilledButton(
                      label: l10n.authVerifyEmailOpened,
                      loading: checking,
                      onPressed: checking
                          ? null
                          : () => ctx
                              .read<AuthBloc>()
                              .add(AuthConfirmEmailEvent(widget.email)),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: AuthTextLink(
                        label: _secondsLeft > 0
                            ? l10n.authResendLinkIn(_secondsLeft)
                            : l10n.authResendLink,
                        onTap: _secondsLeft > 0 || checking
                            ? null
                            : () => ctx
                                .read<AuthBloc>()
                                .add(AuthResendLinkEvent(widget.email)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: AuthTextLink(
                        label: l10n.authChangeEmail,
                        onTap: checking ? null : () => ctx.go('/register'),
                      ),
                    ),
                    Center(
                      child: AuthTextLink(
                        label: l10n.authBackToSignIn,
                        onTap: checking ? null : () => ctx.go('/login'),
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
