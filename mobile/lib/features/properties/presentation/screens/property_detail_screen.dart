import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_event.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int id;
  const PropertyDetailScreen({super.key, required this.id});
  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  PropertyResponse? _p;
  List<ClientMatch> _interested = const [];
  List<MeetingResponse> _viewings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        Injector.propertiesRepository.getProperty(widget.id),
        Injector.propertiesRepository.getInterested(widget.id),
        Injector.propertiesRepository.getViewings(widget.id),
      ]);
      if (!mounted) return;
      setState(() {
        _p = results[0] as PropertyResponse;
        _interested = results[1] as List<ClientMatch>;
        _viewings = results[2] as List<MeetingResponse>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).propertiesPropertyNotFound;
      });
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.propertiesDeleteProperty,
      content: l10n.propertiesDeleteCascade(_p!.title),
    );
    if (!ok || !mounted) return;
    context.read<PropertiesBloc>().add(PropertiesDeleteEvent(widget.id));
    context.go('/properties');
  }

  PropertyStatus? _confirmedStatus;

  void _updateStatus(PropertyStatus s) {
    if (s == _p?.status) return;
    _confirmedStatus = _p?.status;
    context
        .read<PropertiesBloc>()
        .add(PropertiesUpdateStatusEvent(widget.id, s));
    setState(() => _p = _p?.copyWith(status: s));
  }

  void _onWriteResult(BuildContext _, PropertiesState state) {
    if (state is PropertiesActionSuccess) {
      _confirmedStatus = null;
    } else if (state is PropertiesActionFailure && _confirmedStatus != null) {
      setState(() => _p = _p?.copyWith(status: _confirmedStatus!));
      _confirmedStatus = null;
    }
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: '${widget.id}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context).propertiesPropertyIdCopied),
          duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = _p;

    if (_loading || p == null) {
      return DetailScaffold(
        title: l10n.propertiesProperty,
        children: [
          if (_error != null)
            EmptyState(
              icon: Icons.home_work_outlined,
              title: _error!,
              action: AppGhostButton(label: l10n.coreRetry, onPressed: _load),
            )
          else
            const ShimmerGroup(
              child: Column(children: [
                ShimmerHeroCard(lines: 1, buttons: 0),
                SizedBox(height: 14),
                ShimmerInfoCard(rows: 5, heading: true),
                SizedBox(height: 14),
                ShimmerFormCard(fields: 1),
                SizedBox(height: 14),
                ShimmerNestedListCard(rows: 2),
                SizedBox(height: 14),
                ShimmerNestedListCard(rows: 2),
              ]),
            ),
        ],
      );
    }

    return BlocListener<PropertiesBloc, PropertiesState>(
      listener: _onWriteResult,
      child: DetailScaffold(
        title: l10n.propertiesPropertyIdLabel(p.id),
        onRefresh: _load,
        actions: detailActions(
          onEdit: () => context.push('/properties/${widget.id}/edit'),
          onDelete: _delete,
          editTooltip: l10n.propertiesEdit,
          deleteTooltip: l10n.propertiesDelete,
        ),
        children: [
          _PropertyHero(property: p, onCopyId: _copyId),
          _DetailsCard(property: p),
          _StatusCard(status: p.status, onChanged: _updateStatus),
          _InterestedCard(buyers: _interested, propertyId: widget.id),
          _ViewingsCard(viewings: _viewings),
          if (p.description != null && p.description!.trim().isNotEmpty)
            _DescriptionCard(text: p.description!),
        ],
      ),
    );
  }
}

class _PropertyHero extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onCopyId;
  const _PropertyHero({required this.property, required this.onCopyId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final perSqm = property.areaSqm != null && property.areaSqm! > 0
        ? formatPrice(property.price / property.areaSqm!)
        : null;

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: t.heroText),
                    ),
                    if (property.address.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        property.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.heroTextMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PropertyStatusChip(status: property.status),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatPrice(property.price),
              maxLines: 1,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: t.heroText),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            onTap: onCopyId,
            child: Text(
              [
                if (perSqm != null) l10n.propertiesPricePerSqm(perSqm),
                l10n.propertiesPropertyIdLabel(property.id),
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  color: t.heroTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestedCard extends StatelessWidget {
  final List<ClientMatch> buyers;
  final int propertyId;
  const _InterestedCard({required this.buyers, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.propertiesInterested)),
              Text('${buyers.length}',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (buyers.isEmpty)
            Text(
              l10n.propertiesNoInterested,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            )
          else
            for (var i = 0; i < buyers.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _BuyerRow(match: buyers[i], propertyId: propertyId),
            ],
        ],
      ),
    );
  }
}

class _BuyerRow extends StatelessWidget {
  final ClientMatch match;
  final int propertyId;
  const _BuyerRow({required this.match, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final client = match.client;

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: () => context
          .push('/meetings/new?clientId=${client.id}&propertyId=$propertyId'),
      child: Row(
        children: [
          InitialAvatar(name: client.fullName, size: 34),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                if (client.phone != null && client.phone!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    client.phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        color: t.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (match.overBudget) ...[
            const SizedBox(width: 8),
            Flexible(
              child: StatusChip(
                  label: l10n.clientsOverBudget, hue: StatusHue.negotiation),
            ),
          ],
        ],
      ),
    );
  }
}

class _ViewingsCard extends StatelessWidget {
  final List<MeetingResponse> viewings;
  const _ViewingsCard({required this.viewings});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: EyebrowLabel(l10n.propertiesViewings)),
              Text('${viewings.length}',
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          if (viewings.isEmpty)
            Text(
              l10n.propertiesNoViewings,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            )
          else
            for (var i = 0; i < viewings.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _ViewingRow(viewing: viewings[i]),
            ],
        ],
      ),
    );
  }
}

class _ViewingRow extends StatelessWidget {
  final MeetingResponse viewing;
  const _ViewingRow({required this.viewing});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: () => context.push('/meetings/${viewing.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewing.clientName,
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
                  formatDateTime(viewing.scheduledAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          if (viewing.completed) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle_outline_rounded,
                size: 18, color: t.textHint),
          ],
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final PropertyResponse property;
  const _DetailsCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const dash = '—';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesDetails),
          const SizedBox(height: 13),
          DetailGrid(cells: [
            DetailCell(
                label: l10n.propertiesType,
                value: propertyTypeLabel(l10n, property.type)),
            DetailCell(
              label: l10n.propertiesArea,
              value: property.areaSqm == null
                  ? dash
                  : l10n.propertiesAreaValue(
                      property.areaSqm!.toStringAsFixed(0)),
            ),
            DetailCell(
                label: l10n.propertiesRooms,
                value: property.rooms?.toString() ?? dash),
            DetailCell(
              label: l10n.propertiesFloor,
              value: property.floor == null
                  ? dash
                  : (property.totalFloors == null
                      ? '${property.floor}'
                      : l10n.propertiesFloorOf(
                          property.floor!, property.totalFloors!)),
            ),
          ]),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final PropertyStatus status;
  final ValueChanged<PropertyStatus> onChanged;
  const _StatusCard({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesStatus),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < PropertyStatus.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: FilterPill(
                    label: propertyStatusLabel(l10n, PropertyStatus.values[i]),
                    selected: status == PropertyStatus.values[i],
                    onCard: true,
                    onTap: () => onChanged(PropertyStatus.values[i]),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
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

class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.propertiesDescription),
          const SizedBox(height: 9),
          Text(
            text,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                height: 1.55,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
