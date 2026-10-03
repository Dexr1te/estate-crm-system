import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_labels.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_sheets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One offer: the figure on the table and whose it is, the listing and the
/// buyer, the negotiation step by step, and — for whoever may — a counter
/// and the decisions. Accepting asks first, and says what happens to the
/// other offers on the listing.
class OfferScreen extends StatefulWidget {
  final int id;
  const OfferScreen({super.key, required this.id});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  PropertyOffer? _offer;
  ApiFailure? _failure;
  bool _deciding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final found = await Injector.offersRepository.getOffer(widget.id);
      if (!mounted) return;
      setState(() {
        _offer = found;
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

  Future<void> _counter(PropertyOffer o) async {
    final saved = await showCounterOfferSheet(context, o);
    if (saved != null && mounted) setState(() => _offer = saved);
  }

  Future<void> _decide(PropertyOffer o, OfferDecision decision) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: switch (decision) {
        OfferDecision.accept => l10n.offersAcceptTitle,
        OfferDecision.reject => l10n.offersRejectTitle,
        OfferDecision.withdraw => l10n.offersWithdrawTitle,
      },
      content: switch (decision) {
        OfferDecision.accept => l10n.offersAcceptConfirm(formatPrice(o.amount)),
        OfferDecision.reject => l10n.offersRejectConfirm,
        OfferDecision.withdraw => l10n.offersWithdrawConfirm,
      },
      confirmLabel: switch (decision) {
        OfferDecision.accept => l10n.offersAccept,
        OfferDecision.reject => l10n.offersReject,
        OfferDecision.withdraw => l10n.offersWithdraw,
      },
      icon: switch (decision) {
        OfferDecision.accept => Icons.handshake_outlined,
        OfferDecision.reject => Icons.block_outlined,
        OfferDecision.withdraw => Icons.undo_rounded,
      },
    );
    if (!ok || !mounted) return;
    setState(() => _deciding = true);
    try {
      final saved = await Injector.offersRepository.decide(o.id, decision);
      if (!mounted) return;
      setState(() {
        _offer = saved;
        _deciding = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _deciding = false);
      showActionUnavailable(context, offerFailureLabel(l10n, err));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = _offer;

    if (o == null) {
      return DetailScaffold(
        title: l10n.offersTitle,
        children: [
          if (_failure != null)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.offersLoadFailed,
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

    final open = o.status.isOpen;
    final canWithdraw = open || o.status == OfferStatus.accepted;

    return DetailScaffold(
      title: l10n.offersTitle,
      onRefresh: _load,
      children: [
        _Hero(offer: o),
        _Details(offer: o),
        if (o.canEdit && open) ...[
          AppFilledButton(
            key: const ValueKey('offer-accept'),
            label: l10n.offersAccept,
            loading: _deciding,
            onPressed: o.otherAccepted || _deciding
                ? null
                : () => _decide(o, OfferDecision.accept),
          ),
          Row(children: [
            Expanded(
              child: AppGhostButton(
                key: const ValueKey('offer-counter'),
                label: l10n.offersCounter,
                height: AppMetrics.buttonHeightInline,
                onPressed: _deciding ? null : () => _counter(o),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppGhostButton(
                key: const ValueKey('offer-reject'),
                label: l10n.offersReject,
                height: AppMetrics.buttonHeightInline,
                onPressed:
                    _deciding ? null : () => _decide(o, OfferDecision.reject),
              ),
            ),
          ]),
        ],
        if (o.canEdit && canWithdraw)
          AppGhostButton(
            key: const ValueKey('offer-withdraw'),
            label: l10n.offersWithdraw,
            height: AppMetrics.buttonHeightInline,
            onPressed:
                _deciding ? null : () => _decide(o, OfferDecision.withdraw),
          ),
        _History(steps: o.history),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final PropertyOffer offer;
  const _Hero({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final o = offer;
    final percent = offerPercentOfAsking(o);
    final asking = o.propertyPrice;

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('offer-listing'),
                  onTap: () => context.push('/properties/${o.propertyId}'),
                  child: Text(
                    o.propertyTitle.trim().isEmpty
                        ? '#${o.propertyId}'
                        : o.propertyTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: t.heroText),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(
                label: offerStatusLabel(l10n, o.status),
                hue: offerStatusHue(o.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            formatPrice(o.amount),
            key: const ValueKey('offer-amount-hero'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: t.heroText),
          ),
          const SizedBox(height: 5),
          Text(
            [
              offerFigureLabel(l10n, o.lastParty),
              if (percent != null) l10n.offersOfAsking(percent),
              if (asking != null && asking > 0)
                l10n.offersAsking(formatPrice(asking)),
            ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.heroTextMuted),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final PropertyOffer offer;
  const _Details({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final o = offer;
    final note = o.note?.trim() ?? '';
    final agent = o.agentName?.trim() ?? '';
    final canOpenBuyer = o.clientVisible;

    return AppCard(
      key: const ValueKey('offer-details'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (o.otherAccepted) ...[
            Text(
              l10n.offersBackup,
              key: const ValueKey('offer-backup'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: t.dangerText),
            ),
            const SizedBox(height: 11),
          ],
          GestureDetector(
            key: const ValueKey('offer-buyer-row'),
            onTap: canOpenBuyer
                ? () => context.push('/clients/${o.clientId}')
                : null,
            child: InfoRow(
                label: l10n.offersBuyer, value: offerBuyerLabel(l10n, o)),
          ),
          const SizedBox(height: 11),
          InfoRow(
            label: l10n.offersExpiresOn,
            value: o.expiresOn == null
                ? l10n.offersNoDeadline
                : offerDateLabel(o.expiresOn!, now, locale),
          ),
          if (agent.isNotEmpty) ...[
            const SizedBox(height: 11),
            InfoRow(label: l10n.offersAgent, value: agent),
          ],
          if (o.decidedAt != null) ...[
            const SizedBox(height: 11),
            InfoRow(
                label: l10n.offersDecidedOn,
                value: offerDateLabel(o.decidedAt!, now, locale)),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(note,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    height: 1.5,
                    color: t.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  final List<OfferStep> steps;
  const _History({required this.steps});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();

    return AppCard(
      key: const ValueKey('offer-history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.offersHistory),
          for (final s in steps) ...[
            const SizedBox(height: 10),
            Row(
              key: ValueKey('offer-step-${s.id}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offerStepLabel(l10n, s),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (s.actorName != null &&
                              s.actorName!.trim().isNotEmpty)
                            s.actorName!.trim(),
                          if (s.createdAt != null)
                            offerDateLabel(s.createdAt!, now, locale),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                      if (s.note != null && s.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          s.note!.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 12,
                              height: 1.4,
                              color: t.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    formatPrice(s.amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
