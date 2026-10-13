import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/time_off/presentation/bloc/time_off_list_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Out today: 2" on a manager's dashboard, with who, opening the team's
/// "who's out". Nothing at all while it loads, when everybody is in, or when
/// it could not be read: it is a nudge, not a card to wait for.
///
/// [topGap] sits above it and goes with it, so a hidden chip leaves no hole.
class OutTodayCard extends StatelessWidget {
  final VoidCallback onTap;
  final double topGap;

  const OutTodayCard({super.key, required this.onTap, this.topGap = 0});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimeOffListBloc, TimeOffListState>(
      builder: (context, state) {
        if (state is! TimeOffListLoaded || state.items.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('out-today-hidden'));
        }
        final t = context.tokens;
        final l10n = AppLocalizations.of(context);
        final names = state.items.map((a) => a.userName).toSet().toList();
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: AppCard(
            key: const ValueKey('out-today'),
            onTap: onTap,
            padding: EdgeInsets.symmetric(
                horizontal: AppMetrics.cardPadding(context), vertical: 13),
            child: Row(
              children: [
                Icon(Icons.beach_access_outlined,
                    size: 18, color: t.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: l10n.timeOffOutToday(names.length),
                      style: TextStyle(
                          fontSize: AppType.subhead,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                      children: [
                        TextSpan(
                          text: '  ${names.join(', ')}',
                          style: TextStyle(
                              fontSize: AppType.footnote,
                              fontWeight: FontWeight.w400,
                              color: t.textSecondary),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: AppFonts.sans),
                  ),
                ),
                const SizedBox(width: 8),
                const RowChevron(),
              ],
            ),
          ),
        );
      },
    );
  }
}
