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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(Icons.beach_access_outlined,
                    size: 18, color: t.textSecondary),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(l10n.timeOffOutToday(names.length),
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
                  child: Text(names.join(', '),
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
