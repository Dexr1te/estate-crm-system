import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/star_labels.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/starred_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The records the signed-in person starred, as clients, listings and deals,
/// newest first in each. A row opens its record; its star takes it off the
/// list at once, and puts it back with a message if the server says no.
class StarredScreen extends StatefulWidget {
  const StarredScreen({super.key});

  @override
  State<StarredScreen> createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen> {
  late final StarsBloc _bloc = context.read<StarsBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(StarsLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<StarsBloc, StarsState>(
      bloc: _bloc,
      listenWhen: isNewStarFailure,
      listener: (context, state) =>
          showStarFailure(context, state.writeFailure!),
      builder: (context, state) => DetailScaffold(
        title: l10n.starsTitle,
        onRefresh: () async => _bloc.add(StarsLoadEvent()),
        children: _body(context, state, l10n),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, StarsState state, AppLocalizations l10n) {
    if (state.status == StarsStatus.failure) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.starsLoadFailed,
          subtitle: state.loadFailure == null
              ? null
              : apiFailureLabel(l10n, state.loadFailure!),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _bloc.add(StarsLoadEvent())),
        ),
      ];
    }
    if (state.status != StarsStatus.loaded) {
      return [
        const ShimmerGroup(child: ShimmerSectionHeader(hasAction: false)),
        for (var i = 0; i < 3; i++) const StarredRowBone(),
      ];
    }
    if (state.items.isEmpty) {
      return [
        EmptyState(
          key: const ValueKey('starred-empty'),
          icon: Icons.star_outline_rounded,
          title: l10n.starsEmptyTitle,
          subtitle: l10n.starsEmptyHint,
        ),
      ];
    }
    return [
      for (final type in StarType.values)
        ...() {
          final items = state.ofType(type);
          if (items.isEmpty) return const <Widget>[];
          return <Widget>[
            SectionHeader(
              key: ValueKey('starred-section-${type.wire}'),
              title: starSectionLabel(l10n, type),
              count: items.length,
            ),
            for (final item in items)
              StarredRow(
                item: item,
                onTap: () => context.push(starredRecordRoute(item.key)),
                onUnstar: () => _bloc.add(StarsToggleEvent(item.key,
                    title: item.title, subtitle: item.subtitle)),
              ),
          ];
        }(),
    ];
  }
}
