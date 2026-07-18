import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

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
            fontSize: 12,
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

// ─────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────

class MeetingFormScreen extends StatefulWidget {
  final int? meetingId;
  const MeetingFormScreen({super.key, this.meetingId});
  bool get isEditing => meetingId != null;

  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _scheduledAt;
  bool _loading = false, _initLoading = false;

  List<_PickerItem> _clients = [];
  List<_PickerItem> _agents = []; // ✅ real agents from GET /users/agents
  List<_PickerItem> _deals = [];
  bool _clientsLoading = true, _agentsLoading = true, _dealsLoading = true;

  _PickerItem? _selectedClient;
  _PickerItem? _selectedAgent;
  _PickerItem? _selectedDeal;

  String? _clientError;
  String? _agentError;

  @override
  void initState() {
    super.initState();
    _loadLists();
    if (widget.isEditing) _loadMeeting();
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _locationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLists() async {
    _loadClients();
    _loadAgents();
    _loadDeals();
  }

  Future<void> _loadClients() async {
    try {
      final data = await Injector.clientsRepository.getClients();
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
      final data = await Injector.agentsRepository.getAgentOptions();
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

  Future<void> _loadDeals() async {
    try {
      final data = await Injector.dealsRepository.getDeals();
      if (!mounted) return;
      setState(() {
        _deals = data
            .map((d) => _PickerItem(
                id: d.id,
                title: d.title,
                subtitle: d.status.name.replaceAll('_', ' ')))
            .toList();
        _dealsLoading = false;
        _resolve(_deals, _selectedDeal, (v) => _selectedDeal = v);
      });
    } catch (_) {
      if (mounted) setState(() => _dealsLoading = false);
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

  Future<void> _loadMeeting() async {
    setState(() => _initLoading = true);
    try {
      final m = await Injector.meetingsRepository.getMeeting(widget.meetingId!);
      _titleCtrl.text = m.title;
      _descCtrl.text = m.description ?? '';
      _locationCtrl.text = m.location ?? '';
      setState(() {
        _scheduledAt = m.scheduledAt;
        _selectedClient =
            _PickerItem(id: m.clientId, title: 'Client #${m.clientId}');
        _selectedAgent =
            _PickerItem(id: m.agentId, title: 'Agent #${m.agentId}');
        if (m.dealId != null) {
          _selectedDeal =
              _PickerItem(id: m.dealId!, title: 'Deal #${m.dealId}');
        }
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

  Future<void> _pickDeal() async {
    final r = await _showPicker(context,
        label: 'Deal', items: _deals, selectedId: _selectedDeal?.id);
    if (r != null) setState(() => _selectedDeal = r);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
        context: context,
        initialDate:
            _scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? DateTime.now()));
    if (time == null) return;
    setState(() => _scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _clientError = _selectedClient == null ? 'Please select a client' : null;
      _agentError = _selectedAgent == null ? 'Please select an agent' : null;
    });
    if (!formValid || _selectedClient == null || _selectedAgent == null) return;
    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')));
      return;
    }

    setState(() => _loading = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'scheduledAt': _scheduledAt!.toIso8601String(),
      'clientId': _selectedClient!.id,
      'agentId': _selectedAgent!.id,
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_selectedDeal != null) 'dealId': _selectedDeal!.id,
    };

    if (widget.isEditing) {
      context
          .read<MeetingsBloc>()
          .add(MeetingsUpdateEvent(widget.meetingId!, data));
    } else {
      context.read<MeetingsBloc>().add(MeetingsCreateEvent(data));
    }
    context.go('/meetings');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickerBorder =
        isDark ? AppColors.darkBorder : const Color(0xFFE8ECF4);
    final pickerTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final pickerHintColor =
        isDark ? AppColors.darkTextHint : AppColors.textHint;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Meeting' : 'Schedule Meeting')),
      body: _initLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormSectionCard(
                      title: 'Details',
                      icon: Icons.event_note_outlined,
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Title *',
                              prefixIcon: Icon(Icons.title, size: 20)),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Location',
                              prefixIcon:
                                  Icon(Icons.location_on_outlined, size: 20)),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: _pickDateTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                                color: _scheduledAt != null
                                    ? cs.primary.withAlpha(12)
                                    : cs.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _scheduledAt != null
                                        ? cs.primary.withAlpha(180)
                                        : pickerBorder)),
                            child: Row(children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 20,
                                  color: _scheduledAt != null
                                      ? cs.primary
                                      : pickerTextColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _scheduledAt != null
                                      ? DateFormat('MMM d, yyyy • h:mm a')
                                          .format(_scheduledAt!)
                                      : 'Select date & time *',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _scheduledAt != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _scheduledAt != null
                                          ? (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary)
                                          : pickerHintColor),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: pickerHintColor, size: 20),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSectionCard(
                      title: 'People & Deal',
                      icon: Icons.groups_outlined,
                      children: [
                        _EntityTile(
                          label: 'Client',
                          icon: Icons.person_outline,
                          selected: _selectedClient,
                          loading: _clientsLoading,
                          required: true,
                          error: _clientError,
                          onTap: _pickClient,
                        ),
                        const SizedBox(height: 14),
                        _EntityTile(
                          label: 'Agent',
                          icon: Icons.support_agent_outlined,
                          selected: _selectedAgent,
                          loading: _agentsLoading,
                          required: true,
                          error: _agentError,
                          onTap: _pickAgent,
                        ),
                        const SizedBox(height: 14),
                        _EntityTile(
                          label: 'Deal',
                          icon: Icons.handshake_outlined,
                          selected: _selectedDeal,
                          loading: _dealsLoading,
                          onTap: _pickDeal,
                          onClear: _selectedDeal != null
                              ? () => setState(() => _selectedDeal = null)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormSectionCard(
                      title: 'Description',
                      icon: Icons.notes_outlined,
                      children: [
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Meeting agenda, talking points…'),
                        ),
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
                              ? 'Update Meeting'
                              : 'Schedule Meeting'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
