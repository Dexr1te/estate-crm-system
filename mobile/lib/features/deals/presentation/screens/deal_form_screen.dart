import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_sheets.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_event.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_state.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/lost_reason_sheet.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DealFormScreen extends StatefulWidget {
  final int? dealId;
  final int? initialClientId;
  final int? initialPropertyId;
  const DealFormScreen(
      {super.key, this.dealId, this.initialClientId, this.initialPropertyId});
  bool get isEditing => dealId != null;

  @override
  State<DealFormScreen> createState() => _DealFormScreenState();
}

class _DealFormScreenState extends State<DealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _reminderCtrl = TextEditingController();

  DealKind _kind = DealKind.sale;
  DateTime? _leaseStart;
  DateTime? _leaseEnd;
  PickerItem? _landlord;
  String? _leaseError;

  DealStatus _status = DealStatus.LEAD;
  DealLostReason? _lostReason;
  String? _lostNote;
  bool _loading = false;
  bool _initLoading = false;

  /// The deal as it was loaded, for the checklist warning on a stage move.
  DealResponse? _loaded;

  List<PickerItem> _clients = const [];
  List<PickerItem> _agents = const [];
  List<PickerItem> _properties = const [];

  PickerItem? _client;
  PickerItem? _agent;
  PickerItem? _property;

  String? _clientError;
  String? _agentError;

  @override
  void initState() {
    super.initState();
    if (!widget.isEditing) {
      final clientId = widget.initialClientId;
      final propertyId = widget.initialPropertyId;
      if (clientId != null) _client = PickerItem(id: clientId, title: '');
      if (propertyId != null) {
        _property = PickerItem(id: propertyId, title: '');
      }
    }
    _loadLists();
    if (widget.isEditing) _loadDeal();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _priceCtrl,
      _budgetCtrl,
      _commissionCtrl,
      _notesCtrl,
      _rentCtrl,
      _reminderCtrl,
    ]) {
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
      } catch (_) {}
    }

    await Future.wait([
      load<ClientResponse>(
        () => Injector.clientsRepository.getClients(),
        (c) => PickerItem(
            id: c.id, title: c.fullName, subtitle: c.email ?? c.phone),
        (v) {
          _clients = v;
          _client = _reconcile(v, _client);
          _landlord = _reconcile(v, _landlord);
        },
      ),
      load<AgentOption>(
        () => Injector.agentsRepository.getAgentOptions(),
        (a) => agentPickerItem(context, a),
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
      final d = await Injector.dealsRepository.getDeal(widget.dealId!);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _titleCtrl.text = d.title;
      _priceCtrl.text = d.dealPrice?.toStringAsFixed(0) ?? '';
      _budgetCtrl.text = d.budget?.toStringAsFixed(0) ?? '';
      _commissionCtrl.text =
          d.commissionPercent == null ? '' : formatRate(d.commissionPercent!);
      _notesCtrl.text = d.notes ?? '';
      _rentCtrl.text = d.monthlyRent == null ? '' : formatRate(d.monthlyRent!);
      _reminderCtrl.text = d.leaseReminderDays?.toString() ?? '';
      setState(() {
        _kind = d.kind;
        _leaseStart = d.leaseStart;
        _leaseEnd = d.leaseEnd;
        _landlord = d.landlordId == null
            ? null
            : _reconcile(
                _clients,
                PickerItem(
                    id: d.landlordId!,
                    title:
                        d.landlordName ?? l10n.dealsClientRef(d.landlordId!)));
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
        _loaded = d;
        _status = d.status;
        _lostReason = d.lostReason;
        _lostNote = d.lostNote;
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

  Future<void> _pickStatus(DealStatus s) async {
    final loaded = _loaded;
    if (loaded != null && s != _status) {
      final go =
          await confirmChecklistGate(context, openRequiredForMove(loaded, s));
      if (!go || !mounted) return;
    }
    if (s != DealStatus.CLOSED_LOST) {
      setState(() => _status = s);
      return;
    }
    final choice = await showLostReasonSheet(context,
        initialReason: _lostReason, initialNote: _lostNote);
    if (choice == null || !mounted) return;
    setState(() {
      _status = s;
      _lostReason = choice.reason;
      _lostNote = choice.note;
    });
  }

  double? _double(TextEditingController c) {
    final v = c.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return v.isEmpty ? null : double.tryParse(v);
  }

  String? _validateCommission(String? _) {
    if (_commissionCtrl.text.trim().isEmpty) return null;
    final v = _double(_commissionCtrl);
    final twoPlaces = v != null && ((v * 100).round() - v * 100).abs() < 1e-6;
    if (v == null || v <= 0 || v > 100 || !twoPlaces) {
      return AppLocalizations.of(context).dealsCommissionInvalid;
    }
    return null;
  }

  String? _validateRent(String? _) {
    if (_kind != DealKind.rent) return null;
    final v = _double(_rentCtrl);
    return v == null || v <= 0
        ? AppLocalizations.of(context).leasesRentRequired
        : null;
  }

  String? _validateReminder(String? _) {
    if (_kind != DealKind.rent || _reminderCtrl.text.trim().isEmpty) {
      return null;
    }
    final v = int.tryParse(_reminderCtrl.text.trim());
    return v == null || v < 1 || v > kMaxLeaseReminderDays
        ? AppLocalizations.of(context).leasesReminderInvalid
        : null;
  }

  /// What is wrong with the lease's days, or null.
  String? _leaseDatesError(AppLocalizations l10n) {
    if (_kind != DealKind.rent) return null;
    final start = _leaseStart;
    final end = _leaseEnd;
    if (start == null || end == null) return l10n.leasesDatesRequired;
    if (!end.isAfter(start)) return l10n.leasesEndBeforeStart;
    return null;
  }

  Future<void> _pickLeaseDay(bool start) async {
    final now = AppClock.now();
    final current = start ? _leaseStart : _leaseEnd;
    final initial = current ??
        (start
            ? DateTime(now.year, now.month, now.day)
            : (_leaseStart == null
                ? DateTime(now.year + 1, now.month, now.day)
                : DateTime(_leaseStart!.year + 1, _leaseStart!.month,
                    _leaseStart!.day)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _leaseStart = picked;
      } else {
        _leaseEnd = picked;
      }
      if (_leaseError != null) {
        _leaseError = _leaseDatesError(AppLocalizations.of(context));
      }
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _clientError = _client == null ? l10n.dealsSelectClientError : null;
      _agentError = _agent == null ? l10n.dealsSelectAgentError : null;
      _leaseError = _leaseDatesError(l10n);
    });
    if (!formOk || _client == null || _agent == null || _leaseError != null) {
      return;
    }

    setState(() => _loading = true);
    final rent = _kind == DealKind.rent;
    final price = rent ? null : _double(_priceCtrl);
    final budget = _double(_budgetCtrl);
    final commission = _double(_commissionCtrl);
    final reminder = int.tryParse(_reminderCtrl.text.trim());

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'clientId': _client!.id,
      'agentId': _agent!.id,
      'status': _status.name,
      'kind': dealKindParam(_kind),
      if (rent) ...{
        'monthlyRent': _double(_rentCtrl),
        'leaseStart': leaseDateParam(_leaseStart!),
        'leaseEnd': leaseDateParam(_leaseEnd!),
        if (reminder != null) 'leaseReminderDays': reminder,
        if (_landlord != null) 'landlordId': _landlord!.id,
      },
      if (_property != null) 'propertyId': _property!.id,
      if (price != null) 'dealPrice': price,
      if (budget != null) 'budget': budget,
      if (commission != null) 'commissionPercent': commission,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_status == DealStatus.CLOSED_LOST && _lostReason != null)
        'lostReason': _lostReason!.name,
      if (_status == DealStatus.CLOSED_LOST && _lostNote != null)
        'lostNote': _lostNote,
    };

    if (widget.isEditing) {
      context.read<DealsBloc>().add(DealsUpdateEvent(widget.dealId!, data));
    } else {
      context.read<DealsBloc>().add(DealsCreateEvent(data));
    }
  }

  /// The lease of a rent: its first and last day, when to be reminded, and
  /// who lets the place.
  Widget _leaseSection(AppLocalizations l10n, AppTokens t) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    String? day(DateTime? d) => d == null ? null : formatFullDate(d, locale);

    return FormSectionCard(
      eyebrow: l10n.leasesTitle,
      children: [
        LabelledField(
          label: l10n.leasesStart,
          required: true,
          child: PickerField(
            key: const ValueKey('deal-form-lease-start'),
            value: day(_leaseStart),
            placeholder: l10n.leasesPickDate,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () => _pickLeaseDay(true),
          ),
        ),
        LabelledField(
          label: l10n.leasesEnd,
          required: true,
          child: PickerField(
            key: const ValueKey('deal-form-lease-end'),
            value: day(_leaseEnd),
            placeholder: l10n.leasesPickDate,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () => _pickLeaseDay(false),
          ),
        ),
        if (_leaseError != null)
          Text(
            _leaseError!,
            key: const ValueKey('deal-form-lease-error'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
          ),
        LabelledField(
          label: l10n.leasesReminderDays,
          child: AppTextField(
            key: const ValueKey('deal-form-lease-reminder'),
            controller: _reminderCtrl,
            hint: '$kDefaultLeaseReminderDays',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: _validateReminder,
          ),
        ),
        _PickerRow(
          label: l10n.leasesLandlord,
          value: _landlord?.title,
          onTap: () => _pick(
              l10n.leasesLandlord, _clients, _landlord, (v) => _landlord = v),
        ),
      ],
    );
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
        if (state is DealsActionFailure) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
        }
        if (state is DealsError) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(apiFailureLabel(l10n, state.failure)),
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
                      ShimmerFormCard(fields: 2),
                      SizedBox(height: 14),
                      ShimmerFormCard(fields: 3),
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
                        onTap: () =>
                            _pick(l10n.dealsClient, _clients, _client, (v) {
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
                        onTap: () => _pick(l10n.dealsProperty, _properties,
                            _property, (v) => _property = v),
                      ),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.dealsKind,
                    children: [
                      FilterPillWrap(pills: [
                        for (final k in DealKind.values)
                          FilterPill(
                            key: ValueKey('deal-form-kind-${k.name}'),
                            label: dealKindLabel(l10n, k),
                            selected: _kind == k,
                            onCard: true,
                            onTap: () => setState(() {
                              _kind = k;
                              _leaseError = null;
                            }),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 9),
                          ),
                      ]),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.dealsFinancials,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _kind == DealKind.rent
                                ? LabelledField(
                                    label: l10n.leasesMonthlyRent,
                                    required: true,
                                    child: AppTextField(
                                      key: const ValueKey('deal-form-rent'),
                                      controller: _rentCtrl,
                                      hint: '350 000',
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      validator: _validateRent,
                                    ),
                                  )
                                : LabelledField(
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
                      LabelledField(
                        label: l10n.dealsCommissionPercent,
                        child: AppTextField(
                          controller: _commissionCtrl,
                          hint: '2.5',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textInputAction: TextInputAction.next,
                          validator: _validateCommission,
                        ),
                      ),
                    ],
                  ),
                  if (_kind == DealKind.rent) _leaseSection(l10n, t),
                  FormSectionCard(
                    eyebrow: l10n.dealsPipelineStage,
                    children: [
                      FilterPillWrap(pills: [
                        for (final s in DealStatus.values)
                          FilterPill(
                            label: dealStatusLabel(l10n, s),
                            selected: _status == s,
                            onCard: true,
                            onTap: () => _pickStatus(s),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 9),
                          ),
                      ]),
                      if (_status == DealStatus.CLOSED_LOST &&
                          _lostReason != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.dealsLostReason}: '
                          '${dealLostReasonLabel(l10n, _lostReason)}',
                          key: const ValueKey('deal-form-lost-reason'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 12.5,
                              height: 1.4,
                              color: t.textSecondary),
                        ),
                      ],
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
                  fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
            ),
          ),
      ],
    );
  }
}
