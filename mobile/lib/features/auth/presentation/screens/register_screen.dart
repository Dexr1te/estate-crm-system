import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Role _role = Role.AGENT;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterEvent(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          role: _role,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        Text('Create account',
                            style: tt.titleLarge?.copyWith(
                                fontSize: 28, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Start managing properties today',
                            style: tt.bodySmall?.copyWith(fontSize: 15)),
                        const SizedBox(height: 36),
                        Form(
                            key: _formKey,
                            child: Column(children: [
                              TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon:
                                          Icon(Icons.person_outline, size: 20)),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Name is required'
                                      : null),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon:
                                          Icon(Icons.email_outlined, size: 20)),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  }),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                      labelText: 'Phone (optional)',
                                      prefixIcon: Icon(Icons.phone_outlined,
                                          size: 20))),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock_outline,
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (v.length < 6) return 'Min 6 characters';
                                    return null;
                                  }),
                              const SizedBox(height: 12),
                              // ── Role picker ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : const Color(0xFFE8ECF4))),
                                child: Row(children: [
                                  Icon(Icons.badge_outlined,
                                      size: 20, color: tt.bodySmall?.color),
                                  const SizedBox(width: 12),
                                  Text('Role', style: tt.bodySmall),
                                  const Spacer(),
                                  DropdownButtonHideUnderline(
                                      child: DropdownButton<Role>(
                                    value: _role,
                                    dropdownColor: isDark
                                        ? AppColors.darkSurface
                                        : AppColors.surface,
                                    style: tt.bodyMedium?.copyWith(
                                        fontFamily: 'Sora', fontSize: 14),
                                    onChanged: (r) =>
                                        setState(() => _role = r!),
                                    items: Role.values
                                        .map((r) => DropdownMenuItem(
                                            value: r, child: Text(r.name)))
                                        .toList(),
                                  )),
                                ]),
                              ),
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
                                      : const Text('Create Account')),
                            ])),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: tt.bodySmall),
                              TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text('Sign In')),
                            ]),
                      ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
