import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class DealDetailScreen extends StatefulWidget {
  final int id;
  const DealDetailScreen({super.key, required this.id});
  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  DealResponse? _d;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await Injector.dealsRepository.getDeal(widget.id);
      setState(() {
        _d = d;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(context,
        title: 'Delete Deal', content: 'Delete "${_d!.title}"?');
    if (!ok) return;
    // ignore: use_build_context_synchronously
    context.read<DealsBloc>().add(DealsDeleteEvent(widget.id));
    if (mounted) context.go('/deals');
  }

  void _updateStatus(DealStatus s) {
    context.read<DealsBloc>().add(DealsUpdateStatusEvent(widget.id, s));
    _load();
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _d!.id.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deal ID copied'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(_d?.title ?? 'Deal'),
          actions: _d == null
              ? []
              : [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.go('/deals/${widget.id}/edit')),
                  if (context.isAdmin)
                    IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        onPressed: _delete),
                ]),
      body: _loading
          ? const _DealDetailSkeleton()
          : _d == null
              ? const EmptyState(
                  title: 'Deal not found', icon: Icons.handshake_outlined)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Card(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(children: [
                                Expanded(
                                    child: Text(_d!.title,
                                        style: tt.titleLarge?.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700))),
                                const SizedBox(width: 8),
                                DealStatusChip(status: _d!.status),
                              ]),
                              const SizedBox(height: 10),
                              if (_d!.dealPrice != null)
                                Text(formatPrice(_d!.dealPrice!),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                        fontFamily: 'Sora'))
                              else if (_d!.budget != null)
                                Text('Budget: ${formatPrice(_d!.budget!)}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                        fontFamily: 'Sora')),
                              const SizedBox(height: 14),
                              _IdBadge(
                                  label: 'Deal ID: ${_d!.id}',
                                  color: AppColors.success,
                                  onTap: _copyId),
                            ])),
                        const SizedBox(height: 14),
                        _Card(
                            title: 'Details',
                            icon: Icons.info_outline,
                            child: Wrap(spacing: 20, runSpacing: 12, children: [
                              _Spec(Icons.person_outline, 'Client',
                                  _d!.clientName),
                              _Spec(Icons.support_agent_outlined, 'Agent',
                                  _d!.agentName),
                              if (_d!.propertyTitle != null)
                                _Spec(Icons.home_outlined, 'Property',
                                    _d!.propertyTitle!),
                              if (_d!.dealPrice != null && _d!.budget != null)
                                _Spec(Icons.account_balance_wallet_outlined,
                                    'Budget', formatPrice(_d!.budget!)),
                              if (_d!.createdAt != null)
                                _Spec(Icons.access_time, 'Created',
                                    formatDate(_d!.createdAt!)),
                              if (_d!.closedAt != null)
                                _Spec(Icons.check_circle_outline, 'Closed',
                                    formatDate(_d!.closedAt!)),
                            ])),
                        if (_d!.notes != null && _d!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _Card(
                              title: 'Notes',
                              icon: Icons.notes_outlined,
                              child: Text(_d!.notes!,
                                  style: tt.bodyMedium?.copyWith(
                                      color: tt.bodySmall?.color,
                                      height: 1.6))),
                        ],
                        const SizedBox(height: 14),
                        _Card(
                          title: 'Pipeline Stage',
                          icon: Icons.flag_outlined,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: DealStatus.values.map((s) {
                              final sel = _d!.status == s;
                              return _StatusPill(
                                label: s.name,
                                selected: sel,
                                onTap: sel ? null : () => _updateStatus(s),
                              );
                            }).toList(),
                          ),
                        ),
                      ])),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────

class _DealDetailSkeleton extends StatelessWidget {
  const _DealDetailSkeleton();

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child:
                                ShimmerBox(width: 180, height: 20, radius: 10)),
                        SizedBox(width: 12),
                        ShimmerBox(width: 76, height: 24, radius: 12),
                      ],
                    ),
                    SizedBox(height: 10),
                    ShimmerBox(width: 130, height: 28, radius: 8),
                    SizedBox(height: 14),
                    ShimmerBox(width: 130, height: 32, radius: 8),
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
                    const ShimmerBox(width: 60, height: 14, radius: 7),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: List.generate(
                        5,
                        (_) =>
                            const ShimmerBox(width: 90, height: 14, radius: 7),
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
                    const ShimmerBox(width: 110, height: 14, radius: 7),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        4,
                        (_) =>
                            const ShimmerBox(width: 90, height: 34, radius: 20),
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

class _Card extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  const _Card({this.title, this.icon, required this.child});
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Text(title!,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: cs.primary)),
            ]),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(64))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tag, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Sora')),
            const SizedBox(width: 6),
            Icon(Icons.copy, size: 13, color: color),
          ]),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _StatusPill(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? cs.primary : cs.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? cs.primary : cs.outline.withAlpha(60)),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: cs.primary.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ]
              : null,
        ),
        child: Text(label.replaceAll('_', ' '),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sora',
                color: selected ? Colors.white : cs.onSurfaceVariant)),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Spec(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: tt.labelSmall?.color),
      const SizedBox(width: 4),
      Text('$label: ', style: tt.labelSmall?.copyWith(fontSize: 13)),
      Flexible(
        child: Text(value,
            style: tt.bodyMedium
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}
