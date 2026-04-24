import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'deals_bloc.dart';

class DealFormScreen extends StatefulWidget {
  final int? dealId;
  const DealFormScreen({super.key, this.dealId});
  bool get isEditing => dealId != null;
  @override
  State<DealFormScreen> createState() => _DealFormScreenState();
}

class _DealFormScreenState extends State<DealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();
  final _propertyIdCtrl = TextEditingController();
  final _agentIdCtrl = TextEditingController();
  DealStatus _status = DealStatus.LEAD;
  bool _loading = false, _initLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _load();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _priceCtrl,
      _budgetCtrl,
      _notesCtrl,
      _clientIdCtrl,
      _propertyIdCtrl,
      _agentIdCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final d = await ApiService().getDeal(widget.dealId!);
      _titleCtrl.text = d.title;
      _priceCtrl.text = d.dealPrice?.toStringAsFixed(0) ?? '';
      _budgetCtrl.text = d.budget?.toStringAsFixed(0) ?? '';
      _notesCtrl.text = d.notes ?? '';
      _clientIdCtrl.text = d.clientId.toString();
      _propertyIdCtrl.text = d.propertyId?.toString() ?? '';
      _agentIdCtrl.text = d.agentId.toString();
      setState(() {
        _status = d.status;
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
      'title': _titleCtrl.text.trim(),
      'status': _status.name,
      'clientId': int.parse(_clientIdCtrl.text.trim()),
      'agentId': int.parse(_agentIdCtrl.text.trim()),
      if (_priceCtrl.text.trim().isNotEmpty)
        'dealPrice': double.parse(_priceCtrl.text.trim()),
      if (_budgetCtrl.text.trim().isNotEmpty)
        'budget': double.parse(_budgetCtrl.text.trim()),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_propertyIdCtrl.text.trim().isNotEmpty)
        'propertyId': int.parse(_propertyIdCtrl.text.trim()),
    };
    if (widget.isEditing) {
      context.read<DealsBloc>().add(DealsUpdateEvent(widget.dealId!, data));
    } else {
      context.read<DealsBloc>().add(DealsCreateEvent(data));
    }
    context.go('/deals');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Deal' : 'New Deal')),
      body: _initLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _f(_titleCtrl, 'Title *', Icons.title, req: true),
                        const SizedBox(height: 12),
                        _f(_clientIdCtrl, 'Client ID *', Icons.person_outline,
                            req: true, num: true),
                        const SizedBox(height: 12),
                        _f(_agentIdCtrl, 'Agent ID *',
                            Icons.support_agent_outlined,
                            req: true, num: true),
                        const SizedBox(height: 12),
                        _f(_propertyIdCtrl, 'Property ID (optional)',
                            Icons.home_outlined,
                            num: true),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: _f(
                                  _priceCtrl, 'Deal Price', Icons.attach_money,
                                  num: true)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _f(_budgetCtrl, 'Budget',
                                  Icons.account_balance_wallet_outlined,
                                  num: true))
                        ]),
                        const SizedBox(height: 16),
                        Text('Status',
                            style: tt.labelMedium?.copyWith(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            children: DealStatus.values
                                .map((s) => ChoiceChip(
                                    label: Text(s.name.replaceAll('_', ' '),
                                        style: const TextStyle(fontSize: 12)),
                                    selected: _status == s,
                                    onSelected: (_) =>
                                        setState(() => _status = s),
                                    selectedColor:
                                        cs.primary.withOpacity(0.15)))
                                .toList()),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _notesCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                labelText: 'Notes',
                                prefixIcon:
                                    Icon(Icons.notes_outlined, size: 20))),
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
                                    ? 'Update Deal'
                                    : 'Create Deal')),
                        const SizedBox(height: 12),
                        OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52)),
                            child: const Text('Cancel')),
                      ]))),
    );
  }

  Widget _f(TextEditingController c, String label, IconData icon,
          {bool req = false, bool num = false}) =>
      TextFormField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
        validator: req
            ? (v) => v == null || v.isEmpty ? '$label is required' : null
            : null,
      );
}
