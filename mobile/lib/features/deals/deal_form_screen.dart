import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'deals_bloc.dart';

// ─────────────────────────────────────────────────────────────
// Generic picker helpers
// ─────────────────────────────────────────────────────────────

class _PickerItem {
  final int id;
  final String title;
  final String? subtitle;
  const _PickerItem({required this.id, required this.title, this.subtitle});
}

Future<_PickerItem?> _showPicker(
  BuildContext context, {
  required String label,
  required List<_PickerItem> items,
  int? selectedId,
}) =>
    showModalBottomSheet<_PickerItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PickerSheet(label: label, items: items, selectedId: selectedId),
    );

class _PickerSheet extends StatefulWidget {
  final String label;
  final List<_PickerItem> items;
  final int? selectedId;
  const _PickerSheet(
      {required this.label, required this.items, required this.selectedId});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late List<_PickerItem> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((i) =>
                  i.title.toLowerCase().contains(q) ||
                  (i.subtitle?.toLowerCase().contains(q) ?? false) ||
                  i.id.toString().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text('Select ${widget.label}',
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name or ID…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchCtrl.clear())
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('No results',
                          style: tt.bodyMedium?.copyWith(color: cs.outline)))
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final item = _filtered[i];
                        final selected = item.id == widget.selectedId;
                        return ListTile(
                          onTap: () => Navigator.pop(context, item),
                          selected: selected,
                          selectedTileColor: cs.primary.withAlpha(20),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: selected
                                ? cs.primary
                                : cs.surfaceContainerHighest,
                            child: Text('#${item.id}',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? cs.onPrimary
                                        : cs.onSurfaceVariant)),
                          ),
                          title: Text(item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: item.subtitle != null
                              ? Text(item.subtitle!,
                                  style: TextStyle(
                                      fontSize: 12, color: cs.outline))
                              : null,
                          trailing: selected
                              ? Icon(Icons.check_circle,
                                  color: cs.primary, size: 20)
                              : null,
                        );
                      },
                    ),
            ),
            SizedBox(height: mq.viewInsets.bottom + 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Entity selector tile
// ─────────────────────────────────────────────────────────────

class _EntityTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final _PickerItem? selected;
  final bool loading;
  final String? error;
  final bool required;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _EntityTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.loading,
    required this.onTap,
    this.error,
    this.required = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${required ? ' *' : ''}',
          style: tt.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? cs.error : cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? cs.error
                    : selected != null
                        ? cs.primary.withAlpha(180)
                        : cs.outline.withAlpha(120),
                width: selected != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selected != null
                  ? cs.primary.withAlpha(12)
                  : cs.surfaceContainerLowest,
            ),
            child: loading
                ? Row(children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: cs.outline)),
                    const SizedBox(width: 12),
                    Text('Loading…',
                        style: TextStyle(color: cs.outline, fontSize: 14)),
                  ])
                : Row(children: [
                    Icon(icon,
                        size: 20,
                        color: selected != null
                            ? cs.primary
                            : cs.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: selected == null
                          ? Text('Tap to select $label',
                              style: TextStyle(color: cs.outline, fontSize: 14))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selected!.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                if (selected!.subtitle != null)
                                  Text(selected!.subtitle!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant)),
                              ],
                            ),
                    ),
                    if (selected != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('#${selected!.id}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary)),
                      ),
                      if (onClear != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onClear,
                          child: Icon(Icons.close, size: 16, color: cs.outline),
                        ),
                      ],
                    ] else
                      Icon(Icons.keyboard_arrow_down,
                          color: cs.outline, size: 20),
                  ]),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child:
                Text(error!, style: TextStyle(fontSize: 12, color: cs.error)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────

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

  DealStatus _status = DealStatus.LEAD;
  bool _loading = false, _initLoading = false;

  List<_PickerItem> _clients = [];
  List<_PickerItem> _agents = []; // ✅ real agents from GET /users/agents
  List<_PickerItem> _properties = [];
  bool _clientsLoading = true, _agentsLoading = true, _propertiesLoading = true;

  _PickerItem? _selectedClient;
  _PickerItem? _selectedAgent;
  _PickerItem? _selectedProperty;

  String? _clientError;
  String? _agentError;

  @override
  void initState() {
    super.initState();
    _loadLists();
    if (widget.isEditing) _loadDeal();
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _priceCtrl, _budgetCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLists() async {
    _loadClients();
    _loadAgents();
    _loadProperties();
  }

  Future<void> _loadClients() async {
    try {
      final data = await ApiService().getClients();
      if (!mounted) return;
      setState(() {
        _clients = data
            .map((c) => _PickerItem(
                id: c.id, title: c.fullName, subtitle: c.email ?? c.phone))
            .toList();
        _clientsLoading = false;
        _resolve(_clients, _selectedClient, (v) => _selectedClient = v);
      });
    } catch (_) {
      if (mounted) setState(() => _clientsLoading = false);
    }
  }

  Future<void> _loadAgents() async {
    try {
      // ✅ GET /users/agents — agents only, not clients
      final data = await ApiService().getAgentOptions();
      if (!mounted) return;
      setState(() {
        _agents = data
            .map((a) =>
                _PickerItem(id: a.id, title: a.fullName, subtitle: a.email))
            .toList();
        _agentsLoading = false;
        _resolve(_agents, _selectedAgent, (v) => _selectedAgent = v);
      });
    } catch (_) {
      if (mounted) setState(() => _agentsLoading = false);
    }
  }

  Future<void> _loadProperties() async {
    try {
      final data = await ApiService().getProperties();
      if (!mounted) return;
      setState(() {
        _properties = data
            .map((p) => _PickerItem(
                id: p.id,
                title: p.title,
                subtitle: [
                  if (p.city != null) p.city,
                  '\$${p.price.toStringAsFixed(0)}',
                ].join(' · ')))
            .toList();
        _propertiesLoading = false;
        _resolve(_properties, _selectedProperty, (v) => _selectedProperty = v);
      });
    } catch (_) {
      if (mounted) setState(() => _propertiesLoading = false);
    }
  }

  void _resolve(List<_PickerItem> list, _PickerItem? current,
      void Function(_PickerItem?) setter) {
    if (current == null) return;
    final match = list
        .cast<_PickerItem?>()
        .firstWhere((i) => i?.id == current.id, orElse: () => current);
    setter(match);
  }

  Future<void> _loadDeal() async {
    setState(() => _initLoading = true);
    try {
      final d = await ApiService().getDeal(widget.dealId!);
      _titleCtrl.text = d.title;
      _priceCtrl.text = d.dealPrice?.toStringAsFixed(0) ?? '';
      _budgetCtrl.text = d.budget?.toStringAsFixed(0) ?? '';
      _notesCtrl.text = d.notes ?? '';
      setState(() {
        _selectedClient =
            _PickerItem(id: d.clientId, title: 'Client #${d.clientId}');
        _selectedAgent =
            _PickerItem(id: d.agentId, title: 'Agent #${d.agentId}');
        if (d.propertyId != null) {
          _selectedProperty = _PickerItem(
              id: d.propertyId!, title: 'Property #${d.propertyId}');
        }
        _status = d.status;
        _initLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initLoading = false);
    }
  }

  Future<void> _pickClient() async {
    final r = await _showPicker(context,
        label: 'Client', items: _clients, selectedId: _selectedClient?.id);
    if (r != null) {
      setState(() {
        _selectedClient = r;
        _clientError = null;
      });
    }
  }

  Future<void> _pickAgent() async {
    final r = await _showPicker(context,
        label: 'Agent', items: _agents, selectedId: _selectedAgent?.id);
    if (r != null) {
      setState(() {
        _selectedAgent = r;
        _agentError = null;
      });
    }
  }

  Future<void> _pickProperty() async {
    final r = await _showPicker(context,
        label: 'Property',
        items: _properties,
        selectedId: _selectedProperty?.id);
    if (r != null) setState(() => _selectedProperty = r);
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _clientError = _selectedClient == null ? 'Please select a client' : null;
      _agentError = _selectedAgent == null ? 'Please select an agent' : null;
    });
    if (!formValid || _selectedClient == null || _selectedAgent == null) return;

    setState(() => _loading = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'status': _status.name,
      'clientId': _selectedClient!.id,
      'agentId': _selectedAgent!.id,
      if (_priceCtrl.text.trim().isNotEmpty)
        'dealPrice': double.parse(_priceCtrl.text.trim()),
      if (_budgetCtrl.text.trim().isNotEmpty)
        'budget': double.parse(_budgetCtrl.text.trim()),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_selectedProperty != null) 'propertyId': _selectedProperty!.id,
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
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Title *',
                          prefixIcon: Icon(Icons.title, size: 20)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 20),
                    _EntityTile(
                      label: 'Client',
                      icon: Icons.person_outline,
                      selected: _selectedClient,
                      loading: _clientsLoading,
                      required: true,
                      error: _clientError,
                      onTap: _pickClient,
                    ),
                    const SizedBox(height: 16),
                    _EntityTile(
                      label: 'Agent',
                      icon: Icons.support_agent_outlined,
                      selected: _selectedAgent,
                      loading: _agentsLoading,
                      required: true,
                      error: _agentError,
                      onTap: _pickAgent,
                    ),
                    const SizedBox(height: 16),
                    _EntityTile(
                      label: 'Property',
                      icon: Icons.home_outlined,
                      selected: _selectedProperty,
                      loading: _propertiesLoading,
                      onTap: _pickProperty,
                      onClear: _selectedProperty != null
                          ? () => setState(() => _selectedProperty = null)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Deal Price',
                              prefixIcon: Icon(Icons.attach_money, size: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _budgetCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Budget',
                              prefixIcon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 20)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Text('Status',
                        style: tt.labelMedium?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: DealStatus.values
                          .map((s) => ChoiceChip(
                                label: Text(s.name.replaceAll('_', ' '),
                                    style: const TextStyle(fontSize: 12)),
                                selected: _status == s,
                                onSelected: (_) => setState(() => _status = s),
                                selectedColor: cs.primary.withAlpha(38),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.notes_outlined, size: 20)),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              widget.isEditing ? 'Update Deal' : 'Create Deal'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52)),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
