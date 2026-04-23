import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'deals_bloc.dart';

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
      final d = await ApiService().getDeal(widget.id);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(_d?.title ?? 'Deal'),
          actions: _d == null
              ? []
              : [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.go('/deals/${widget.id}/edit')),
                  IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: _delete),
                ]),
      body: _loading
          ? const LoadingWidget()
          : _d == null
              ? const EmptyState(
                  title: 'Deal not found', icon: Icons.handshake_outlined)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(_d!.title,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Sora'))),
                                        DealStatusChip(status: _d!.status)
                                      ]),
                                      const SizedBox(height: 10),
                                      // ── Deal ID badge (tap to copy) ──
                                      GestureDetector(
                                        onTap: _copyId,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.success
                                                      .withOpacity(0.25))),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.tag,
                                                    size: 13,
                                                    color: AppColors.success),
                                                const SizedBox(width: 4),
                                                Text('Deal ID: ${_d!.id}',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.success,
                                                        fontFamily: 'Sora')),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.copy,
                                                    size: 13,
                                                    color: AppColors.success),
                                              ]),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_d!.dealPrice != null)
                                        _Row(Icons.attach_money, 'Deal Price',
                                            formatPrice(_d!.dealPrice!),
                                            color: AppColors.success),
                                      if (_d!.budget != null)
                                        _Row(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            'Budget',
                                            formatPrice(_d!.budget!)),
                                      _Row(Icons.person_outline, 'Client',
                                          _d!.clientName),
                                      _Row(Icons.support_agent_outlined,
                                          'Agent', _d!.agentName),
                                      if (_d!.propertyTitle != null)
                                        _Row(Icons.home_outlined, 'Property',
                                            _d!.propertyTitle!),
                                      if (_d!.createdAt != null)
                                        _Row(Icons.access_time, 'Created',
                                            formatDate(_d!.createdAt!)),
                                      if (_d!.closedAt != null)
                                        _Row(
                                            Icons.check_circle_outline,
                                            'Closed',
                                            formatDate(_d!.closedAt!)),
                                    ]))),
                        if (_d!.notes != null && _d!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Notes',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        const SizedBox(height: 8),
                                        Text(_d!.notes!,
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                height: 1.6)),
                                      ]))),
                        ],
                        const SizedBox(height: 12),
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Pipeline Stage',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 12),
                                      Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: DealStatus.values.map((s) {
                                            final sel = _d!.status == s;
                                            return ChoiceChip(
                                                label: Text(
                                                    s.name.replaceAll('_', ' '),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Sora')),
                                                selected: sel,
                                                onSelected: sel
                                                    ? null
                                                    : (_) => _updateStatus(s),
                                                selectedColor:
                                                    AppColors.primary,
                                                labelStyle: TextStyle(
                                                    color: sel
                                                        ? Colors.white
                                                        : AppColors.textPrimary,
                                                    fontWeight:
                                                        FontWeight.w600));
                                          }).toList()),
                                    ]))),
                      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? color;
  const _Row(this.icon, this.label, this.value, {this.color});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        Flexible(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color ?? AppColors.textPrimary)))
      ]));
}
