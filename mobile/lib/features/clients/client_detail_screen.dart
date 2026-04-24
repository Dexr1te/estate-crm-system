import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'clients_bloc.dart';

class ClientDetailScreen extends StatefulWidget {
  final int id;
  const ClientDetailScreen({super.key, required this.id});
  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientResponse? _client;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final c = await ApiService().getClient(widget.id);
      setState(() {
        _client = c;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(context,
        title: 'Delete Client', content: 'Delete "${_client!.fullName}"?');
    if (!ok) return;
    // ignore: use_build_context_synchronously
    context.read<ClientsBloc>().add(ClientsDeleteEvent(widget.id));
    if (mounted) context.go('/clients');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_client?.fullName ?? 'Client'),
        actions: _client == null
            ? []
            : [
                IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.go('/clients/${widget.id}/edit')),
                IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: _delete),
              ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _client == null
              ? const EmptyState(
                  title: 'Client not found', icon: Icons.person_off_outlined)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(children: [
                                  CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          cs.primary.withOpacity(0.1),
                                      child: Text(
                                          _client!.fullName.isNotEmpty
                                              ? _client!.fullName[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: cs.primary,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Sora'))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(_client!.fullName,
                                            style: tt.titleMedium?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        ClientTypeChip(type: _client!.type),
                                      ])),
                                  // ── ID badge (tap to copy) ──
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _client!.id.toString()));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Client ID copied'),
                                              duration: Duration(seconds: 1)));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: cs.primary.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color:
                                                  cs.primary.withOpacity(0.2))),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('ID: ${_client!.id}',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.primary,
                                                    fontFamily: 'Sora')),
                                            const SizedBox(width: 4),
                                            Icon(Icons.copy,
                                                size: 13, color: cs.primary),
                                          ]),
                                    ),
                                  ),
                                ]))),
                        const SizedBox(height: 12),
                        _InfoCard(title: 'Contact', rows: [
                          if (_client!.email != null)
                            _InfoRow(
                                Icons.email_outlined, 'Email', _client!.email!),
                          if (_client!.phone != null)
                            _InfoRow(
                                Icons.phone_outlined, 'Phone', _client!.phone!),
                          if (_client!.agentName != null)
                            _InfoRow(Icons.person_outlined, 'Agent',
                                _client!.agentName!),
                        ]),
                        if (_client!.notes != null &&
                            _client!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Notes',
                                            style: tt.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        const SizedBox(height: 8),
                                        Text(_client!.notes!,
                                            style: tt.bodyMedium?.copyWith(
                                                color: tt.bodySmall?.color,
                                                height: 1.5)),
                                      ]))),
                        ],
                        if (_client!.createdAt != null) ...[
                          const SizedBox(height: 12),
                          _InfoCard(title: 'Timestamps', rows: [
                            _InfoRow(Icons.access_time, 'Created',
                                formatDateTime(_client!.createdAt!)),
                            if (_client!.updatedAt != null)
                              _InfoRow(Icons.update, 'Updated',
                                  formatDateTime(_client!.updatedAt!)),
                          ]),
                        ],
                      ])),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _InfoCard({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: tt.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              ...rows,
            ])));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, size: 16, color: tt.labelSmall?.color),
          const SizedBox(width: 10),
          Text('$label: ',
              style: tt.bodySmall
                  ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
          Flexible(
              child: Text(value,
                  style: tt.bodyMedium
                      ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500))),
        ]));
  }
}
