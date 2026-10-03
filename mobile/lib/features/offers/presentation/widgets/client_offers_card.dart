import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_row.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/property_offers_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A buyer's offers on their card, the latest first: the ones in play, then
/// the closed ones, each naming its listing. Offers are recorded from the
/// listing, so this card only reads. Reads on its own.
class ClientOffersCard extends StatefulWidget {
  final int clientId;

  const ClientOffersCard({super.key, required this.clientId});

  @override
  State<ClientOffersCard> createState() => _ClientOffersCardState();
}

class _ClientOffersCardState extends State<ClientOffersCard> {
  List<PropertyOffer>? _offers;
  bool _failed = false;
  bool _allClosed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final found =
          await Injector.offersRepository.getForClient(widget.clientId);
      if (mounted) {
        setState(() {
          _offers = found;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _retry() {
    setState(() => _failed = false);
    _load();
  }

  Future<void> _open(PropertyOffer o) async {
    await context.push('/offers/${o.id}');
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final all = _offers;

    if (all == null && !_failed) {
      return const ShimmerGroup(child: ShimmerInfoCard(rows: 2, heading: true));
    }

    final inPlay = (all ?? const <PropertyOffer>[]).where(offerInPlay).toList();
    final closed =
        (all ?? const <PropertyOffer>[]).where((o) => !offerInPlay(o)).toList();
    final closedShown =
        _allClosed ? closed : closed.take(offersClosedShown).toList();

    return AppCard(
      key: const ValueKey('client-offers'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.offersCardTitle)),
              if (all != null)
                Text('${all.length}',
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (_failed) ...[
            Text(l10n.offersListLoadFailed,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary)),
            const SizedBox(height: 10),
            AppGhostButton(
              key: const ValueKey('client-offers-retry'),
              label: l10n.coreRetry,
              height: AppMetrics.buttonHeightInline,
              onPressed: _retry,
            ),
          ] else ...[
            if (all!.isEmpty)
              Text(
                l10n.offersClientNone,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    height: 1.4,
                    color: t.textSecondary),
              ),
            for (var i = 0; i < inPlay.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              OfferRow(
                  offer: inPlay[i],
                  showListing: true,
                  onTap: () => _open(inPlay[i])),
            ],
            if (closedShown.isNotEmpty) ...[
              if (inPlay.isNotEmpty) const SizedBox(height: 14),
              OfferListHeading(l10n.offersClosedHeading),
              for (final o in closedShown) ...[
                const SizedBox(height: 8),
                OfferRow(offer: o, showListing: true, onTap: () => _open(o)),
              ],
              if (closed.length > closedShown.length) ...[
                const SizedBox(height: 4),
                AppGhostButton(
                  key: const ValueKey('client-offers-show-all'),
                  label: l10n.offersShowAll,
                  height: AppMetrics.minHitTarget,
                  fontSize: 12.5,
                  onPressed: () => setState(() => _allClosed = true),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
