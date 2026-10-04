import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/handoff_row.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One partner: who they are and how to reach them, the fee agreed, what
/// their referrals came to, the clients they sent and the clients sent to
/// them. The numbers are counted over the clients the signed-in user sees.
class PartnerDetailScreen extends StatefulWidget {
  final int id;
  const PartnerDetailScreen({super.key, required this.id});

  @override
  State<PartnerDetailScreen> createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> {
  Partner? _partner;
  List<PartnerReferral> _referrals = const [];
  List<PartnerHandoff> _handoffs = const [];
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = Injector.partnersRepository;
    try {
      final partner = await repo.getPartner(widget.id);
      List<PartnerReferral> referrals;
      List<PartnerHandoff> handoffs;
      try {
        referrals = await repo.getReferrals(widget.id);
        handoffs = await repo.getPartnerHandoffs(widget.id);
      } catch (_) {
        // The partner reads without its lists; the numbers above still hold.
        referrals = const [];
        handoffs = const [];
      }
      if (!mounted) return;
      setState(() {
        _partner = partner;
        _referrals = referrals;
        _handoffs = handoffs;
        _failure = null;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _failure = ApiFailure.from(err));
    }
  }

  void _retry() {
    setState(() => _failure = null);
    _load();
  }

  Future<void> _edit() async {
    await context.push('/partners/${widget.id}/edit');
    if (mounted) await _load();
  }

  Future<void> _delete(Partner p) async {
    final l10n = AppLocalizations.of(context);
    if (p.referredClients > 0 || p.handoffs > 0) {
      showActionUnavailable(context, l10n.partnersInUse);
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: l10n.partnersDelete,
      content: l10n.partnersDeleteConfirm(p.name),
      confirmLabel: l10n.partnersDelete,
      icon: Icons.person_remove_outlined,
    );
    if (!ok || !mounted) return;
    try {
      await Injector.partnersRepository.delete(p.id);
      if (mounted) context.pop();
    } catch (err) {
      if (mounted) {
        showActionUnavailable(context, partnerFailureLabel(l10n, err));
      }
    }
  }

  Future<void> _openClient(int clientId) async {
    await context.push('/clients/$clientId');
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = _partner;

    if (p == null) {
      return DetailScaffold(
        title: l10n.partnersTitle,
        children: [
          if (_failure != null)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.partnersLoadFailedOne,
              subtitle: apiFailureLabel(l10n, _failure!),
              action: AppGhostButton(label: l10n.coreRetry, onPressed: _retry),
            )
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerHeroCard(lines: 2, buttons: 0),
                SizedBox(height: 14),
                ShimmerInfoCard(rows: 3),
                SizedBox(height: 14),
                ShimmerNestedListCard(rows: 2),
              ]),
            ),
        ],
      );
    }

    return DetailScaffold(
      title: l10n.partnersTitle,
      onRefresh: _load,
      actions: p.canEdit
          ? detailActions(
              onEdit: _edit,
              onDelete: () => _delete(p),
              editTooltip: l10n.partnersEdit,
              deleteTooltip: l10n.partnersDelete,
            )
          : const [],
      children: [
        _Hero(partner: p),
        _Stats(partner: p),
        _Contact(partner: p),
        _ReferralsCard(referrals: _referrals, onOpen: _openClient),
        _SentCard(handoffs: _handoffs, onOpen: _openClient),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final Partner partner;
  const _Hero({required this.partner});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final p = partner;
    final addedBy = p.createdByName?.trim();

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: t.heroText),
          ),
          const SizedBox(height: 5),
          Text(
            partnerSubtitle(l10n, p),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.heroTextMuted),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.partnersFee}: ${partnerFeeLabel(l10n, p)}',
            key: const ValueKey('partner-fee'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.heroText),
          ),
          if (addedBy != null && addedBy.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l10n.partnersAddedBy(addedBy),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  color: t.heroTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final Partner partner;
  const _Stats({required this.partner});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final p = partner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MetricsCard(
          key: const ValueKey('partner-stats'),
          metrics: [
            Metric(
                value: '${p.referredClients}',
                caption: l10n.partnersStatReferred),
            Metric(value: '${p.wonDeals}', caption: l10n.partnersStatWon),
            Metric(
                value: partnerMoney(p.feesOwed),
                caption: l10n.partnersStatFees),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [
            l10n.partnersStatsScope,
            if (p.wonDealsWithoutCommission > 0)
              l10n.partnersFeesUnknown(p.wonDealsWithoutCommission),
          ].join(' '),
          key: const ValueKey('partner-stats-note'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 11.5,
              height: 1.4,
              color: t.textSecondary),
        ),
      ],
    );
  }
}

class _Contact extends StatelessWidget {
  final Partner partner;
  const _Contact({required this.partner});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final p = partner;
    const dash = '—';
    final note = p.note?.trim();
    final phone = p.phone?.trim() ?? '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.partnersContact),
          const SizedBox(height: 12),
          InfoRow(
              label: l10n.partnersPhone, value: phone.isEmpty ? dash : phone),
          const SizedBox(height: 10),
          InfoRow(
              label: l10n.partnersEmail,
              value: p.email?.trim().isNotEmpty == true ? p.email! : dash),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              note,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.textSecondary),
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppFilledButton(
              key: const ValueKey('partner-call'),
              label: l10n.coreCall,
              onPressed: () async {
                if (!await ContactActions.call(phone) && context.mounted) {
                  showActionUnavailable(context, l10n.clientsNoPhone);
                }
              },
              height: AppMetrics.minHitTarget,
              fontSize: 12.5,
              radius: 11,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  final String title;
  final int count;
  const _CardHeading(this.title, this.count);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: EyebrowLabel(title)),
          Text('$count',
              maxLines: 1,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.textSecondary)),
        ],
      );
}

class _Quiet extends StatelessWidget {
  final String text;
  const _Quiet(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12.5,
            height: 1.4,
            color: context.tokens.textSecondary),
      );
}

class _ReferralsCard extends StatelessWidget {
  final List<PartnerReferral> referrals;
  final ValueChanged<int> onOpen;
  const _ReferralsCard({required this.referrals, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      key: const ValueKey('partner-referrals'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeading(l10n.partnersReferrals, referrals.length),
          const SizedBox(height: 11),
          if (referrals.isEmpty)
            _Quiet(l10n.partnersNoReferrals)
          else
            for (var i = 0; i < referrals.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              PartnerReferralRow(
                referral: referrals[i],
                onTap: () => onOpen(referrals[i].clientId),
              ),
            ],
        ],
      ),
    );
  }
}

/// A client a partner sent: who, which agent holds them, their won deals
/// and the fee on them.
class PartnerReferralRow extends StatelessWidget {
  final PartnerReferral referral;
  final VoidCallback onTap;

  const PartnerReferralRow(
      {super.key, required this.referral, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final r = referral;
    final agent = r.agentName?.trim() ?? '';
    final deals = r.wonDeals == 0
        ? l10n.partnersReferralNoDeals
        : [
            l10n.partnersReferralWon(r.wonDeals),
            if (r.feeOwed > 0)
              l10n.partnersReferralFee(partnerMoney(r.feeOwed)),
          ].join(' · ');

    return AppCard(
      key: ValueKey('referral-${r.clientId}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: Row(
        children: [
          InitialAvatar(name: r.fullName, size: 32),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  [clientTypeLabel(l10n, r.type), if (agent.isNotEmpty) agent]
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  deals,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: t.textPrimary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: t.textHint),
        ],
      ),
    );
  }
}

class _SentCard extends StatelessWidget {
  final List<PartnerHandoff> handoffs;
  final ValueChanged<int> onOpen;
  const _SentCard({required this.handoffs, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      key: const ValueKey('partner-handoffs'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeading(l10n.partnersSentClients, handoffs.length),
          const SizedBox(height: 11),
          if (handoffs.isEmpty)
            _Quiet(l10n.partnersNoSentClients)
          else
            for (var i = 0; i < handoffs.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              HandoffRow(
                handoff: handoffs[i],
                showClient: true,
                onTap: () => onOpen(handoffs[i].clientId),
              ),
            ],
        ],
      ),
    );
  }
}
