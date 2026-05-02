import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'properties_bloc.dart';

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
    final tt = Theme.of(context).textTheme;

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
                padding: const EdgeInsets.all(24),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _f(_titleCtrl, 'Title *', Icons.title, req: true),
                          const SizedBox(height: 12),
                          _f(_addressCtrl, 'Address *',
                              Icons.location_on_outlined,
                              req: true),
                          const SizedBox(height: 12),
                          _f(_cityCtrl, 'City', Icons.location_city_outlined),
                          const SizedBox(height: 12),
                          _f(_priceCtrl, 'Price *', Icons.attach_money,
                              req: true, num: true),
                          const SizedBox(height: 16),
                          Text('Type',
                              style: tt.labelMedium?.copyWith(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 8,
                              children: PropertyType.values
                                  .map((t) => ChoiceChip(
                                      label: Text(t.name,
                                          style: const TextStyle(fontSize: 12)),
                                      selected: _type == t,
                                      onSelected: (_) =>
                                          setState(() => _type = t),
                                      selectedColor: cs.primary.withAlpha(38)))
                                  .toList()),
                          const SizedBox(height: 16),
                          Text('Status',
                              style: tt.labelMedium?.copyWith(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 8,
                              children: PropertyStatus.values
                                  .map((s) => ChoiceChip(
                                      label: Text(s.name,
                                          style: const TextStyle(fontSize: 12)),
                                      selected: _status == s,
                                      onSelected: (_) =>
                                          setState(() => _status = s),
                                      selectedColor: cs.primary.withAlpha(38)))
                                  .toList()),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: _descCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText: 'Description',
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
                                      ? 'Update Property'
                                      : 'Create Property')),
                          const SizedBox(height: 12),
                          OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52)),
                              child: const Text('Cancel')),
                        ]))),
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
