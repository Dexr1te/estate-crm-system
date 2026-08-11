import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';
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
    context.read<PropertiesBloc>().add(PropertiesLoadEvent(
          status: _filterStatus,
          type: _filterType,
          search: q.isEmpty ? null : q,
        ));
  }

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
                      content: Text(state.message),
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
                                    // Alphabetical, not source order:
                                    // gen-l10n emits (reserved, total).
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
                            const SizedBox(width: 12),
                            AppHeaderAction(
                              label: l10n.propertiesAddShort,
                              onPressed: () => context.go('/properties/new'),
                            )
                          ],
                        ),
                        const SizedBox(height: 14),
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
                  Expanded(child: _body(ctx, state, items, l10n, pad)),
                ],
              );
            },
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
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        cardBuilder: () => const PropertyCardBone(),
      );
    }
    if (state is PropertiesError) {
      return ErrorWidget2(message: state.message, onRetry: _reload);
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
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        itemCount: items.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, i) {
          if (i >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          return PropertyCard(
            property: items[i],
            onTap: () => context.go('/properties/${items[i].id}'),
          );
        },
      ),
    );
  }
}

const _kAnyType = Object();
