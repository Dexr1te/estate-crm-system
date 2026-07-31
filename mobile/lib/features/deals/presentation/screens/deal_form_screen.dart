import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealFormScreen extends StatefulWidget {
  final int? dealId;
  const DealFormScreen({super.key, this.dealId});
  bool get isEditing => dealId != null;

  @override
  State<DealFormScreen> createState() => _DealFormScreenState();
}

class _DealFormScreenState extends State<DealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DealStatus _status = DealStatus.LEAD;
  bool _loading = false;
  bool _initLoading = false;

  List<PickerItem> _clients = const [];
  List<PickerItem> _agents = const [];
  List<PickerItem> _properties = const [];

  PickerItem? _client;
  PickerItem? _agent;
  PickerItem? _property;

  /// Set when submit is attempted without a required selection — the picker
  /// rows sit outside the Form, so they validate by hand.
  String? _clientError;
  String? _agentError;

  @override
  void initState() {
    super.initState();
    _loadLists();
    if (widget.isEditing) _loadDeal();
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _priceCtrl, _budgetCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLists() async {
    Future<void> load<T>(
      Future<List<T>> Function() fetch,
      PickerItem Function(T) map,
      void Function(List<PickerItem>) assign,
    ) async {
      try {
        final data = await fetch();
        if (!mounted) return;
        setState(() => assign(data.map(map).toList()));
      } catch (_) {
        // A picker that fails to load stays empty; the field still opens and
        // shows its empty state rather than blocking the form.
      }
    }

    await Future.wait([
      load<ClientResponse>(
        () => Injector.clientsRepository.getClients(),
        (c) => PickerItem(
            id: c.id, title: c.fullName, subtitle: c.email ?? c.phone),
        (v) {
          _clients = v;
          _client = _reconcile(v, _client);
        },
      ),
      load<AgentOption>(
        () => Injector.agentsRepository.getAgentOptions(),
        (a) => PickerItem(id: a.id, title: a.fullName, subtitle: a.email),
        (v) {
          _agents = v;
          _agent = _reconcile(v, _agent);
        },
      ),
      load<PropertyResponse>(
        () => Injector.propertiesRepository.getAllProperties(),
        (p) => PickerItem(
          id: p.id,
          title: p.title,
          subtitle:
              [if (p.city != null) p.city!, formatPrice(p.price)].join(' · '),
        ),
        (v) {
          _properties = v;
          _property = _reconcile(v, _property);
        },
      ),
    ]);
  }

  /// Swaps a placeholder ("Client #7", built while editing before the lists
  /// arrive) for the real record once it loads.
  PickerItem? _reconcile(List<PickerItem> list, PickerItem? current) {
    if (current == null) return null;
    for (final i in list) {
      if (i.id == current.id) return i;
    }
    return current;
  }

  Future<void> _loadDeal() async {
    setState(() => _initLoading = true);
    try {
      final l10n = AppLocalizations.of(context);
      final d = await Injector.dealsRepository.getDeal(widget.dealId!);
      _titleCtrl.text = d.title;
      _priceCtrl.text = d.dealPrice?.toStringAsFixed(0) ?? '';
      _budgetCtrl.text = d.budget?.toStringAsFixed(0) ?? '';
      _notesCtrl.text = d.notes ?? '';
      if (!mounted) return;
      setState(() {
        _client = _reconcile(
            _clients,
            PickerItem(
                id: d.clientId,
                title: d.clientName.isNotEmpty
                    ? d.clientName
                    : l10n.dealsClientRef(d.clientId)));
        _agent = _reconcile(
            _agents,
            PickerItem(
                id: d.agentId,
                title: d.agentName.isNotEmpty
                    ? d.agentName
                    : l10n.dealsAgentRef(d.agentId)));
        _property = d.propertyId == null
            ? null
            : _reconcile(
                _properties,
                PickerItem(
                    id: d.propertyId!,
                    title: d.propertyTitle ??
                        l10n.dealsPropertyRef(d.propertyId!)));
        _status = d.status;
        _initLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initLoading = false);
    }
  }

  Future<void> _pick(
    String title,
    List<PickerItem> items,
    PickerItem? current,
    ValueChanged<PickerItem> onPicked,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.dealsSelectLabel(title),
      items: items,
      selectedId: current?.id,
      searchHint: l10n.dealsSearchHint,
      emptyLabel: l10n.coreNoResults,
    );
    if (picked != null && mounted) setState(() => onPicked(picked));
  }

  double? _double(TextEditingController c) {
    final v = c.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return v.isEmpty ? null : double.tryParse(v);
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _clientError = _client == null ? l10n.dealsSelectClientError : null;
      _agentError = _agent == null ? l10n.dealsSelectAgentError : null;
    });
    if (!formOk || _client == null || _agent == null) return;

    setState(() => _loading = true);
    final price = _double(_priceCtrl);
    final budget = _double(_budgetCtrl);

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'clientId': _client!.id,
      'agentId': _agent!.id,
      'status': _status.name,
      if (_property != null) 'propertyId': _property!.id,
      if (price != null) 'dealPrice': price,
      if (budget != null) 'budget': budget,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    if (widget.isEditing) {
      context.read<DealsBloc>().add(DealsUpdateEvent(widget.dealId!, data));
    } else {
      context.read<DealsBloc>().add(DealsCreateEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return BlocListener<DealsBloc, DealsState>(
      listener: (context, state) {
        if (state is DealsActionSuccess) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
          context.go('/deals');
        }
        // A rejected save leaves the user on the form with their input intact.
        if (state is DealsActionFailure) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
        }
        if (state is DealsError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: t.dangerSolid));
        }
      },
      child: Form(
        key: _formKey,
        child: DetailScaffold(
          title: widget.isEditing ? l10n.dealsEditTitle : l10n.dealsNewTitle,
          bottomAction: _initLoading
              ? null
              : Column(
                  children: [
                    AppFilledButton(
                      label: widget.isEditing
                          ? l10n.dealsUpdateDeal
                          : l10n.dealsCreateDeal,
                      loading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 8),
                    AppGhostButton(
                      label: l10n.coreCancel,
                      onPressed: _loading ? null : () => context.go('/deals'),
                    ),
                  ],
                ),
          children: _initLoading
              ? const [
                  ShimmerGroup(
                    child: Column(children: [
                      ShimmerBox(
                          width: double.infinity,
                          height: 90,
                          radius: AppMetrics.radiusMd),
                      SizedBox(height: 14),
                      ShimmerBox(
                          width: double.infinity,
                          height: 230,
                          radius: AppMetrics.radiusMd),
                    ]),
                  )
                ]
              : [
                  FormSectionCard(children: [
                    LabelledField(
                      label: l10n.dealsTitleLabel,
                      required: true,
                      child: AppTextField(
                        controller: _titleCtrl,
                        hint: l10n.dealsFallbackTitle,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? l10n.dealsTitleRequired
                            : null,
                      ),
                    ),
                  ]),
                  FormSectionCard(
                    eyebrow: l10n.dealsPeopleProperty,
                    children: [
                      _PickerRow(
                        label: l10n.dealsClient,
                        required: true,
                        value: _client?.title,
                        error: _clientError,
                        onTap: () => _pick(l10n.dealsClient, _clients, _client,
                            (v) {
                          _client = v;
                          _clientError = null;
                        }),
                      ),
                      _PickerRow(
                        label: l10n.dealsAgent,
                        required: true,
                        value: _agent?.title,
                        error: _agentError,
                        onTap: () =>
                            _pick(l10n.dealsAgent, _agents, _agent, (v) {
                          _agent = v;
                          _agentError = null;
                        }),
                      ),
                      _PickerRow(
                        label: l10n.dealsProperty,
                        value: _property?.title,
                        onTap: () => _pick(
                            l10n.dealsProperty, _properties, _property,
                            (v) => _property = v),
                      ),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.dealsFinancials,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LabelledField(
                              label: l10n.dealsDealPrice,
                              child: AppTextField(
                                controller: _priceCtrl,
                                hint: '12 300 000',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: LabelledField(
                              label: l10n.dealsBudget,
                              child: AppTextField(
                                controller: _budgetCtrl,
                                hint: '13 000 000',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.dealsPipelineStage,
                    children: [
                      FilterPillWrap(pills: [
                        for (final s in DealStatus.values)
                          FilterPill(
                            label: dealStatusLabel(l10n, s),
                            selected: _status == s,
                            onCard: true,
                            onTap: () => setState(() => _status = s),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 9),
                          ),
                      ]),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.dealsNotes,
                    children: [
                      AppTextField(
                        controller: _notesCtrl,
                        hint: l10n.dealsNotesHint,
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

/// A labelled [PickerField] with an optional inline error, for the selections
/// that live outside the `Form`.
class _PickerRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? error;
  final bool required;
  final VoidCallback onTap;

  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelledField(
          label: label,
          required: required,
          child: PickerField(
            value: value,
            placeholder: l10n.coreNotSelected,
            onTap: onTap,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 2),
            child: Text(
              error!,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11,
                  color: t.dangerText),
            ),
          ),
      ],
    );
  }
}
