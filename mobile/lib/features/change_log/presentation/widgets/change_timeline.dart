import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/domain/change_entry.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_entry_card.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

typedef ChangePageLoader = Future<PagedResponse<RecordChange>> Function(
    int page);

/// A change log as a screen: newest first, the next page read as the reader
/// nears the end, a skeleton while the first one comes, and a failure that
/// says so with a retry. [header] sits above the entries, for filters.
class ChangeTimeline extends StatefulWidget {
  final String title;
  final ChangePageLoader load;
  final List<Widget> header;
  final bool showRecord;
  final String emptySubtitle;

  const ChangeTimeline({
    super.key,
    required this.title,
    required this.load,
    required this.emptySubtitle,
    this.header = const [],
    this.showRecord = false,
  });

  @override
  State<ChangeTimeline> createState() => _ChangeTimelineState();
}

class _ChangeTimelineState extends State<ChangeTimeline> {
  final List<RecordChange> _items = [];
  bool _loaded = false;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _page = 0;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final first = await widget.load(0);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(first.content);
        _page = 0;
        _hasMore = first.hasMore;
        _loaded = true;
        _failure = null;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _failure = ApiFailure.from(err));
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = await widget.load(_page + 1);
      if (!mounted) return;
      setState(() {
        final known = _items.map((c) => c.id).toSet();
        _items.addAll(next.content.where((c) => !known.contains(c.id)));
        _page += 1;
        _hasMore = next.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _retry() {
    setState(() => _failure = null);
    _load();
  }

  bool _nearEnd(ScrollNotification s) {
    if (s.metrics.axis == Axis.vertical && s.metrics.extentAfter < 400) {
      _loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _nearEnd,
      child: DetailScaffold(
        title: widget.title,
        onRefresh: _load,
        children: [...widget.header, ..._body(l10n)],
      ),
    );
  }

  List<Widget> _body(AppLocalizations l10n) {
    final failure = _failure;
    if (failure != null) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.changeLogLoadFailed,
          subtitle: apiFailureLabel(l10n, failure),
          action: AppGhostButton(label: l10n.coreRetry, onPressed: _retry),
        ),
      ];
    }
    if (!_loaded) {
      return [for (var i = 0; i < 4; i++) const ChangeEntryBone()];
    }
    if (_items.isEmpty) {
      return [
        EmptyState(
          icon: Icons.history_rounded,
          title: l10n.changeLogEmptyTitle,
          subtitle: widget.emptySubtitle,
        ),
      ];
    }
    return [
      for (final entry in groupChanges(_items))
        ChangeEntryCard(
          entry: entry,
          showRecord: widget.showRecord,
          onOpenRecord: _opener(entry),
        ),
      if (_loadingMore) const ChangeEntryBone(),
    ];
  }

  VoidCallback? _opener(ChangeEntry entry) {
    if (!widget.showRecord) return null;
    final location = changeEntityLocation(entry.entityType, entry.entityId);
    if (location == null) return null;
    return () => context.push(location);
  }
}
