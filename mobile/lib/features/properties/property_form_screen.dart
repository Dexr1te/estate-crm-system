import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/features/properties/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/bloc/properties_state.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';

class PropertyFormScreen extends StatefulWidget {
  final int? propertyId;
  const PropertyFormScreen({super.key, this.propertyId});
  bool get isEditing => propertyId != null;
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _totalFloorsCtrl = TextEditingController();
  PropertyType _type = PropertyType.APARTMENT;
  PropertyStatus _status = PropertyStatus.AVAILABLE;
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
      _descCtrl,
      _addressCtrl,
      _cityCtrl,
      _priceCtrl,
      _areaCtrl,
      _roomsCtrl,
      _floorCtrl,
      _totalFloorsCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final p = await ApiService().getProperty(widget.propertyId!);
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description ?? '';
      _addressCtrl.text = p.address;
      _cityCtrl.text = p.city ?? '';
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _areaCtrl.text = p.areaSqm?.toStringAsFixed(0) ?? '';
      _roomsCtrl.text = p.rooms?.toString() ?? '';
      _floorCtrl.text = p.floor?.toString() ?? '';
      _totalFloorsCtrl.text = p.totalFloors?.toString() ?? '';
      setState(() {
        _type = p.type;
        _status = p.status;
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
      'address': _addressCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'type': _type.name,
      'status': _status.name,
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_areaCtrl.text.trim().isNotEmpty)
        'areaSqm': double.parse(_areaCtrl.text.trim()),
      if (_roomsCtrl.text.trim().isNotEmpty)
        'rooms': int.parse(_roomsCtrl.text.trim()),
      if (_floorCtrl.text.trim().isNotEmpty)
        'floor': int.parse(_floorCtrl.text.trim()),
      if (_totalFloorsCtrl.text.trim().isNotEmpty)
        'totalFloors': int.parse(_totalFloorsCtrl.text.trim()),
    };
    if (widget.isEditing) {
      context
          .read<PropertiesBloc>()
          .add(PropertiesUpdateEvent(widget.propertyId!, data));
      context.go('/properties');
    } else {
      context.read<PropertiesBloc>().add(PropertiesCreateEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<PropertiesBloc, PropertiesState>(
      listener: (context, state) {
        if (state is PropertyCreated) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Property created (ID: ${state.property.id})'),
            ),
          );
          context.go('/properties');
        }
        if (state is PropertiesError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: cs.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit Property' : 'New Property')),
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
                        title: 'Basic Info',
                        icon: Icons.description_outlined,
                        children: [
                          _f(_titleCtrl, 'Title *', Icons.title, req: true),
                          const SizedBox(height: 14),
                          _f(_priceCtrl, 'Price *', Icons.attach_money,
                              req: true, num: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FormSectionCard(
                        title: 'Location',
                        icon: Icons.location_on_outlined,
                        children: [
                          _f(_addressCtrl, 'Address *',
                              Icons.location_on_outlined,
                              req: true),
                          const SizedBox(height: 14),
                          _f(_cityCtrl, 'City', Icons.location_city_outlined),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FormSectionCard(
                        title: 'Type & Status',
                        icon: Icons.tune_outlined,
                        children: [
                          Text('Type',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: PropertyType.values
                                  .map((t) => _PillChip(
                                      label: t.name,
                                      selected: _type == t,
                                      onTap: () => setState(() => _type = t)))
                                  .toList()),
                          const SizedBox(height: 16),
                          Text('Status',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: PropertyStatus.values
                                  .map((s) => _PillChip(
                                      label: s.name,
                                      selected: _status == s,
                                      onTap: () => setState(() => _status = s)))
                                  .toList()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FormSectionCard(
                        title: 'Details',
                        icon: Icons.straighten_outlined,
                        children: [
                          Row(children: [
                            Expanded(
                                child: _f(
                                    _areaCtrl, 'Area m²', Icons.square_foot,
                                    num: true)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _f(
                                    _roomsCtrl, 'Rooms', Icons.bed_outlined,
                                    num: true))
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(
                                child: _f(
                                    _floorCtrl, 'Floor', Icons.stairs_outlined,
                                    num: true)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _f(_totalFloorsCtrl, 'Total Floors',
                                    Icons.stairs,
                                    num: true))
                          ]),
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
                                  hintText: 'Describe the property…')),
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
                                  ? 'Update Property'
                                  : 'Create Property')),
                      const SizedBox(height: 10),
                      OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: const Text('Cancel')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label, IconData icon,
          {bool req = false, bool num = false}) =>
      TextFormField(
        controller: c,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
        validator: req
            ? (v) => v == null || v.isEmpty ? '$label is required' : null
            : null,
      );
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

// ─── Pill-style selectable chip ─────────────────────────────────

class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PillChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color:
              selected ? cs.primary : cs.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? cs.primary : cs.outline.withAlpha(60)),
        ),
        child: Text(label.replaceAll('_', ' '),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : cs.onSurfaceVariant)),
      ),
    );
  }
}
