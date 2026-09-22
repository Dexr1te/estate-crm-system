import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientFormScreen extends StatefulWidget {
  final int? clientId;
  const ClientFormScreen({super.key, this.clientId});
  bool get isEditing => clientId != null;
  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  ClientType _type = ClientType.BUYER;
  PropertyType? _wantedType;
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
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _notesCtrl,
      _cityCtrl,
      _budgetMinCtrl,
      _budgetMaxCtrl,
      _roomsCtrl,
      _areaCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final c = await Injector.clientsRepository.getClient(widget.clientId!);
      _nameCtrl.text = c.fullName;
      _emailCtrl.text = c.email ?? '';
      _phoneCtrl.text = c.phone ?? '';
      _notesCtrl.text = c.notes ?? '';
      _cityCtrl.text = c.wantedCity ?? '';
      _budgetMinCtrl.text = _amount(c.budgetMin);
      _budgetMaxCtrl.text = _amount(c.budgetMax);
      _roomsCtrl.text = c.minRooms?.toString() ?? '';
      _areaCtrl.text = _amount(c.minAreaSqm);
      if (!mounted) return;
      setState(() {
        _type = c.type;
        _wantedType = c.wantedType;
        _initLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initLoading = false);
    }
  }

  static String _amount(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  double? _number(TextEditingController controller) {
    final text =
        controller.text.replaceAll(' ', '').replaceAll(',', '.').trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'fullName': _nameCtrl.text.trim(),
      if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
      if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      'type': _type.name,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_type == ClientType.BUYER) ...{
        if (_wantedType != null) 'wantedType': _wantedType!.name,
        if (_cityCtrl.text.trim().isNotEmpty)
          'wantedCity': _cityCtrl.text.trim(),
        if (_number(_budgetMinCtrl) != null)
          'budgetMin': _number(_budgetMinCtrl),
        if (_number(_budgetMaxCtrl) != null)
          'budgetMax': _number(_budgetMaxCtrl),
        if (_number(_roomsCtrl) != null)
          'minRooms': _number(_roomsCtrl)!.round(),
        if (_number(_areaCtrl) != null) 'minAreaSqm': _number(_areaCtrl),
      },
    };
    if (widget.isEditing) {
      context
          .read<ClientsBloc>()
          .add(ClientsUpdateEvent(widget.clientId!, data));
      context.go('/clients');
    } else {
      context.read<ClientsBloc>().add(ClientsCreateEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return BlocListener<ClientsBloc, ClientsState>(
      listener: (context, state) {
        if (state is ClientCreated) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(l10n.clientsClientCreatedId(state.client.id))));
          context.go('/clients');
        }
        if (state is ClientsActionFailure) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
        }
        if (state is ClientsError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(apiFailureLabel(l10n, state.failure)),
                backgroundColor: t.dangerSolid));
        }
        if (state is ClientsActionSuccess) {
          setState(() => _loading = false);
        }
      },
      child: Form(
        key: _formKey,
        child: DetailScaffold(
          title:
              widget.isEditing ? l10n.clientsEditClient : l10n.clientsNewClient,
          bottomAction: _initLoading
              ? null
              : Column(
                  children: [
                    AppFilledButton(
                      label: widget.isEditing
                          ? l10n.clientsUpdateClient
                          : l10n.clientsCreateClient,
                      loading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 9),
                    AppGhostButton(
                      label: l10n.coreCancel,
                      onPressed: _loading ? null : () => context.go('/clients'),
                    ),
                  ],
                ),
          children: _initLoading
              ? const [
                  ShimmerGroup(
                    child: Column(children: [
                      ShimmerCard(
                        radius: AppMetrics.radiusSm,
                        padding: EdgeInsets.all(6),
                        child: Row(children: [
                          Expanded(
                              child: ShimmerBox(
                                  width: double.infinity,
                                  height: 40,
                                  radius: 10)),
                          SizedBox(width: 6),
                          Expanded(
                              child: ShimmerBox(
                                  width: double.infinity,
                                  height: 40,
                                  radius: 10)),
                        ]),
                      ),
                      SizedBox(height: 14),
                      ShimmerFormCard(fields: 4),
                    ]),
                  )
                ]
              : [
                  _TypeSelector(
                    type: _type,
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  FormSectionCard(
                    eyebrow: l10n.clientsContactInfo,
                    children: [
                      LabelledField(
                        label: l10n.clientsFullName,
                        required: true,
                        child: AppTextField(
                          controller: _nameCtrl,
                          hint: l10n.clientsFullName,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.clientsNameRequired
                              : null,
                        ),
                      ),
                      LabelledField(
                        label: l10n.clientsPhone,
                        required: true,
                        child: AppTextField(
                          controller: _phoneCtrl,
                          hint: '+7 ___ ___-__-__',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      LabelledField(
                        label: l10n.clientsEmail,
                        child: AppTextField(
                          controller: _emailCtrl,
                          hint: 'name@mail.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v != null && v.isNotEmpty && !v.contains('@')
                                  ? l10n.clientsInvalidEmail
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  if (_type == ClientType.BUYER)
                    _RequirementsCard(
                      wantedType: _wantedType,
                      onTypeChanged: (v) => setState(() => _wantedType = v),
                      cityCtrl: _cityCtrl,
                      budgetMinCtrl: _budgetMinCtrl,
                      budgetMaxCtrl: _budgetMaxCtrl,
                      roomsCtrl: _roomsCtrl,
                      areaCtrl: _areaCtrl,
                    ),
                  FormSectionCard(
                    eyebrow: l10n.clientsNotes,
                    children: [
                      AppTextField(
                        controller: _notesCtrl,
                        hint: l10n.clientsNotesHint,
                        maxLines: 4,
                        minLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final PropertyType? wantedType;
  final ValueChanged<PropertyType?> onTypeChanged;
  final TextEditingController cityCtrl;
  final TextEditingController budgetMinCtrl;
  final TextEditingController budgetMaxCtrl;
  final TextEditingController roomsCtrl;
  final TextEditingController areaCtrl;

  const _RequirementsCard({
    required this.wantedType,
    required this.onTypeChanged,
    required this.cityCtrl,
    required this.budgetMinCtrl,
    required this.budgetMaxCtrl,
    required this.roomsCtrl,
    required this.areaCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FormSectionCard(
      eyebrow: l10n.clientsRequirements,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            l10n.clientsRequirementsHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                height: 1.35,
                color: context.tokens.textSecondary),
          ),
        ),
        LabelledField(
          label: l10n.clientsWantedType,
          child: FilterPillWrap(pills: [
            FilterPill(
              label: l10n.clientsAnyType,
              selected: wantedType == null,
              onCard: true,
              onTap: () => onTypeChanged(null),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            ),
            for (final type in PropertyType.values)
              FilterPill(
                label: propertyTypeLabel(l10n, type),
                selected: wantedType == type,
                onCard: true,
                onTap: () => onTypeChanged(type),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              ),
          ]),
        ),
        LabelledField(
          label: l10n.clientsWantedCity,
          child: AppTextField(
            controller: cityCtrl,
            hint: l10n.clientsWantedCity,
            textInputAction: TextInputAction.next,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabelledField(
                label: l10n.clientsBudgetFrom,
                child: AppTextField(
                  controller: budgetMinCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabelledField(
                label: l10n.clientsBudgetTo,
                child: AppTextField(
                  controller: budgetMaxCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabelledField(
                label: l10n.clientsMinRooms,
                child: AppTextField(
                  controller: roomsCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabelledField(
                label: l10n.clientsMinArea,
                child: AppTextField(
                  controller: areaCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final ClientType type;
  final ValueChanged<ClientType> onChanged;
  const _TypeSelector({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: EyebrowLabel(l10n.clientsClientType,
              color: context.tokens.textSecondary),
        ),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: l10n.clientsBuyer,
                selected: type == ClientType.BUYER,
                onTap: () => onChanged(ClientType.BUYER),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _TypeButton(
                label: l10n.clientsSeller,
                selected: type == ClientType.SELLER,
                onTap: () => onChanged(ClientType.SELLER),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => selected
      ? AppFilledButton(
          label: label, onPressed: onTap, height: 48, fontSize: 13)
      : AppGhostButton(
          label: label, onPressed: onTap, height: 48, fontSize: 13);
}
