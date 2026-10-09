import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/keys_out_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/key_out_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// How many keys out the dashboard shows before "See all".
const kKeysOutPreview = 3;

/// The keys that are out, on the dashboard: the overdue and soonest due few,
/// each opening its listing. Nothing at all when every key is in the office,
/// a skeleton while it loads, and a failure stays inside the card. Mirrors
/// the deposits and leases cards.
///
/// [topGap] sits above the card and goes with it, so a hidden card leaves no
/// hole in the column.
class KeysOutCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final double topGap;

  const KeysOutCard({
    super.key,
    required this.onSeeAll,
    this.topGap = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeysOutBloc, KeysOutState>(
      builder: (context, state) {
        if (state is KeysOutLoaded && state.keys.isEmpty) {
          return const SizedBox.shrink(key: ValueKey('keys-out-hidden'));
        }
        return Padding(
          padding: EdgeInsets.only(top: topGap),
          child: _card(context, state),
        );
      },
    );
  }

  Widget _card(BuildContext context, KeysOutState state) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final all = state is KeysOutLoaded ? state.keys : null;
    final shown = all?.take(kKeysOutPreview).toList();
    final overdue = state is KeysOutLoaded ? state.overdueCount : 0;
    final secondary = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 12.5, color: t.textSecondary);
    final countStyle = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: overdue > 0 ? t.dangerText : t.textSecondary);

    return AppCard(
      key: const ValueKey('keys-out-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.keysOutTitle)),
              if (overdue > 0)
                Flexible(
                  child: Text(l10n.keysOutOverdueCount(overdue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: countStyle),
                )
              else if (all != null && all.length > shown!.length)
                Flexible(
                  child: Text(l10n.dashboardMandatesTotal(all.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: countStyle),
                ),
            ],
          ),
          const SizedBox(height: 11),
          if (state is KeysOutError) ...[
            Text(l10n.keysOutLoadFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('keys-out-retry'),
              label: l10n.coreRetry,
              onPressed: () =>
                  context.read<KeysOutBloc>().add(KeysOutLoadEvent()),
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ] else if (shown == null)
            const Column(children: [
              KeyOutRowBone(),
              SizedBox(height: 8),
              KeyOutRowBone(),
            ])
          else ...[
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              KeyOutRow(
                handover: shown[i],
                nested: true,
                onTap: () => context.push('/properties/${shown[i].propertyId}'),
              ),
            ],
            const SizedBox(height: 12),
            AppGhostButton(
              key: const ValueKey('keys-out-see-all'),
              label: l10n.dashboardSeeAll,
              onPressed: onSeeAll,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12.5,
            ),
          ],
        ],
      ),
    );
  }
}
