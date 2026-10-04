import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The agency's partners: everyone in it sees them all. Narrowed on the
/// phone by kind and by a word in the name, company or phone, each with how
/// many clients it sent and what the agency owes it.
class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  final _searchCtrl = TextEditingController();
  List<Partner>? _partners;
  ApiFailure? _failure;
  PartnerKind? _kind;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q != _query) setState(() => _query = q);
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final found = await Injector.partnersRepository.getPartners();
      if (!mounted) return;
      setState(() {
        _partners = found;
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

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) await _load();
  }

  bool _matches(Partner p) {
    if (_kind != null && p.kind != _kind) return false;
    if (_query.isEmpty) return true;
    return [p.name, p.company, p.phone]
        .any((v) => v != null && v.toLowerCase().contains(_query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final all = _partners;
    final shown = all?.where(_matches).toList() ?? const <Partner>[];

    return DetailScaffold(
      title: l10n.partnersTitle,
      onRefresh: _load,
      bottomAction: all == null
          ? null
          : AppFilledButton(
              key: const ValueKey('partner-new'),
              label: l10n.partnersAdd,
              onPressed: () => _open('/partners/new'),
            ),
      children: [
        Text(
          l10n.partnersIntro,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              height: 1.45,
              color: t.textSecondary),
        ),
        if (all == null && _failure != null)
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.partnersLoadFailed,
            subtitle: apiFailureLabel(l10n, _failure!),
            action: AppGhostButton(label: l10n.coreRetry, onPressed: _retry),
          )
        else if (all == null)
          const ShimmerGroup(
            child: Column(children: [
              ShimmerNestedListCard(rows: 3),
            ]),
          )
        else if (all.isEmpty)
          EmptyState(
            icon: Icons.handshake_outlined,
            title: l10n.partnersEmpty,
            subtitle: l10n.partnersEmptyBody,
          )
        else ...[
          AppTextField(
            key: const ValueKey('partners-search'),
            controller: _searchCtrl,
            skin: FieldSkin.card,
            hint: l10n.partnersSearchHint,
            icon: Icons.search_rounded,
          ),
          FilterPillWrap(pills: [
            FilterPill(
              key: const ValueKey('partners-kind-all'),
              label: l10n.partnersFilterAll,
              selected: _kind == null,
              onTap: () => setState(() => _kind = null),
            ),
            for (final k in PartnerKind.values)
              if (all.any((p) => p.kind == k))
                FilterPill(
                  key: ValueKey('partners-kind-${k.name}'),
                  label: partnerKindLabel(l10n, k),
                  selected: _kind == k,
                  onTap: () => setState(() => _kind = k),
                ),
          ]),
          if (shown.isEmpty)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.partnersNoMatches,
            )
          else
            for (final p in shown)
              PartnerCard(
                key: ValueKey('partner-${p.id}'),
                partner: p,
                onTap: () => _open('/partners/${p.id}'),
              ),
        ],
      ],
    );
  }
}

/// A partner in the list: who, what they do, how many clients they sent and
/// what the agency owes them.
class PartnerCard extends StatelessWidget {
  final Partner partner;
  final VoidCallback onTap;

  const PartnerCard({super.key, required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final p = partner;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialAvatar(name: p.name, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  partnerSubtitle(l10n, p),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
                const SizedBox(height: 7),
                Text(
                  [
                    l10n.partnersReferredCount(p.referredClients),
                    if (p.feesOwed > 0)
                      '${l10n.partnersStatFees}: ${partnerMoney(p.feesOwed)}',
                  ].join(' · '),
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
