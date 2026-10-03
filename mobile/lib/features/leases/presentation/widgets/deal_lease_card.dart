import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/renew_lease_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A rent deal's lease: the rent, from when to when, how long is left, when
/// the agent is reminded and who lets the place; and, on a won rent, a way to
/// renew it. [onRenewed] gets the deal as the server has it after a renewal.
class DealLeaseCard extends StatefulWidget {
  final DealResponse deal;
  final ValueChanged<DealResponse> onRenewed;

  const DealLeaseCard({super.key, required this.deal, required this.onRenewed});

  @override
  State<DealLeaseCard> createState() => _DealLeaseCardState();
}

class _DealLeaseCardState extends State<DealLeaseCard> {
  bool _saving = false;

  bool _canRenew(BuildContext context) {
    try {
      final me = context.watch<AuthBloc>().currentUser;
      if (me == null) return false;
      return me.role == Role.ADMIN ||
          me.role == Role.MANAGER ||
          widget.deal.agentId == me.userId;
    } catch (_) {
      // No signed-in user above this card: nothing to renew as.
      return false;
    }
  }

  Future<void> _renew() async {
    final l10n = AppLocalizations.of(context);
    final renewal = await showRenewLeaseSheet(context, widget.deal);
    if (renewal == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final t = context.tokens;
    setState(() => _saving = true);
    try {
      final deal =
          await Injector.leasesRepository.renew(widget.deal.id, renewal);
      if (!mounted) return;
      setState(() => _saving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(l10n.leasesRenewed,
                maxLines: 2, overflow: TextOverflow.ellipsis)));
      widget.onRenewed(deal);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            backgroundColor: t.dangerSolid,
            content: Text(l10n.leasesRenewFailed,
                maxLines: 2, overflow: TextOverflow.ellipsis)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final deal = widget.deal;
    final now = AppClock.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final start = deal.leaseStart;
    final end = deal.leaseEnd;
    final days = end == null ? null : leaseDaysLeft(end, now);
    final warning = leaseEnding(deal, now);
    final landlord = deal.landlordName?.trim() ?? '';
    final reminder =
        deal.leaseReminderDaysEffective ?? kDefaultLeaseReminderDays;

    return AppCard(
      key: const Key('deal-lease-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.leasesTitle),
          const SizedBox(height: 13),
          if (deal.monthlyRent != null) ...[
            InfoRow(
                label: l10n.leasesMonthlyRent,
                value: formatPrice(deal.monthlyRent!)),
            const SizedBox(height: 11),
          ],
          if (start != null) ...[
            InfoRow(
                label: l10n.leasesStart,
                value: leaseDateLabel(start, now, locale)),
            const SizedBox(height: 11),
          ],
          if (end != null) ...[
            InfoRow(
                label: l10n.leasesEnd, value: leaseDateLabel(end, now, locale)),
            const SizedBox(height: 4),
            Text(
              leaseTimeLeftLabel(l10n, days!),
              key: Key('deal-lease-left${warning ? '-warning' : ''}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: warning ? t.dangerText : t.textHint),
            ),
            const SizedBox(height: 11),
          ],
          InfoRow(
              label: l10n.leasesReminder,
              value: l10n.leasesReminderValue(reminder)),
          if (landlord.isNotEmpty) ...[
            const SizedBox(height: 11),
            InfoRow(label: l10n.leasesLandlord, value: landlord),
          ],
          if (leaseRenewable(deal)) ...[
            if (_canRenew(context)) ...[
              const SizedBox(height: 14),
              AppGhostButton(
                key: const Key('deal-lease-renew'),
                label: l10n.leasesRenew,
                icon: Icons.event_repeat_outlined,
                loading: _saving,
                height: AppMetrics.buttonHeightInline,
                onPressed: _saving ? null : _renew,
              ),
            ],
          ] else if (deal.status != DealStatus.CLOSED_LOST) ...[
            const SizedBox(height: 11),
            Text(l10n.leasesRenewWhenWon,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    color: t.textSecondary)),
          ],
        ],
      ),
    );
  }
}
