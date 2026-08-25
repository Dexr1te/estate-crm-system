import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/search/data/recent_searches.dart';
import 'package:real_estate_crm/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_crm/features/search/presentation/bloc/search_bloc.dart';
import 'package:real_estate_crm/features/search/presentation/bloc/search_event.dart';
import 'package:real_estate_crm/features/search/presentation/bloc/search_state.dart';
import 'package:real_estate_crm/features/search/presentation/widgets/search_result_tile.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One field over the whole database.
///
/// The bloc is made here rather than in `my_app`: search is a pushed screen
/// with a life of its own, and a query is worth exactly as long as the screen
/// asking it.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SearchBloc(Injector.searchRepository, RecentSearches())
          ..add(SearchRecentLoadEvent()),
        child: const _SearchView(),
      );
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  /// Long enough that a name typed at speed costs one request rather than six,
  /// short enough that stopping to read never feels like waiting.
  static const _debounce = Duration(milliseconds: 350);

  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    setState(() {});
    if (value.trim().isEmpty) {
      context.read<SearchBloc>().add(SearchClearedEvent());
      return;
    }
    _timer = Timer(_debounce, () => _run(value));
  }

  void _run(String value) {
    if (!mounted) return;
    context.read<SearchBloc>().add(SearchQueryEvent(value));
  }

  void _submit(String value) {
    _timer?.cancel();
    _run(value);
  }

  void _useRecent(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    // The clear button is drawn from what the field holds, and filling it from
    // here is the one path that does not come through _onChanged.
    setState(() {});
    _submit(query);
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    setState(() {});
    context.read<SearchBloc>().add(SearchClearedEvent());
  }

  /// Opens a result and keeps the query that found it — the only queries worth
  /// offering back are the ones that led somewhere.
  void _open(String route, String query) {
    context.read<SearchBloc>().add(SearchRememberEvent(query));
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final pad = AppMetrics.pagePadding(context);

    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          _SearchBar(
            controller: _controller,
            onChanged: _onChanged,
            onSubmitted: _submit,
            onClear: _controller.text.isEmpty ? null : _clear,
          ),
          Expanded(
            child: AppMetrics.constrain(
              BlocBuilder<SearchBloc, SearchState>(
                builder: (ctx, state) => _body(ctx, state, l10n, pad),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext ctx, SearchState state, AppLocalizations l10n,
      double pad) {
    if (state is SearchLoading) {
      return ShimmerList(
        count: 5,
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        cardBuilder: () => const _ResultBone(),
      );
    }
    if (state is SearchError) {
      return ErrorWidget2(
        message: apiFailureLabel(l10n, state.failure),
        onRetry: () => ctx.read<SearchBloc>().add(SearchQueryEvent(state.query)),
      );
    }
    if (state is SearchLoaded) {
      if (state.results.isEmpty) {
        return EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.searchNoResults,
          subtitle: l10n.searchNoResultsSubtitle,
        );
      }
      return _results(state.query, state.results, l10n, pad);
    }

    final recent = state is SearchIdle ? state.recent : const <String>[];
    if (recent.isEmpty) {
      return EmptyState(
        icon: Icons.search_rounded,
        title: l10n.searchPromptTitle,
        subtitle: l10n.searchPromptSubtitle,
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
      children: [
        SectionHeader(
          title: l10n.searchRecent,
          actionLabel: l10n.searchClearRecent,
          onAction: () => ctx.read<SearchBloc>().add(SearchForgetAllEvent()),
        ),
        const SizedBox(height: 12),
        FilterPillWrap(pills: [
          for (final query in recent)
            FilterPill(
              label: query,
              selected: false,
              onTap: () => _useRecent(query),
            ),
        ]),
      ],
    );
  }

  Widget _results(String query, SearchResults results, AppLocalizations l10n,
      double pad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
      children: [
        ..._section(
          title: l10n.searchSectionClients,
          total: results.clients.length,
          l10n: l10n,
          rows: [
            for (final client in results.clients)
              ClientResultTile(
                client: client,
                onTap: () => _open('/clients/${client.id}', query),
              ),
          ],
        ),
        ..._section(
          title: l10n.searchSectionProperties,
          total: results.propertiesTotal,
          l10n: l10n,
          rows: [
            for (final property in results.properties)
              PropertyResultTile(
                property: property,
                onTap: () => _open('/properties/${property.id}', query),
              ),
          ],
        ),
        ..._section(
          title: l10n.searchSectionDeals,
          total: results.deals.length,
          l10n: l10n,
          rows: [
            for (final deal in results.deals)
              DealResultTile(
                deal: deal,
                onTap: () => _open('/deals/${deal.id}', query),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _section({
    required String title,
    required int total,
    required List<Widget> rows,
    required AppLocalizations l10n,
  }) {
    if (rows.isEmpty) return const [];
    return [
      const SizedBox(height: 16),
      SectionHeader(title: title, count: total),
      const SizedBox(height: 10),
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: 9),
        rows[i],
      ],
      // The listings endpoint pages. Saying how many were left behind beats a
      // header that counts two hundred above twenty rows.
      if (rows.length < total) ...[
        const SizedBox(height: 10),
        _MoreRow(label: l10n.searchMoreCount(total - rows.length)),
      ],
    ];
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
            bottom: BorderSide(color: t.border, width: AppMetrics.borderWidth)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 12, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/dashboard'),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: t.textPrimary),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              Expanded(
                child: AppTextField(
                  controller: controller,
                  autofocus: true,
                  skin: FieldSkin.page,
                  hint: l10n.searchHint,
                  icon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  suffix: onClear == null
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          splashRadius: 20,
                          tooltip: l10n.searchClear,
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: t.textSecondary),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final String label;
  const _MoreRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11.5,
        color: t.textSecondary,
      ),
    );
  }
}

class _ResultBone extends StatelessWidget {
  const _ResultBone();

  @override
  Widget build(BuildContext context) => const ShimmerBox(
      width: double.infinity, height: 64, radius: AppMetrics.radiusMd);
}
