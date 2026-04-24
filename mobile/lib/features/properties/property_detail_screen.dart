import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'properties_bloc.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int id;
  const PropertyDetailScreen({super.key, required this.id});
  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  PropertyResponse? _p;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ApiService().getProperty(widget.id);
      setState(() {
        _p = p;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(context,
        title: 'Delete Property', content: 'Delete "${_p!.title}"?');
    if (!ok) return;
    context.read<PropertiesBloc>().add(PropertiesDeleteEvent(widget.id));
    if (mounted) context.go('/properties');
  }

  void _updateStatus(PropertyStatus s) {
    context
        .read<PropertiesBloc>()
        .add(PropertiesUpdateStatusEvent(widget.id, s));
    _load();
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _p!.id.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Property ID copied'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(_p?.title ?? 'Property'),
          actions: _p == null
              ? []
              : [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.go('/properties/${widget.id}/edit')),
                  IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error),
                      onPressed: _delete),
                ]),
      body: _loading
          ? const LoadingWidget()
          : _p == null
              ? const EmptyState(
                  title: 'Property not found', icon: Icons.home_work_outlined)
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
                                            child: Text(_p!.title,
                                                style: tt.titleLarge?.copyWith(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w700))),
                                        PropertyStatusChip(status: _p!.status),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(formatPrice(_p!.price),
                                          style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              color: cs.primary,
                                              fontFamily: 'Sora')),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 15,
                                            color: tt.labelSmall?.color),
                                        const SizedBox(width: 4),
                                        Flexible(
                                            child: Text(_p!.address,
                                                style: tt.bodySmall
                                                    ?.copyWith(fontSize: 13)))
                                      ]),
                                      if (_p!.city != null)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(_p!.city!,
                                                style: tt.labelSmall
                                                    ?.copyWith(fontSize: 13))),
                                      const SizedBox(height: 12),
                                      // ── ID badge (tap to copy) ──
                                      GestureDetector(
                                        onTap: _copyId,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: cs.secondary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: cs.secondary
                                                      .withOpacity(0.25))),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.tag,
                                                    size: 13,
                                                    color: cs.secondary),
                                                const SizedBox(width: 4),
                                                Text('Property ID: ${_p!.id}',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: cs.secondary,
                                                        fontFamily: 'Sora')),
                                                const SizedBox(width: 6),
                                                Icon(Icons.copy,
                                                    size: 13,
                                                    color: cs.secondary),
                                              ]),
                                        ),
                                      ),
                                    ]))),
                        const SizedBox(height: 12),
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Details',
                                          style: tt.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 12),
                                      Wrap(
                                          spacing: 16,
                                          runSpacing: 8,
                                          children: [
                                            _Spec(Icons.category_outlined,
                                                'Type', _p!.type.name),
                                            if (_p!.areaSqm != null)
                                              _Spec(Icons.square_foot, 'Area',
                                                  '${_p!.areaSqm!.toStringAsFixed(0)} m²'),
                                            if (_p!.rooms != null)
                                              _Spec(Icons.bed_outlined, 'Rooms',
                                                  '${_p!.rooms}'),
                                            if (_p!.floor != null)
                                              _Spec(
                                                  Icons.stairs_outlined,
                                                  'Floor',
                                                  '${_p!.floor}/${_p!.totalFloors ?? '?'}'),
                                            if (_p!.agentName != null)
                                              _Spec(Icons.person_outlined,
                                                  'Agent', _p!.agentName!),
                                          ]),
                                    ]))),
                        if (_p!.description != null &&
                            _p!.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Description',
                                            style: tt.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        const SizedBox(height: 8),
                                        Text(_p!.description!,
                                            style: tt.bodyMedium?.copyWith(
                                                color: tt.bodySmall?.color,
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
                                      Text('Update Status',
                                          style: tt.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 12),
                                      Row(
                                          children:
                                              PropertyStatus.values.map((s) {
                                        final sel = _p!.status == s;
                                        return Expanded(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    right:
                                                        s != PropertyStatus.SOLD
                                                            ? 8
                                                            : 0),
                                                child: OutlinedButton(
                                                  onPressed: sel
                                                      ? null
                                                      : () => _updateStatus(s),
                                                  style: OutlinedButton.styleFrom(
                                                      backgroundColor: sel
                                                          ? cs.primary
                                                          : null,
                                                      foregroundColor: sel
                                                          ? cs.onPrimary
                                                          : tt.bodySmall?.color,
                                                      side: BorderSide(
                                                          color: sel
                                                              ? cs.primary
                                                              : cs.outline),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      minimumSize:
                                                          const Size(0, 40),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontFamily:
                                                                  'Sora',
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                  child: Text(s.name),
                                                )));
                                      }).toList()),
                                    ]))),
                      ])),
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
      Text(value,
          style: tt.bodyMedium
              ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600))
    ]);
  }
}
