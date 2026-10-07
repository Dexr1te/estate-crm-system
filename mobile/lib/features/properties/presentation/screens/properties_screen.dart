import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/widgets/compare_tray_bar.dart';
import 'package:real_estate_crm/features/exports/presentation/widgets/export_button.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_map_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/properties_map_view.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});
  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  PropertyStatus? _filterStatus;
  PropertyType? _filterType;
  bool _map = false;

  /// Null outside compare mode; the picked ids, in the order picked, inside.
  List<int>? _picked;
  String? _query;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<PropertiesBloc>().add(PropertiesLoadMoreEvent());
    }
  }

  void _reload() {
    final q = _searchCtrl.text.trim();
    _query = q.isEmpty ? null : q;
    context.read<PropertiesBloc>().add(PropertiesLoadEvent(
          status: _filterStatus,
          type: _filterType,
          search: q.isEmpty ? null : q,
        ));
  }

  void _toggleCompareMode() =>
      setState(() => _picked = _picked == null ? <int>[] : null);

  void _togglePick(int id) {
    final picked = _picked!;
    if (picked.contains(id)) {
      setState(() => picked.remove(id));
    } else if (picked.length >= kMaxCompared) {
      showActionUnavailable(context, AppLocalizations.of(context).compareLimit);
    } else {
      setState(() => picked.add(id));
    }
  }

  ExportFilters get _exportFilters => ExportFilters(
        status: _filterStatus?.name,
        type: _filterType?.name,
        search: _query,
      );

  MapFilters get _mapFilters =>
      MapFilters(status: _filterStatus, type: _filterType, search: _query);

  void _setStatus(PropertyStatus? s) {
    setState(() => _filterStatus = s);
    _reload();
  }

  Future<void> _openTypeFilter() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppBottomSheet<Object?>(
      context,
      title: l10n.propertiesType,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterPillWrap(pills: [
            FilterPill(
              label: l10n.propertiesAll,
              selected: _filterType == null,
              onTap: () => Navigator.pop(ctx, _kAnyType),
            ),
            for (final type in PropertyType.values)
              FilterPill(
                label: propertyTypeLabel(l10n, type),
                selected: _filterType == type,
                onTap: () => Navigator.pop(ctx, type),
              ),
          ]),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    setState(() =>
        _filterType = picked == _kAnyType ? null : picked as PropertyType);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AppMetrics.constrain(
          BlocConsumer<PropertiesBloc, PropertiesState>(
            listener: (ctx, state) {
              if (state is PropertiesError) {
                ScaffoldMessenger.of(ctx)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(apiFailureLabel(l10n, state.failure)),
                      backgroundColor: t.dangerSolid));
              }
              showActionOutcome(ctx, state);
            },
            builder: (ctx, state) {
              final items = state is PropertiesLoaded
                  ? state.properties
                  : <PropertyResponse>[];

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
                                l10n.propertiesTitle,
                                reserveSubtitle: true,
                                subtitle: state is PropertiesLoaded
                                    ? l10n.propertiesCounter(
                                        items
                                            .where((p) =>
                                                p.status ==
                                                PropertyStatus.RESERVED)
                                            .length,
                                        items.length)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!_map) ...[
                              AppIconTile(
                                key: const ValueKey('properties-compare'),
                                icon: _picked == null
                                    ? Icons.compare_arrows_rounded
                                    : Icons.close_rounded,
                                tooltip: _picked == null
                                    ? l10n.compareAction
                                    : l10n.compareExit,
                                onPressed: _toggleCompareMode,
                              ),
                              const SizedBox(width: 4),
                            ],
                            ExportButton(
                                kind: ExportKind.properties,
                                filters: _exportFilters),
                            const SizedBox(width: 4),
                            const QuickAddButton()
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedTabs(
                          key: const ValueKey('properties-view-tabs'),
                          labels: [
                            l10n.propertiesViewList,
                            l10n.propertiesViewMap
                          ],
                          selectedIndex: _map ? 1 : 0,
                          onSelected: (i) => setState(() {
                            _map = i == 1;
                            if (_map) _picked = null;
                          }),
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _searchCtrl,
                          skin: FieldSkin.page,
                          hint: l10n.propertiesSearchHintFull,
                          icon: Icons.search_rounded,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _reload(),
                          suffix: IconButton(
                            onPressed: _openTypeFilter,
                            splashRadius: 20,
                            tooltip: l10n.propertiesFilters,
                            icon: Icon(Icons.tune_rounded,
                                size: 18,
                                color: _filterType == null
                                    ? t.textSecondary
                                    : t.accent),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilterPillRow(pills: [
                          FilterPill(
                            label: l10n.propertiesAll,
                            selected: _filterStatus == null,
                            onTap: () => _setStatus(null),
                          ),
                          for (final s in PropertyStatus.values)
                            FilterPill(
                              label: propertyStatusLabel(l10n, s),
                              selected: _filterStatus == s,
                              onTap: () => _setStatus(s),
                            ),
                        ]),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _map
                        ? PropertiesMapView(
                            filters: _mapFilters,
                            initialCenter: items.map(listingPoint).firstWhere(
                                (p) => p != null,
                                orElse: () => null),
                          )
                        : _body(ctx, state, items, l10n, pad),
                  ),
                  if (!_map && _picked != null) _compareBar(l10n, pad),
                  if (!_map && _picked == null) CompareTrayBar(pad: pad),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Under the list in compare mode: what to do until two are picked, then
  /// the way to the comparison.
  Widget _compareBar(AppLocalizations l10n, double pad) {
    final t = context.tokens;
    final picked = _picked!;
    return Padding(
      key: const ValueKey('compare-bar'),
      padding: EdgeInsets.fromLTRB(
          pad, 8, pad, 8 + AppMetrics.navClearance(context)),
      child: GlassSurface(
        blur: AppMetrics.glassBlur,
        fill: t.glassFillStrong,
        borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
        shadow: GlassShadow.floating,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: picked.length < 2
              ? Text(
                  l10n.comparePickHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12.5,
                      color: t.textSecondary),
                )
              : AppFilledButton(
                  key: const ValueKey('compare-open'),
                  label: l10n.compareBarButton(picked.length),
                  onPressed: () => context.push(compareLocation(picked)),
                ),
        ),
      ),
    );
  }

  Widget _body(BuildContext ctx, PropertiesState state,
      List<PropertyResponse> items, AppLocalizations l10n, double pad) {
    if (state is PropertiesLoading || state is PropertiesInitial) {
      return ShimmerList(
        count: 4,
        padding:
            EdgeInsets.fromLTRB(pad, 0, pad, 24 + AppMetrics.navClearance(ctx)),
        cardBuilder: () => const PropertyCardBone(),
      );
    }
    if (state is PropertiesError) {
      return ErrorWidget2(
          message: apiFailureLabel(l10n, state.failure), onRetry: _reload);
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.home_work_outlined,
        title: l10n.propertiesNoProperties,
        subtitle: _searchCtrl.text.isNotEmpty ||
                _filterStatus != null ||
                _filterType != null
            ? l10n.propertiesNoResultsSubtitle
            : l10n.propertiesAddFirstListing,
      );
    }

    final loadingMore = state is PropertiesLoaded && state.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      color: ctx.tokens.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding:
            EdgeInsets.fromLTRB(pad, 0, pad, 24 + AppMetrics.navClearance(ctx)),
        itemCount: items.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, i) {
          if (i >= items.length) {
            return const ShimmerGroup(child: PropertyCardBone());
          }
          final picked = _picked;
          return PropertyCard(
            property: items[i],
            picked: picked?.contains(items[i].id),
            onTap: picked != null
                ? () => _togglePick(items[i].id)
                : () => context.go('/properties/${items[i].id}'),
          );
        },
      ),
    );
  }
}

const _kAnyType = Object();
