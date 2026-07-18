import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_state.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';

class ClientFormScreen extends StatefulWidget {
  final int? clientId;
  const ClientFormScreen({super.key, this.clientId});
  bool get isEditing => clientId != null;
  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ClientType _type = ClientType.BUYER;
  bool _loading = false, _initLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _load();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final c = await ApiService().getClient(widget.clientId!);
      _nameCtrl.text = c.fullName;
      _emailCtrl.text = c.email ?? '';
      _phoneCtrl.text = c.phone ?? '';
      _notesCtrl.text = c.notes ?? '';
      setState(() {
        _type = c.type;
        _initLoading = false;
      });
    } catch (_) {
      setState(() => _initLoading = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'fullName': _nameCtrl.text.trim(),
      if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
      if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      'type': _type.name,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };
    if (widget.isEditing) {
      context
          .read<ClientsBloc>()
          .add(ClientsUpdateEvent(widget.clientId!, data));
      context.go('/clients');
    } else {
      context.read<ClientsBloc>().add(ClientsCreateEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final unselectedBorder =
        isDark ? AppColors.darkBorder : const Color(0xFFE8ECF4);
    final unselectedText =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocListener<ClientsBloc, ClientsState>(
      listener: (context, state) {
        if (state is ClientCreated) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Client created (ID: ${state.client.id})')),
          );
          context.go('/clients');
        }
        if (state is ClientsError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
        if (state is ClientsActionSuccess) {
          setState(() => _loading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit Client' : 'New Client')),
        body: _initLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Client type banner ──────────────────
                      Text('Client Type',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Row(
                          children: ClientType.values
                              .map((t) => Expanded(
                                      child: Padding(
                                    padding: EdgeInsets.only(
                                        right: t == ClientType.BUYER ? 10 : 0),
                                    child: InkWell(
                                      onTap: () => setState(() => _type = t),
                                      borderRadius: BorderRadius.circular(14),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: _type == t
                                              ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                      cs.primary,
                                                      cs.primary.withAlpha(210),
                                                    ])
                                              : null,
                                          color:
                                              _type == t ? null : unselectedBg,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                              color: _type == t
                                                  ? cs.primary
                                                  : unselectedBorder),
                                          boxShadow: _type == t
                                              ? [
                                                  BoxShadow(
                                                      color: cs.primary
                                                          .withAlpha(60),
                                                      blurRadius: 12,
                                                      offset:
                                                          const Offset(0, 4)),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                            child: Text(
                                                t == ClientType.BUYER
                                                    ? '🏠 Buyer'
                                                    : '💰 Seller',
                                                style: TextStyle(
                                                    fontFamily: 'Sora',
                                                    fontWeight: FontWeight.w600,
                                                    color: _type == t
                                                        ? Colors.white
                                                        : unselectedText,
                                                    fontSize: 14))),
                                      ),
                                    ),
                                  )))
                              .toList()),
                      const SizedBox(height: 24),

                      // ── Contact info section ────────────────
                      _FormSectionCard(
                        title: 'Contact Info',
                        icon: Icons.badge_outlined,
                        children: [
                          TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Full Name *',
                                  prefixIcon:
                                      Icon(Icons.person_outline, size: 20)),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Name is required'
                                  : null),
                          const SizedBox(height: 14),
                          TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon:
                                      Icon(Icons.email_outlined, size: 20)),
                              validator: (v) {
                                if (v != null &&
                                    v.isNotEmpty &&
                                    !v.contains('@')) {
                                  return 'Invalid email';
                                }
                                return null;
                              }),
                          const SizedBox(height: 14),
                          TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon:
                                      Icon(Icons.phone_outlined, size: 20))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Notes section ────────────────────────
                      _FormSectionCard(
                        title: 'Notes',
                        icon: Icons.notes_outlined,
                        children: [
                          TextFormField(
                              controller: _notesCtrl,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'Additional notes about this client…',
                                  isCollapsed: false)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(widget.isEditing
                                ? 'Update Client'
                                : 'Create Client'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: const Text('Cancel')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Reusable section card ─────────────────────────────────────

class _FormSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _FormSectionCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withAlpha(35)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: cs.primary)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
