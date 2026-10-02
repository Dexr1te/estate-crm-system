import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/open_house_labels.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/schedule_open_house_sheet.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/visitor_sign_in_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One open house: when and where, its summary, and the sign-in sheet with a
/// button to add the next visitor that is never more than a thumb away.
class OpenHouseScreen extends StatefulWidget {
  final int id;
  const OpenHouseScreen({super.key, required this.id});

  @override
  State<OpenHouseScreen> createState() => _OpenHouseScreenState();
}

class _OpenHouseScreenState extends State<OpenHouseScreen> {
  OpenHouse? _openHouse;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final found = await Injector.openHousesRepository.getOpenHouse(widget.id);
      if (!mounted) return;
      setState(() {
        _openHouse = found;
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

  Future<void> _addVisitors() async {
    final added = await showVisitorSignInSheet(context, openHouseId: widget.id);
    if (added.isNotEmpty && mounted) await _load();
  }

  Future<void> _edit(OpenHouse o) async {
    final saved = await showScheduleOpenHouseSheet(context,
        propertyId: o.propertyId, existing: o);
    if (saved != null && mounted) await _load();
  }

  Future<void> _delete(OpenHouse o) async {
    final l10n = AppLocalizations.of(context);
    if (o.visitorCount > 0) {
      showActionUnavailable(context, l10n.openHouseHasVisitors);
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: l10n.openHouseDelete,
      content: l10n.openHouseDeleteConfirm,
      confirmLabel: l10n.openHouseDelete,
      icon: Icons.event_busy_outlined,
    );
    if (!ok || !mounted) return;
    try {
      await Injector.openHousesRepository.delete(o.id);
      if (mounted) context.pop();
    } catch (err) {
      if (mounted) {
        showActionUnavailable(context, openHouseFailureLabel(l10n, err));
      }
    }
  }

  Future<void> _removeVisitor(OpenHouseVisitor v) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.openHouseRemoveVisitor,
      content: l10n.openHouseRemoveVisitorConfirm(v.fullName),
      confirmLabel: l10n.openHouseRemoveVisitor,
      icon: Icons.person_remove_outlined,
    );
    if (!ok || !mounted) return;
    try {
      await Injector.openHousesRepository.removeVisitor(widget.id, v.id);
      if (mounted) await _load();
    } catch (err) {
      if (mounted) {
        showActionUnavailable(context, openHouseFailureLabel(l10n, err));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = _openHouse;

    if (o == null) {
      return DetailScaffold(
        title: l10n.openHouseTitle,
        children: [
          if (_failure != null)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.openHouseLoadFailed,
              subtitle: apiFailureLabel(l10n, _failure!),
              action: AppGhostButton(label: l10n.coreRetry, onPressed: _retry),
            )
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerHeroCard(lines: 2, buttons: 0),
                SizedBox(height: 14),
                ShimmerInfoCard(rows: 2),
                SizedBox(height: 14),
                ShimmerNestedListCard(rows: 3),
              ]),
            ),
        ],
      );
    }

    final now = AppClock.now();
    return DetailScaffold(
      title: l10n.openHouseTitle,
      onRefresh: _load,
      actions: o.canEdit
          ? detailActions(
              onEdit: () => _edit(o),
              onDelete: () => _delete(o),
              editTooltip: l10n.openHouseEdit,
              deleteTooltip: l10n.openHouseDelete,
            )
          : const [],
      children: [
        _Hero(openHouse: o, now: now),
        MetricsCard(metrics: [
          Metric(
              value: '${o.visitorCount}',
              caption: l10n.openHouseSummaryVisitors),
          Metric(
              value: '${o.newClientCount}',
              caption: l10n.openHouseSummaryNewClients),
          Metric(
              value: '${o.interestedCount}',
              caption: l10n.openHouseSummaryInterested),
        ]),
        AppFilledButton(
          key: const ValueKey('open-house-add-visitor'),
          label: l10n.openHouseAddVisitor,
          onPressed: _addVisitors,
        ),
        _SignInSheet(
          visitors: o.visitors,
          onRemove: _removeVisitor,
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final OpenHouse openHouse;
  final DateTime now;
  const _Hero({required this.openHouse, required this.now});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = openHouse;
    final host = o.agentName?.trim();
    final note = o.note?.trim();

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('open-house-listing'),
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
              if (o.isOn(now)) ...[
                const SizedBox(width: 10),
                StatusChip(label: l10n.openHouseLive, hue: StatusHue.positive),
              ],
            ],
          ),
          if (o.propertyAddress != null &&
              o.propertyAddress!.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            _HeroLine(o.propertyAddress!, color: t.heroTextMuted),
          ],
          const SizedBox(height: 14),
          Text(
            openHouseWhen(o, locale),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: t.heroText),
          ),
          if (host != null && host.isNotEmpty) ...[
            const SizedBox(height: 6),
            _HeroLine(l10n.openHouseHost(host), color: t.heroTextMuted),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              note,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.heroTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroLine extends StatelessWidget {
  final String text;
  final Color color;
  const _HeroLine(this.text, {required this.color});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style:
            TextStyle(fontFamily: AppFonts.sans, fontSize: 11.5, color: color),
      );
}

class _SignInSheet extends StatelessWidget {
  final List<OpenHouseVisitor> visitors;
  final ValueChanged<OpenHouseVisitor> onRemove;

  const _SignInSheet({required this.visitors, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      key: const ValueKey('open-house-sheet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.openHouseSignInSheet)),
              Text('${visitors.length}',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (visitors.isEmpty)
            EmptyState(
              icon: Icons.how_to_reg_outlined,
              title: l10n.openHouseNoVisitors,
              subtitle: l10n.openHouseNoVisitorsHint,
            )
          else
            for (var i = 0; i < visitors.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              VisitorRow(
                visitor: visitors[i],
                onRemove:
                    visitors[i].canRemove ? () => onRemove(visitors[i]) : null,
              ),
            ],
        ],
      ),
    );
  }
}

/// One line of the sign-in sheet: who, their number, whether they are new to
/// the agency and how keen they said they were. Opens the client when the
/// signed-in user may.
class VisitorRow extends StatelessWidget {
  final OpenHouseVisitor visitor;
  final VoidCallback? onRemove;

  const VisitorRow({super.key, required this.visitor, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final v = visitor;
    final note = v.note?.trim();
    final colleague = v.clientAgentName?.trim();
    final canOpen = v.clientVisible && v.clientId != null;

    return AppCard(
      key: ValueKey('visitor-${v.id}'),
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.fromLTRB(12, 11, 4, 11),
      onTap: canOpen ? () => context.push('/clients/${v.clientId}') : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialAvatar(name: v.fullName, size: 34),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.fullName,
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
                  [
                    v.phone,
                    if (v.signedInAt != null) formatTimeOfDay(v.signedInAt!),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusChip(
                      label: v.newClient
                          ? l10n.openHouseNewClient
                          : l10n.openHouseKnownClient,
                      hue: v.newClient ? StatusHue.positive : StatusHue.neutral,
                    ),
                    if (v.interest != null)
                      StatusChip(
                        label: openHouseInterestLabel(l10n, v.interest!),
                        hue: v.interest == OpenHouseInterest.interested
                            ? StatusHue.lead
                            : StatusHue.neutral,
                      ),
                  ],
                ),
                if (!v.clientVisible &&
                    colleague != null &&
                    colleague.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.openHouseColleagueClient(colleague),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textSecondary),
                  ),
                ],
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
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
          if (onRemove != null)
            SizedBox(
              width: AppMetrics.minHitTarget,
              height: AppMetrics.minHitTarget,
              child: IconButton(
                key: ValueKey('visitor-remove-${v.id}'),
                padding: EdgeInsets.zero,
                tooltip: l10n.openHouseRemoveVisitor,
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 17, color: t.textHint),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
