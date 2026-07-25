import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
        },
        builder: (ctx, state) {
          final loading = state is AuthLoading;
          return Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.home_work,
                                  color: Colors.white, size: 26)),
                          const SizedBox(height: 28),
                          Text(l10n.authWelcomeBack,
                              style: tt.titleLarge?.copyWith(
                                  fontSize: 28, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(l10n.authSignInSubtitle,
                              style: tt.bodySmall?.copyWith(fontSize: 15)),
                          const SizedBox(height: 36),
                          Form(
                              key: _formKey,
                              child: Column(children: [
                                TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        labelText: l10n.authEmail,
                                        prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            size: 20)),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return l10n.authEmailRequired;
                                      }
                                      if (!v.contains('@')) {
                                        return l10n.authEmailInvalid;
                                      }
                                      return null;
                                    }),
                                const SizedBox(height: 16),
                                TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                        labelText: l10n.authPassword,
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            size: 20),
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                                _obscure
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                size: 20),
                                            onPressed: () => setState(
                                                () => _obscure = !_obscure))),
                                    validator: (v) => v == null || v.isEmpty
                                        ? l10n.authPasswordRequired
                                        : null,
                                    onFieldSubmitted: (_) => _submit()),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                    onPressed: loading ? null : _submit,
                                    child: loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                        : Text(l10n.authSignIn)),
                                const SizedBox(height: 4),
                                TextButton(
                                    onPressed: loading
                                        ? null
                                        : () => ctx.go('/accept-invite'),
                                    child: Text(l10n.authHaveAnInvite)),
                              ])),
                        ]),
                  )));
        },
      )),
    );
  }
}
