import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_filter_sheet.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_button.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  ClientType? _typeFilter;

  /// Only buyers from a listing's public page, from the last week — see
  /// [ClientSummary.isNewLead].
  bool _leadsOnly = false;

  /// Clients carrying every one of these tags; alongside the other filters.
  Set<String> _tags = const {};

  @override
  void initState() {
    super.initState();
    context.read<ClientsBloc>().add(ClientsLoadEvent());
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ClientSummary> _visible(List<ClientSummary> all) {
    final now = AppClock.now();
    return all
        .where((c) => _typeFilter == null || c.type == _typeFilter)
        .where((c) => !_leadsOnly || c.isNewLead(now))
        .where((c) => c.hasAllTags(_tags))
        .where((c) => _search.isEmpty || c.matches(_search))
        .toList();
  }

  Future<void> _pickTags(List<ClientSummary> all) async {
    final picked = await showClientTagFilter(context,
        available: tagCounts(all), selected: _tags);
    if (picked != null && mounted) setState(() => _tags = picked);
  }

  ExportFilters get _exportFilters => ExportFilters(
        type: _typeFilter?.name,
        source: _leadsOnly ? 'PUBLIC_LINK' : null,
        createdFrom: _leadsOnly
            ? AppClock.now().subtract(ClientSummary.newLeadWindow)
            : null,
        search: _search.trim().isEmpty ? null : _search.trim(),
        tags: _tags.toList(),
      );

  void _pick({ClientType? type, bool leads = false}) => setState(() {
        _typeFilter = type;
        _leadsOnly = leads;
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AppMetrics.constrain(
          BlocConsumer<ClientsBloc, ClientsState>(
            listener: (ctx, state) {
              if (state is ClientsError) {
                ScaffoldMessenger.of(ctx)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(apiFailureLabel(l10n, state.failure)),
                      backgroundColor: t.dangerSolid));
              }
              showActionOutcome(ctx, state);
            },
            builder: (ctx, state) {
              final all =
                  state is ClientsLoaded ? state.clients : <ClientSummary>[];
              final visible = _visible(all);

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ScreenTitle(
                                l10n.clientsTitle,
                                reserveSubtitle: true,
                                subtitle: state is ClientsLoaded
                                    ? l10n.clientsCounter(
                                        all
                                            .where((c) => c.dealCount > 0)
                                            .length,
                                        all.length)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ExportButton(
                                kind: ExportKind.clients,
                                filters: _exportFilters),
                            const SizedBox(width: 4),
                            const QuickAddButton()
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _searchCtrl,
                          skin: FieldSkin.page,
                          hint: l10n.clientsSearchHint,
                          icon: Icons.search_rounded,
                        ),
                        const SizedBox(height: 10),
                        FilterPillRow(pills: [
                          FilterPill(
                            label: l10n.clientsFilterAll,
                            selected: _typeFilter == null && !_leadsOnly,
                            onTap: () => _pick(),
                          ),
                          FilterPill(
                            label: l10n.clientsFilterBuyers,
                            selected: _typeFilter == ClientType.BUYER,
                            onTap: () => _pick(type: ClientType.BUYER),
                          ),
                          FilterPill(
                            label: l10n.clientsFilterSellers,
                            selected: _typeFilter == ClientType.SELLER,
                            onTap: () => _pick(type: ClientType.SELLER),
                          ),
                          FilterPill(
                            key: const ValueKey('clients-filter-leads'),
                            label: l10n.clientsFilterNewLeads,
                            selected: _leadsOnly,
                            onTap: () => _pick(leads: true),
                          ),
                          FilterPill(
                            key: const ValueKey('clients-filter-tags'),
                            label: _tags.isEmpty
                                ? l10n.clientsTags
                                : l10n.clientsFilterTagsCount(_tags.length),
                            selected: _tags.isNotEmpty,
                            onTap: () => _pickTags(all),
                          ),
                        ]),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  Expanded(child: _body(ctx, state, visible, l10n, pad)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext ctx, ClientsState state,
      List<ClientSummary> visible, AppLocalizations l10n, double pad) {
    if (state is ClientsLoading || state is ClientsInitial) {
      return ShimmerList(
        count: 5,
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        cardBuilder: () => const ClientCardBone(),
      );
    }
    if (state is ClientsError) {
      return ErrorWidget2(
        message: apiFailureLabel(l10n, state.failure),
        onRetry: () => ctx.read<ClientsBloc>().add(ClientsLoadEvent()),
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline_rounded,
        title: l10n.clientsNoClientsFound,
        subtitle: _leadsOnly && _search.isEmpty
            ? l10n.clientsNewLeadsEmpty
            : _search.isNotEmpty ||
                    _typeFilter != null ||
                    _leadsOnly ||
                    _tags.isNotEmpty
                ? l10n.clientsTryDifferentSearch
                : l10n.clientsAddFirstClient,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ctx.read<ClientsBloc>().add(ClientsLoadEvent()),
      color: ctx.tokens.primary,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, i) => ClientCard(
          client: visible[i],
          onTap: () => context.go('/clients/${visible[i].id}'),
        ),
      ),
    );
  }
}
