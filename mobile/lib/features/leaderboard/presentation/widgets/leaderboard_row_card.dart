import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Money in the agency's own currency, as the server named it for this board.
String leaderboardMoney(double amount, String? currency,
        {bool compact = true}) =>
    formatMoney(
      amount,
      currency == null ? AppCurrency.current : Currency.fromCode(currency),
      AppCurrency.locale,
      compact: compact,
    );

String leaderboardPercent(double? rate, String none) =>
    rate == null ? none : '${(rate * 100).round()}%';

/// The figure a row leads with: whatever the board is sorted by.
String leaderboardValue(AppLocalizations l10n, LeaderboardRow row,
    LeaderboardSort sort, String? currency) {
  switch (sort) {
    case LeaderboardSort.commission:
      return leaderboardMoney(row.commission, currency);
    case LeaderboardSort.dealsWon:
      return '${row.dealsWon}';
    case LeaderboardSort.viewings:
      return '${row.viewingsHeld}';
    case LeaderboardSort.newClients:
      return '${row.newClients}';
    case LeaderboardSort.winRate:
      return leaderboardPercent(row.winRate, l10n.leaderboardNoValue);
  }
}

/// One person on the board: place, name, the sorted-by figure and the rest
/// in one line. [muted] rows are the deactivated ones, kept apart.
class LeaderboardRowCard extends StatelessWidget {
  final LeaderboardRow row;
  final LeaderboardSort sort;
  final String? currency;
  final bool muted;
  final VoidCallback onTap;

  const LeaderboardRowCard({
    super.key,
    required this.row,
    required this.sort,
    required this.currency,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final leader = !muted && row.rank == 1;
    return AppCard(
      key: ValueKey('leaderboard-row-${row.agentId}'),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              muted ? l10n.leaderboardNoValue : '${row.rank ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: leader ? t.primary : t.textSecondary,
              ),
            ),
          ),
          InitialAvatar(name: row.fullName, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: muted ? t.textSecondary : t.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.leaderboardSummary(
                      row.dealsWon, row.viewingsHeld, row.newClients),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              leaderboardValue(l10n, row, sort, currency),
              key: ValueKey('leaderboard-value-${row.agentId}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: muted ? t.textSecondary : t.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row's own figures, all of them, for the period on the board.
Future<void> showLeaderboardAgentSheet(
  BuildContext context, {
  required LeaderboardRow row,
  required String? currency,
  required String period,
}) {
  final l10n = AppLocalizations.of(context);
  final role = Role.values.where((r) => r.name == row.role).firstOrNull;
  return showAppBottomSheet<void>(
    context,
    title: row.fullName,
    subtitle: role == null ? period : '${roleLabel(l10n, role)} · $period',
    builder: (ctx) {
      final rows = <(String, String)>[
        (
          l10n.leaderboardSortCommission,
          leaderboardMoney(row.commission, currency, compact: false)
        ),
        (
          l10n.leaderboardWonValue,
          leaderboardMoney(row.wonValue, currency, compact: false)
        ),
        (l10n.leaderboardSortDealsWon, '${row.dealsWon}'),
        (l10n.leaderboardDealsLost, '${row.dealsLost}'),
        (
          l10n.leaderboardSortWinRate,
          leaderboardPercent(row.winRate, l10n.leaderboardNoValue)
        ),
        (l10n.leaderboardSortViewings, '${row.viewingsHeld}'),
        (l10n.leaderboardSortNewClients, '${row.newClients}'),
      ];
      return Column(
        key: const ValueKey('leaderboard-agent-sheet'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            InfoRow(label: rows[i].$1, value: rows[i].$2),
          ],
          const SizedBox(height: 8),
        ],
      );
    },
  );
}
