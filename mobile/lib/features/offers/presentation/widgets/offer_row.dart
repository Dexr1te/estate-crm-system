import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One offer in a list: the figure on the table and where it stands, then who
/// made it (on a listing) or which listing it is on (on a buyer), how it sits
/// against the asking price, its deadline, and whether another offer on the
/// listing has been accepted while this one waits.
class OfferRow extends StatelessWidget {
  final PropertyOffer offer;

  /// On a buyer's card the listing is what tells offers apart; on a
  /// listing's, the buyer.
  final bool showListing;
  final VoidCallback onTap;

  const OfferRow({
    super.key,
    required this.offer,
    required this.onTap,
    this.showListing = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = offer;
    final percent = offerPercentOfAsking(o);
    final who = showListing
        ? (o.propertyTitle.trim().isEmpty
            ? '#${o.propertyId}'
            : o.propertyTitle)
        : offerBuyerLabel(l10n, o);
    final expires = o.expiresOn;

    return AppCard(
      key: ValueKey('offer-row-${o.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(o.amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: StatusChip(
                  label: offerStatusLabel(l10n, o.status),
                  hue: offerStatusHue(o.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              who,
              if (percent != null) l10n.offersOfAsking(percent),
            ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.textSecondary),
          ),
          if (o.status.isOpen && expires != null) ...[
            const SizedBox(height: 3),
            Text(
              l10n.offersValidUntil(
                  offerDateLabel(expires, AppClock.now(), locale)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textHint),
            ),
          ],
          if (o.otherAccepted) ...[
            const SizedBox(height: 6),
            Text(
              l10n.offersBackup,
              key: ValueKey('offer-backup-${o.id}'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: t.dangerText),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small grey heading inside an offers card.
class OfferListHeading extends StatelessWidget {
  final String text;
  const OfferListHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: context.tokens.textSecondary),
      );
}
