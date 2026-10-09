import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/star_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many starred titles the dashboard row names before it runs out of
/// room.
const kStarredEntryPreview = 3;

/// "Starred: 3" on the dashboard with the first few names, opening the
/// Starred screen. With nothing starred it says how to star instead, so the
/// way in is always there.
///
/// It reads the app-wide [StarsBloc] and draws nothing where none is
/// provided. [topGap] sits above it and goes with it.
class StarredEntryRow extends StatelessWidget {
  final VoidCallback onTap;
  final double topGap;

  const StarredEntryRow({super.key, required this.onTap, this.topGap = 0});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StarsBloc?>();
    if (bloc == null) return const SizedBox.shrink();

    return BlocBuilder<StarsBloc, StarsState>(
      bloc: bloc,
      builder: (context, state) {
        final t = context.tokens;
        final l10n = AppLocalizations.of(context);
        final loaded = state.status == StarsStatus.loaded;
        final items = state.items;
        final title = loaded && items.isNotEmpty
            ? l10n.starsEntryCount(items.length)
            : l10n.starsTitle;
        final detail = items.isNotEmpty
            ? items
                .take(kStarredEntryPreview)
                .map((item) => starredTitle(l10n, item))
                .join(', ')
            : (loaded ? l10n.starsEntryHint : '');

        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: AppCard(
            key: const ValueKey('starred-entry'),
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  items.isEmpty
                      ? Icons.star_outline_rounded
                      : Icons.star_rounded,
                  size: 18,
                  color: items.isEmpty ? t.textSecondary : t.accent,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12,
                          color: t.textSecondary)),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
              ],
            ),
          ),
        );
      },
    );
  }
}
