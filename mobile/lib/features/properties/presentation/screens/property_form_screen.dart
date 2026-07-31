import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertyFormScreen extends StatefulWidget {
  final int? propertyId;
  const PropertyFormScreen({super.key, this.propertyId});
  bool get isEditing => propertyId != null;
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _stepOneKey = GlobalKey<FormState>();
  final _stepTwoKey = GlobalKey<FormState>();

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
  int _step = 0;
  bool _loading = false;
  bool _initLoading = false;

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
      _totalFloorsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final p =
          await Injector.propertiesRepository.getProperty(widget.propertyId!);
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description ?? '';
      _addressCtrl.text = p.address;
      _cityCtrl.text = p.city ?? '';
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _areaCtrl.text = p.areaSqm?.toStringAsFixed(0) ?? '';
      _roomsCtrl.text = p.rooms?.toString() ?? '';
      _floorCtrl.text = p.floor?.toString() ?? '';
      _totalFloorsCtrl.text = p.totalFloors?.toString() ?? '';
      if (!mounted) return;
      setState(() {
        _type = p.type;
        _status = p.status;
        _initLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initLoading = false);
    }
  }

  void _next() {
    if (!(_stepOneKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = 1);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() => _step = 0);
  }

  int? _int(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : int.tryParse(v);
  }

  double? _double(TextEditingController c) {
    final v = c.text.trim().replaceAll(',', '.');
    return v.isEmpty ? null : double.tryParse(v);
  }

  void _submit() {
    if (!(_stepTwoKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final area = _double(_areaCtrl);
    final rooms = _int(_roomsCtrl);
    final floor = _int(_floorCtrl);
    final totalFloors = _int(_totalFloorsCtrl);

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'price': _double(_priceCtrl) ?? 0,
      'type': _type.name,
      'status': _status.name,
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (area != null) 'areaSqm': area,
      if (rooms != null) 'rooms': rooms,
      if (floor != null) 'floor': floor,
      if (totalFloors != null) 'totalFloors': totalFloors,
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
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return BlocListener<PropertiesBloc, PropertiesState>(
      listener: (context, state) {
        if (state is PropertyCreated) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content:
                    Text(l10n.propertiesPropertyCreated(state.property.id))));
          context.go('/properties');
        }
        if (state is PropertiesActionFailure) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
        }
        if (state is PropertiesError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: t.dangerSolid));
        }
      },
      child: DetailScaffold(
        title: widget.isEditing
            ? l10n.propertiesEditProperty
            : l10n.propertiesNewProperty,
        trailingLabel:
            _initLoading ? null : l10n.propertiesStepOf(_step + 1, 2),
        onBack: _step == 1 ? _back : null,
        bottomAction: _initLoading ? null : _actions(l10n),
        children: _initLoading
            ? const [
                ShimmerGroup(
                  child: Column(children: [
                    ShimmerBox(
                        width: double.infinity,
                        height: 200,
                        radius: AppMetrics.radiusMd),
                    SizedBox(height: 14),
                    ShimmerBox(
                        width: double.infinity,
                        height: 160,
                        radius: AppMetrics.radiusMd),
                  ]),
                )
              ]
            : [
                _StepBar(step: _step),
                if (_step == 0)
                  Form(key: _stepOneKey, child: _stepOne(l10n))
                else
                  Form(key: _stepTwoKey, child: _stepTwo(l10n)),
              ],
      ),
    );
  }

  Widget _actions(AppLocalizations l10n) => _step == 0
      ? AppFilledButton(label: l10n.propertiesNextDetails, onPressed: _next)
      : Column(
          children: [
            AppFilledButton(
              label: widget.isEditing
                  ? l10n.propertiesUpdateProperty
                  : l10n.propertiesCreateProperty,
              loading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            const SizedBox(height: 9),
            AppGhostButton(
              label: l10n.propertiesBack,
              onPressed: _loading ? null : _back,
            ),
          ],
        );

  Widget _stepOne(AppLocalizations l10n) {
    final gap = AppMetrics.blockGap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSectionCard(
          eyebrow: l10n.propertiesBasicInfo,
          children: [
            LabelledField(
              label: l10n.propertiesProperty,
              required: true,
              child: AppTextField(
                controller: _titleCtrl,
                hint: l10n.propertiesTitleLabel,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.propertiesFieldRequired(l10n.propertiesProperty)
                    : null,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabelledField(
                    label: l10n.propertiesPriceLabel,
                    required: true,
                    child: AppTextField(
                      controller: _priceCtrl,
                      hint: '12 300 000',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) => _double(_priceCtrl) == null ||
                              _double(_priceCtrl)! <= 0
                          ? l10n.propertiesFieldRequired(
                              l10n.propertiesPriceLabel)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabelledField(
                    label: l10n.propertiesAreaLabel,
                    child: AppTextField(
                      controller: _areaCtrl,
                      hint: '58',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: gap),
        FormSectionCard(
          eyebrow: l10n.propertiesLocation,
          children: [
            LabelledField(
              label: l10n.propertiesAddressLabel,
              required: true,
              child: AppTextField(
                controller: _addressCtrl,
                hint: l10n.propertiesAddressLabel,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.propertiesFieldRequired(l10n.propertiesAddressLabel)
                    : null,
              ),
            ),
            LabelledField(
              label: l10n.propertiesCityLabel,
              child: AppTextField(
                controller: _cityCtrl,
                hint: l10n.propertiesCityLabel,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        FormSectionCard(
          eyebrow: l10n.propertiesType,
          children: [
            FilterPillWrap(pills: [
              for (final type in PropertyType.values)
                FilterPill(
                  label: propertyTypeLabel(l10n, type),
                  selected: _type == type,
                  onCard: true,
                  onTap: () => setState(() => _type = type),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _stepTwo(AppLocalizations l10n) {
    final gap = AppMetrics.blockGap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSectionCard(
          eyebrow: l10n.propertiesDetails,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabelledField(
                    label: l10n.propertiesRooms,
                    child: AppTextField(
                      controller: _roomsCtrl,
                      hint: '2',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabelledField(
                    label: l10n.propertiesFloor,
                    child: AppTextField(
                      controller: _floorCtrl,
                      hint: '5',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabelledField(
                    label: l10n.propertiesTotalFloors,
                    child: AppTextField(
                      controller: _totalFloorsCtrl,
                      hint: '24',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: gap),
        FormSectionCard(
          eyebrow: l10n.propertiesStatus,
          children: [
            Row(
              children: [
                for (var i = 0; i < PropertyStatus.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: FilterPill(
                      label:
                          propertyStatusLabel(l10n, PropertyStatus.values[i]),
                      selected: _status == PropertyStatus.values[i],
                      onCard: true,
                      onTap: () =>
                          setState(() => _status = PropertyStatus.values[i]),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 11),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: gap),
        FormSectionCard(
          eyebrow: l10n.propertiesDescription,
          children: [
            AppTextField(
              controller: _descCtrl,
              hint: l10n.propertiesDescribeHint,
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: i <= step ? t.accent : t.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
