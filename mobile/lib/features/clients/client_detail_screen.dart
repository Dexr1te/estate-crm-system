import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_event.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'package:shimmer/shimmer.dart';

class ClientDetailScreen extends StatefulWidget {
  final int id;
  const ClientDetailScreen({super.key, required this.id});
  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientResponse? _client;
  List<DealResponse> _deals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService().getClient(widget.id),
        ApiService().getDeals(),
      ]);
      final client = results[0] as ClientResponse;
      final allDeals = results[1] as List<DealResponse>;
      setState(() {
        _client = client;
        _deals = allDeals.where((d) => d.clientId == widget.id).toList();
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

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _client!.id.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Client ID copied'), duration: Duration(seconds: 1)));
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
          ? const _ClientDetailSkeleton()
          : _client == null
              ? const EmptyState(
                  title: 'Client not found', icon: Icons.person_off_outlined)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile header ──
                        _HeaderCard(
                          child: Row(children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      cs.primary.withAlpha(60),
                                      cs.primary.withAlpha(20)
                                    ]),
                                border: Border.all(color: cs.primary, width: 2),
                              ),
                              child: Center(
                                  child: Text(
                                      _client!.fullName.isNotEmpty
                                          ? _client!.fullName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: cs.primary,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Sora'))),
                            ),
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
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    ClientTypeChip(type: _client!.type),
                                    const SizedBox(width: 8),
                                    _IdBadge(
                                        label: 'ID ${_client!.id}',
                                        color: AppColors.success,
                                        onTap: _copyId),
                                  ]),
                                ])),
                          ]),
                        ),

                        // ── Contact card ──
                        const SizedBox(height: 14),
                        _InfoCard(
                            title: 'Contact',
                            icon: Icons.badge_outlined,
                            rows: [
                              if (_client!.email != null)
                                _InfoRow(Icons.email_outlined, 'Email',
                                    _client!.email!),
                              if (_client!.phone != null)
                                _InfoRow(Icons.phone_outlined, 'Phone',
                                    _client!.phone!),
                              if (_client!.agentName != null)
                                _InfoRow(Icons.person_outlined, 'Agent',
                                    _client!.agentName!),
                            ]),

                        // ── Deals card ──
                        if (_deals.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _HeaderCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.handshake_outlined,
                                      size: 16, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Deals',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: cs.primary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_deals.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                        fontFamily: 'Sora',
                                      ),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                ..._deals.map((deal) => _DealRow(deal: deal)),
                              ],
                            ),
                          ),
                        ],

                        // ── Notes card ──
                        if (_client!.notes != null &&
                            _client!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _InfoCard(
                              title: 'Notes',
                              icon: Icons.notes_outlined,
                              rows: [
                                Text(_client!.notes!,
                                    style: tt.bodyMedium?.copyWith(
                                        color: tt.bodySmall?.color,
                                        height: 1.5)),
                              ]),
                        ],

                        // ── Timestamps card ──
                        if (_client!.createdAt != null) ...[
                          const SizedBox(height: 14),
                          _InfoCard(
                              title: 'Timestamps',
                              icon: Icons.access_time,
                              rows: [
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

// ─── Deal Row ────────────────────────────────────────────────────

class _DealRow extends StatelessWidget {
  final DealResponse deal;
  const _DealRow({required this.deal});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                deal.title,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            DealStatusChip(status: deal.status),
          ]),
          if (deal.propertyTitle != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.home_outlined, size: 13, color: tt.bodySmall?.color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  deal.propertyTitle!,
                  style: tt.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
          if (deal.budget != null || deal.dealPrice != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 13, color: tt.bodySmall?.color),
              const SizedBox(width: 4),
              Text(
                formatPrice((deal.dealPrice ?? deal.budget)!),
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────

class _ClientDetailSkeleton extends StatelessWidget {
  const _ClientDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252A3D) : const Color(0xFFE8ECF4);
    final highlight =
        isDark ? const Color(0xFF353B52) : const Color(0xFFF5F7FC);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    ShimmerBox(width: 60, height: 60, radius: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 160, height: 16, radius: 8),
                          SizedBox(height: 8),
                          ShimmerBox(width: 72, height: 22, radius: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 70, height: 14, radius: 7),
                    const SizedBox(height: 14),
                    ...List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            ShimmerBox(width: 16, height: 16, radius: 4),
                            SizedBox(width: 10),
                            ShimmerBox(width: 55, height: 12, radius: 6),
                            SizedBox(width: 8),
                            ShimmerBox(width: 130, height: 12, radius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      ShimmerBox(width: 50, height: 14, radius: 7),
                      Spacer(),
                      ShimmerBox(width: 24, height: 20, radius: 10),
                    ]),
                    const SizedBox(height: 14),
                    ...List.generate(
                      2,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ShimmerBox(
                            width: double.infinity, height: 70, radius: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final Widget child;
  const _HeaderCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withAlpha(35)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

class _IdBadge extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _IdBadge(
      {required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(64))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tag, size: 12, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Sora')),
            const SizedBox(width: 4),
            Icon(Icons.copy, size: 11, color: color),
          ]),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> rows;
  const _InfoCard(
      {required this.title, required this.icon, required this.rows});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _HeaderCard(
      child: Padding(
        padding: EdgeInsets.zero,
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
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 6),
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
