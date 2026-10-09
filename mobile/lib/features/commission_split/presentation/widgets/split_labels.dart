import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/payout_widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A share as the card writes it: "50%".
String splitPercentLabel(AppLocalizations l10n, double percent) =>
    l10n.splitsPercent(formatRate(percent));

/// Who a share is, under their name: the deal's agent, a colleague, or a
/// co-broker and their agency.
String splitPartyLabel(AppLocalizations l10n, CommissionShare share) {
  switch (share.kind) {
    case CommissionPartyKind.AGENT:
      return l10n.splitsDealAgent;
    case CommissionPartyKind.COLLEAGUE:
      return share.active ? l10n.splitsColleague : l10n.splitsInactive;
    case CommissionPartyKind.CO_BROKER:
      final agency = share.agency?.trim() ?? '';
      return agency.isEmpty
          ? l10n.splitsCoBroker
          : l10n.splitsCoBrokerFrom(agency);
  }
}

/// A refusal in words: the server's rules this app knows by their code, the
/// server's own text otherwise.
String splitFailureLabel(AppLocalizations l10n, ApiFailure failure) =>
    switch (failure.serverCode) {
      'SPLIT_TOTAL_NOT_100' => l10n.splitsTotalMustBe100,
      'SPLIT_COLLEAGUE_INACTIVE' => l10n.splitsColleagueInactive,
      'SPLIT_PARTY_REQUIRED' => l10n.splitsCoBrokerNameMissing,
      _ => payoutFailureLabel(l10n, failure) ?? apiFailureLabel(l10n, failure),
    };

/// The line under the leaderboard's and the goals' totals saying how a split
/// deal counts.
class CommissionShareNote extends StatelessWidget {
  const CommissionShareNote({super.key});

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context).splitsShareNote,
        key: const Key('commission-share-note'),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12,
            height: 1.4,
            color: context.tokens.textSecondary),
      );
}
