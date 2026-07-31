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
      final p = await Injector.propertiesRepository.getProperty(widget.id);
      if (!mounted) return;
      setState(() {
        _p = p;
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

  /// The status the server last confirmed. The chip moves optimistically so
  /// the tap feels instant; if the write is rejected we fall back to this
  /// instead of leaving a status on screen that was never saved.
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
    // The message itself is surfaced by the list screen's listener, which
    // stays mounted underneath this route.
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
                ShimmerBox(
                    width: double.infinity,
                    height: 170,
                    radius: AppMetrics.radiusLg),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 150,
                    radius: AppMetrics.radiusMd),
                SizedBox(height: 14),
                ShimmerBox(
                    width: double.infinity,
                    height: 110,
                    radius: AppMetrics.radiusMd),
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
          if (p.description != null && p.description!.trim().isNotEmpty)
            _DescriptionCard(text: p.description!),
        ],
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────

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
          // The only 30px type in the app; scaled down rather than wrapped so
          // a ten-digit amount still fits.
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

// ─── Details ─────────────────────────────────────────────────────

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

// ─── Status ──────────────────────────────────────────────────────

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

// ─── Description ─────────────────────────────────────────────────

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
