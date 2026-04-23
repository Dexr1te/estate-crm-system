import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'clients_bloc.dart';

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
    } else {
      context.read<ClientsBloc>().add(ClientsCreateEvent(data));
      // Navigation is handled in the BlocListener below (on ClientCreated)
      return;
    }
    // For update, navigate back immediately
    context.go('/clients');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientsBloc, ClientsState>(
      listener: (context, state) {
        if (state is ClientCreated) {
          // The client was created and we have its id — navigate to clients list
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client created (ID: ${state.client.id})'),
            ),
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit Client' : 'New Client')),
        body: _initLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon:
                                      Icon(Icons.phone_outlined, size: 20))),
                          const SizedBox(height: 20),
                          const Text('Client Type',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          Row(
                              children: ClientType.values
                                  .map((t) => Expanded(
                                          child: Padding(
                                        padding: EdgeInsets.only(
                                            right:
                                                t == ClientType.BUYER ? 8 : 0),
                                        child: InkWell(
                                          onTap: () =>
                                              setState(() => _type = t),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            decoration: BoxDecoration(
                                                color: _type == t
                                                    ? AppColors.primary
                                                    : AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: _type == t
                                                        ? AppColors.primary
                                                        : const Color(
                                                            0xFFE8ECF4))),
                                            child: Center(
                                                child: Text(
                                                    t == ClientType.BUYER
                                                        ? '🏠 Buyer'
                                                        : '💰 Seller',
                                                    style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _type == t
                                                            ? Colors.white
                                                            : AppColors
                                                                .textSecondary,
                                                        fontSize: 14))),
                                          ),
                                        ),
                                      )))
                                  .toList()),
                          const SizedBox(height: 20),
                          TextFormField(
                              controller: _notesCtrl,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                  hintText: 'Additional notes...',
                                  alignLabelWithHint: true)),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
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
                          const SizedBox(height: 12),
                          OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52)),
                              child: const Text('Cancel')),
                        ])),
              ),
      ),
    );
  }
}
