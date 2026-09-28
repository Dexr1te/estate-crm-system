import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/features/compare/presentation/widgets/compare_send_bar.dart';
import 'package:real_estate_crm/features/compare/presentation/widgets/compare_table.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Two to four listings side by side, opened at `/compare?ids=1,2,3`. With
/// `client=` the buyer's fit shows as a row of its own.
class CompareScreen extends StatefulWidget {
  final List<int> ids;
  final int? clientId;

  const CompareScreen({super.key, required this.ids, this.clientId});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<ComparedListing>? _listings;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _listings = null;
      _failure = null;
    });
    try {
      final repo = Injector.propertiesRepository;
      final properties = await Future.wait(widget.ids.map((id) => repo
          .getProperty(id)
          .then<PropertyResponse?>((p) => p)
          .catchError((Object _) => null)));
      final found = properties.whereType<PropertyResponse>().toList();
      if (found.isEmpty && widget.ids.isNotEmpty) {
        // Nothing came back at all: say why, rather than "pick two".
        await repo.getProperty(widget.ids.first);
      }
      final views = await Future.wait(found.map((p) => repo
          .getShareLink(p.id)
          .then<int?>((link) => link.url == null ? null : link.viewCount)
          .catchError((Object _) => null)));
      List<PropertyMatch>? matches;
      final clientId = widget.clientId;
      if (clientId != null) {
        try {
          matches = await Injector.clientsRepository.getMatches(clientId);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() => _listings = [
            for (var i = 0; i < found.length; i++)
              ComparedListing(found[i],
                  linkViews: views[i],
                  fit: matches == null ? null : buyerFit(found[i].id, matches)),
          ]);
    } catch (e) {
      if (!mounted) return;
      setState(() => _failure = ApiFailure.from(e));
    }
  }

  void _remove(int id) {
    Injector.comparisonTray.remove(id);
    setState(() => _listings = [
          for (final l in _listings ?? const <ComparedListing>[])
            if (l.property.id != id) l,
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final listings = _listings;

    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          DetailAppBar(
            title: l10n.compareTitle,
            trailingLabel: listings == null || listings.length < 2
                ? null
                : '${listings.length}',
          ),
          Expanded(child: _body(context, l10n, listings)),
        ],
      ),
      bottomNavigationBar: listings != null && listings.length >= 2
          ? CompareSendBar(listings: listings)
          : null,
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n,
      List<ComparedListing>? listings) {
    final failure = _failure;
    if (failure != null) {
      return ErrorWidget2(
          message: apiFailureLabel(l10n, failure), onRetry: _load);
    }
    if (listings == null) return const CompareSkeleton();
    if (listings.length < 2) {
      return EmptyState(
        icon: Icons.compare_arrows_rounded,
        title: l10n.compareNeedTwo,
        subtitle: l10n.compareNeedTwoHint,
      );
    }
    final t = context.tokens;
    final pad = AppMetrics.pagePadding(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.compareBestLegend,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.textSecondary),
          ),
          const SizedBox(height: 8),
          CompareTable(
            listings: listings,
            now: AppClock.now(),
            onOpen: (id) => context.push('/properties/$id'),
            onRemove: _remove,
          ),
        ],
      ),
    );
  }
}
