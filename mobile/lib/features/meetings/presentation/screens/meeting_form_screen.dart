import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_event.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

class MeetingFormScreen extends StatefulWidget {
  final int? meetingId;
  const MeetingFormScreen({super.key, this.meetingId});
  bool get isEditing => meetingId != null;

  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime? _scheduledAt;
  bool _loading = false;
  bool _initLoading = false;

  /// Why the pickers are empty, when the reason is a failed request rather
  /// than an empty agency. Swallowing this made a broken connection look
  /// exactly like having no colleagues.
  ApiFailure? _loadFailure;

  List<PickerItem> _clients = const [];
  List<PickerItem> _agents = const [];
  List<PickerItem> _deals = const [];

  PickerItem? _client;
  PickerItem? _agent;
  PickerItem? _deal;

  String? _clientError;
  String? _agentError;
  String? _whenError;

  @override
  void initState() {
    super.initState();
    _loadLists();
    if (widget.isEditing) _loadMeeting();
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _locationCtrl]) {
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
      } catch (err) {
        if (!mounted) return;
        setState(() => _loadFailure = ApiFailure.from(err));
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
      load<DealResponse>(
        () => Injector.dealsRepository.getDeals(),
        (d) => PickerItem(id: d.id, title: d.title, subtitle: d.clientName),
        (v) {
          _deals = v;
          _deal = _reconcile(v, _deal);
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

  Future<void> _loadMeeting() async {
    setState(() => _initLoading = true);
    try {
      final l10n = AppLocalizations.of(context);
      final m = await Injector.meetingsRepository.getMeeting(widget.meetingId!);
      _titleCtrl.text = m.title;
      _descCtrl.text = m.description ?? '';
      _locationCtrl.text = m.location ?? '';
      if (!mounted) return;
      setState(() {
        _scheduledAt = m.scheduledAt;
        _client = _reconcile(
            _clients,
            PickerItem(
                id: m.clientId,
                title: m.clientName.isNotEmpty
                    ? m.clientName
                    : l10n.meetingsClientNumber(m.clientId)));
        _agent = _reconcile(
            _agents,
            PickerItem(
                id: m.agentId,
                title: m.agentName.isNotEmpty
                    ? m.agentName
                    : l10n.meetingsAgentNumber(m.agentId)));
        _deal = m.dealId == null
            ? null
            : _reconcile(
                _deals,
                PickerItem(
                    id: m.dealId!,
                    title: m.dealTitle ?? l10n.meetingsDealNumber(m.dealId!)));
        _initLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initLoading = false);
    }
  }

  Future<void> _pick(
    String label,
    List<PickerItem> items,
    PickerItem? current,
    ValueChanged<PickerItem> onPicked, {
    String? whenNone,
  }) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.meetingsSelectEntity(label),
      items: items,
      selectedId: current?.id,
      searchHint: l10n.meetingsSearchByNameOrId,
      emptyLabel: _emptyLabel(l10n, whenNone ?? l10n.coreNoResults),
    );
    if (picked != null && mounted) setState(() => onPicked(picked));
  }

  /// What an empty picker should say: a failed load and an empty list look the
  /// same on screen, and only one of them is the person's problem to solve.
  String _emptyLabel(AppLocalizations l10n, String noneLabel) =>
      _loadFailure == null ? noneLabel : apiFailureLabel(l10n, _loadFailure!);

  /// Where the pickers start when nothing has been chosen: the next half hour,
  /// not this instant. "Now" as a default meant picking today and leaving the
  /// time alone produced a moment already in the past, which the backend
  /// refuses outright (MeetingRequest.scheduledAt is @Future) — the form looked
  /// filled in and the save came back as an error nobody expected.
  DateTime get _defaultSlot {
    final now = AppClock.now();
    final rounded = DateTime(now.year, now.month, now.day, now.hour)
        .add(Duration(minutes: now.minute < 30 ? 30 : 60));
    return rounded;
  }

  Future<void> _pickDate() async {
    final now = AppClock.now();
    final base = _scheduledAt ?? _defaultSlot;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      // The backend requires a future time (MeetingRequest.scheduledAt is
      // @Future), so a past date is a round trip that can only fail. Editing an
      // older meeting still opens on its own date.
      firstDate: _scheduledAt != null && _scheduledAt!.isBefore(now)
          ? _scheduledAt!
          : now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _scheduledAt =
          DateTime(date.year, date.month, date.day, base.hour, base.minute);
      _whenError = null;
    });
  }

  Future<void> _pickTime() async {
    final base = _scheduledAt ?? _defaultSlot;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt =
          DateTime(base.year, base.month, base.day, time.hour, time.minute);
      _whenError = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _clientError = _client == null ? l10n.meetingsPleaseSelectClient : null;
      _agentError = _agent == null ? l10n.meetingsPleaseSelectAgent : null;
      _whenError = _scheduledAt == null
          ? l10n.meetingsPleaseSelectDateTime
          : !_scheduledAt!.isAfter(AppClock.now())
              ? l10n.meetingsMustBeInFuture
              : null;
    });
    if (!formOk ||
        _client == null ||
        _agent == null ||
        _scheduledAt == null ||
        _whenError != null) {
      return;
    }

    setState(() => _loading = true);
    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'scheduledAt': _scheduledAt!.toIso8601String(),
      'clientId': _client!.id,
      'agentId': _agent!.id,
      if (_deal != null) 'dealId': _deal!.id,
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
    };

    if (widget.isEditing) {
      context
          .read<MeetingsBloc>()
          .add(MeetingsUpdateEvent(widget.meetingId!, data));
    } else {
      context.read<MeetingsBloc>().add(MeetingsCreateEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return BlocListener<MeetingsBloc, MeetingsState>(
      listener: (context, state) {
        if (state is MeetingsActionSuccess) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
          context.go('/meetings');
        }
        if (state is MeetingsActionFailure) {
          setState(() => _loading = false);
          showActionOutcome(context, state);
        }
        if (state is MeetingsError) {
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
          title: widget.isEditing
              ? l10n.meetingsEditMeeting
              : l10n.meetingsScheduleMeeting,
          bottomAction: _initLoading
              ? null
              : Column(
                  children: [
                    AppFilledButton(
                      label: widget.isEditing
                          ? l10n.meetingsUpdateMeeting
                          : l10n.meetingsSchedule,
                      loading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 8),
                    AppGhostButton(
                      label: l10n.coreCancel,
                      onPressed:
                          _loading ? null : () => context.go('/meetings'),
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
                          height: 200,
                          radius: AppMetrics.radiusMd),
                    ]),
                  )
                ]
              : [
                  FormSectionCard(children: [
                    LabelledField(
                      label: l10n.meetingsTitleFieldLabel,
                      required: true,
                      child: AppTextField(
                        controller: _titleCtrl,
                        hint: l10n.meetingsTitle,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? l10n.meetingsTitleRequired
                            : null,
                      ),
                    ),
                  ]),
                  FormSectionCard(
                    eyebrow: l10n.meetingsWhen,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LabelledField(
                              label: l10n.meetingsDate,
                              required: true,
                              child: PickerField(
                                value: _scheduledAt == null
                                    ? null
                                    : formatDayMonth(_scheduledAt!, locale),
                                placeholder: l10n.meetingsDate,
                                onTap: _pickDate,
                                trailingIcon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: LabelledField(
                              label: l10n.meetingsTime,
                              required: true,
                              child: PickerField(
                                value: _scheduledAt == null
                                    ? null
                                    : formatTimeOfDay(_scheduledAt!),
                                placeholder: l10n.meetingsTime,
                                onTap: _pickTime,
                                trailingIcon: Icons.schedule_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_whenError != null)
                        Text(
                          _whenError!,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11,
                              color: t.dangerText),
                        ),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.meetingsWhoAndWhere,
                    children: [
                      _PickerRow(
                        label: l10n.meetingsClient,
                        required: true,
                        value: _client?.title,
                        error: _clientError,
                        onTap: () =>
                            _pick(l10n.meetingsClient, _clients, _client, (v) {
                          _client = v;
                          _clientError = null;
                        }),
                      ),
                      _PickerRow(
                        label: l10n.meetingsAgent,
                        required: true,
                        value: _agent?.title,
                        error: _agentError,
                        onTap: () =>
                            _pick(l10n.meetingsAgent, _agents, _agent, (v) {
                          _agent = v;
                          _agentError = null;
                        }, whenNone: l10n.meetingsNoAgentsToAssign),
                      ),
                      _PickerRow(
                        label: l10n.meetingsDeal,
                        value: _deal?.title,
                        onTap: () => _pick(
                            l10n.meetingsDeal, _deals, _deal, (v) => _deal = v),
                      ),
                      LabelledField(
                        label: l10n.meetingsLocation,
                        child: AppTextField(
                          controller: _locationCtrl,
                          hint: l10n.meetingsLocation,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  FormSectionCard(
                    eyebrow: l10n.meetingsDescription,
                    children: [
                      AppTextField(
                        controller: _descCtrl,
                        hint: l10n.meetingsAgendaHint,
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
