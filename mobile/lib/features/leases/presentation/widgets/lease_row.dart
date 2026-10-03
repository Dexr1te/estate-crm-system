import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Calls [phone], or says there is no number to call.
Future<void> callLeaseParty(BuildContext context, String? phone) async {
  final l10n = AppLocalizations.of(context);
  if (!await ContactActions.call(phone) && context.mounted) {
    showActionUnavailable(context, l10n.clientsNoPhone);
  }
}

/// One lease running out: the flat, how long is left, the rent, who lives
/// there and who lets it, and a call to each. The landlord's button is there
/// only when the deal names one.
class LeaseRow extends StatelessWidget {
  final LeaseEnding lease;
  final VoidCallback onTap;
  final bool nested;

  const LeaseRow({
    super.key,
    required this.lease,
    required this.onTap,
    this.nested = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final days = leaseDaysLeft(lease.leaseEnd, AppClock.now());
    final title = lease.propertyTitle?.isNotEmpty == true
        ? lease.propertyTitle!
        : lease.dealTitle;
    final landlord = lease.landlordName?.trim() ?? '';
    final people = [
      if (lease.tenantName.isNotEmpty) l10n.leasesTenantValue(lease.tenantName),
      if (landlord.isNotEmpty) l10n.leasesLandlordValue(landlord),
    ].join(' · ');
    final meta = [
      leaseRentLabel(l10n, lease.monthlyRent),
      if (lease.agentName?.isNotEmpty == true) lease.agentName!,
    ].join(' · ');

    return AppCard(
      key: ValueKey('lease-row-${lease.dealId}'),
      nested: nested,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  borderRadius: BorderRadius.circular(11),
                ),
                child:
                    Icon(Icons.key_outlined, size: 19, color: t.textSecondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary)),
                    const SizedBox(height: 2),
                    Text(leaseTimeLeftLabel(l10n, days),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: t.dangerText)),
                    if (people.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(people,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11.5,
                              color: t.textSecondary)),
                    ],
                    const SizedBox(height: 2),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppGhostButton(
                  key: ValueKey('lease-call-tenant-${lease.dealId}'),
                  label: l10n.leasesTenant,
                  icon: Icons.phone_outlined,
                  onPressed: () => callLeaseParty(context, lease.tenantPhone),
                  height: AppMetrics.buttonHeightInline,
                  fontSize: 12.5,
                ),
              ),
              if (lease.landlordId != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: AppGhostButton(
                    key: ValueKey('lease-call-landlord-${lease.dealId}'),
                    label: l10n.leasesLandlord,
                    icon: Icons.phone_outlined,
                    onPressed: () =>
                        callLeaseParty(context, lease.landlordPhone),
                    height: AppMetrics.buttonHeightInline,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The skeleton of a [LeaseRow], shaped like one.
class LeaseRowBone extends StatelessWidget {
  const LeaseRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          titleFactor: 0.55,
          subtitleFactor: 0.4,
        ),
      );
}
