import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
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
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Sora'))),
                                        PropertyStatusChip(status: _p!.status)
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(formatPrice(_p!.price),
                                          style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                              fontFamily: 'Sora')),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        const Icon(Icons.location_on_outlined,
                                            size: 15,
                                            color: AppColors.textHint),
                                        const SizedBox(width: 4),
                                        Flexible(
                                            child: Text(_p!.address,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13)))
                                      ]),
                                      if (_p!.city != null)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(_p!.city!,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textHint))),
                                    ]))),
                        const SizedBox(height: 12),
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Details',
                                          style: TextStyle(
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
                                        const Text('Description',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        const SizedBox(height: 8),
                                        Text(_p!.description!,
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
                                      const Text('Update Status',
                                          style: TextStyle(
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
                                                          ? AppColors.primary
                                                          : null,
                                                      foregroundColor: sel
                                                          ? Colors.white
                                                          : AppColors
                                                              .textSecondary,
                                                      side: BorderSide(
                                                          color: sel
                                                              ? AppColors
                                                                  .primary
                                                              : const Color(
                                                                  0xFFE8ECF4)),
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
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text('$label: ',
            style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary))
      ]);
}
