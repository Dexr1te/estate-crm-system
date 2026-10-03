import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/domain/repositories/change_log_repository.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_timeline.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The agency's change log for its manager: every listing, deal and client
/// created, edited or deleted, newest first, narrowed by kind of record, by
/// who made the change and by days.
class TeamChangeLogScreen extends StatefulWidget {
  const TeamChangeLogScreen({super.key});

  @override
  State<TeamChangeLogScreen> createState() => _TeamChangeLogScreenState();
}

class _TeamChangeLogScreenState extends State<TeamChangeLogScreen> {
  ChangeLogFilter _filter = const ChangeLogFilter();
  String? _actorName;

  bool get _filtered =>
      _filter.entityType != null ||
      _filter.actorId != null ||
      _filter.from != null ||
      _filter.to != null;

  Future<void> _pickActor() async {
    final l10n = AppLocalizations.of(context);
    List<AgentOption> people;
    try {
      people = await Injector.agentsRepository.getAgentOptions();
    } catch (_) {
      if (mounted) showActionUnavailable(context, l10n.changeLogPeopleFailed);
      return;
    }
    if (!mounted) return;
    final picked = await showAppBottomSheet<AgentOption?>(
      context,
      title: l10n.changeLogPickPerson,
      builder: (sheet) => SettingsGroup(rows: [
        SettingsRow(
          key: const ValueKey('change-actor-anyone'),
          label: l10n.changeLogAnyone,
          onTap: () => Navigator.of(sheet).pop(const AgentOption(
            id: -1,
            fullName: '',
          )),
        ),
        for (final p in people)
          SettingsRow(
            key: ValueKey('change-actor-${p.id}'),
            label: p.fullName,
            onTap: () => Navigator.of(sheet).pop(p),
          ),
      ]),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final anyone = picked.id < 0;
      _filter = _filter.copyWith(actorId: () => anyone ? null : picked.id);
      _actorName = anyone ? null : picked.fullName;
    });
  }

  Future<void> _pickDays() async {
    final l10n = AppLocalizations.of(context);
    final today = AppClock.now();
    final last = DateTime(today.year, today.month, today.day);
    final from = _filter.from;
    final to = _filter.to;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: last,
      initialDateRange: from != null && to != null
          ? DateTimeRange(start: from, end: to)
          : null,
      helpText: l10n.changeLogPickDays,
    );
    if (picked == null || !mounted) return;
    setState(() => _filter =
        _filter.copyWith(from: () => picked.start, to: () => picked.end));
  }

  void _clear() => setState(() {
        _filter = const ChangeLogFilter();
        _actorName = null;
      });

  String _daysLabel(AppLocalizations l10n) {
    final from = _filter.from;
    final to = _filter.to;
    if (from == null || to == null) return l10n.changeLogAnyTime;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return l10n.changeLogDays(
        formatDayMonth(from, locale), formatDayMonth(to, locale));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = _filter;
    return ChangeTimeline(
      key: ValueKey(filter),
      title: l10n.changeLogTeamTitle,
      showRecord: true,
      emptySubtitle: _filtered
          ? l10n.changeLogTeamEmptyFiltered
          : l10n.changeLogTeamEmptyBody,
      load: (page) => Injector.changeLogRepository.feed(filter, page: page),
      header: [
        FilterPillRow(pills: [
          FilterPill(
            key: const ValueKey('change-type-all'),
            label: l10n.changeLogFilterAll,
            selected: filter.entityType == null,
            onTap: () => setState(
                () => _filter = _filter.copyWith(entityType: () => null)),
          ),
          for (final type in ChangeEntityType.values)
            FilterPill(
              key: ValueKey('change-type-${type.name}'),
              label: _typeFilterLabel(l10n, type),
              selected: filter.entityType == type,
              onTap: () => setState(
                  () => _filter = _filter.copyWith(entityType: () => type)),
            ),
        ]),
        FilterPillRow(pills: [
          FilterPill(
            key: const ValueKey('change-actor'),
            label: _actorName ?? l10n.changeLogAnyone,
            selected: filter.actorId != null,
            onTap: _pickActor,
          ),
          FilterPill(
            key: const ValueKey('change-days'),
            label: _daysLabel(l10n),
            selected: filter.from != null,
            onTap: _pickDays,
          ),
          if (_filtered)
            FilterPill(
              key: const ValueKey('change-clear'),
              label: l10n.changeLogClearFilters,
              selected: false,
              onTap: _clear,
            ),
        ]),
      ],
    );
  }

  static String _typeFilterLabel(
          AppLocalizations l10n, ChangeEntityType type) =>
      switch (type) {
        ChangeEntityType.property => l10n.changeLogFilterListings,
        ChangeEntityType.deal => l10n.changeLogFilterDeals,
        ChangeEntityType.client => l10n.changeLogFilterClients,
      };
}
