import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

/// Where an invited user redeems their invite code and sets a password. On
/// success the backend returns a full session, so the router redirect moves
/// them straight into the app.
class AcceptInviteScreen extends StatefulWidget {
  /// Optional token to pre-fill (e.g. from a deep link).
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
            // On AuthAuthenticated the GoRouter redirect handles navigation.
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
                        child: const Icon(Icons.vpn_key_outlined,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 28),
                      Text('Accept your invite',
                          style: tt.titleLarge?.copyWith(
                              fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Enter the invite code you were given and choose a '
                          'password.',
                          style: tt.bodySmall?.copyWith(fontSize: 15)),
                      const SizedBox(height: 36),
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            controller: _tokenCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Invite code',
                                prefixIcon:
                                    Icon(Icons.confirmation_number_outlined,
                                        size: 20)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Invite code is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'New password',
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'At least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscure,
                            decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon:
                                    Icon(Icons.lock_outline, size: 20)),
                            validator: (v) => v != _passCtrl.text
                                ? 'Passwords do not match'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Set password & continue'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                loading ? null : () => ctx.go('/login'),
                            child: const Text('Back to sign in'),
                          ),
                        ]),
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
