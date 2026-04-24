import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'properties_bloc.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});
  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  PropertyStatus? _filterStatus;
  PropertyType? _filterType;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() => context
      .read<PropertiesBloc>()
      .add(PropertiesLoadEvent(status: _filterStatus, type: _filterType));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(children: [
              Expanded(
                  child: Text('Properties',
                      style: tt.titleLarge?.copyWith(fontSize: 22))),
              FilledButton.icon(
                onPressed: () => context.go('/properties/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ])),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) => context
                  .read<PropertiesBloc>()
                  .add(PropertiesLoadEvent(search: v)),
              decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.tune_outlined, size: 20),
                      onPressed: _showFilters)),
            )),
        if (_filterStatus != null || _filterType != null)
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(children: [
                if (_filterStatus != null)
                  Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                          label: Text(_filterStatus!.name,
                              style: const TextStyle(fontSize: 12)),
                          onDeleted: () {
                            setState(() => _filterStatus = null);
                            _reload();
                          })),
                if (_filterType != null)
                  Chip(
                      label: Text(_filterType!.name,
                          style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() => _filterType = null);
                        _reload();
                      }),
              ])),
        const SizedBox(height: 16),
        Expanded(
            child: BlocConsumer<PropertiesBloc, PropertiesState>(
          listener: (ctx, state) {
            if (state is PropertiesError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error));
            }
            if (state is PropertiesActionSuccess) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            if (state is PropertiesLoading) {
              return ShimmerList(
                  cardBuilder: () => const PropertyCardSkeleton());
            }
            if (state is PropertiesError) {
              return ErrorWidget2(message: state.message, onRetry: _reload);
            }
            if (state is PropertiesLoaded) {
              if (state.properties.isEmpty) {
                return const EmptyState(
                    title: 'No properties',
                    icon: Icons.home_work_outlined,
                    subtitle: 'Add your first listing');
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                color: cs.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: state.properties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = state.properties[i];
                    return _PropertyCard(
                        property: p,
                        onTap: () => context.go('/properties/${p.id}'),
                        onEdit: () => context.go('/properties/${p.id}/edit'),
                        onDelete: () async {
                          final ok = await showConfirmDialog(ctx,
                              title: 'Delete Property',
                              content: 'Delete "${p.title}"?');
                          if (ok && ctx.mounted) {
                            ctx
                                .read<PropertiesBloc>()
                                .add(PropertiesDeleteEvent(p.id));
                          }
                        });
                  },
                ),
              );
            }
            return const SizedBox();
          },
        )),
      ])),
    );
  }

  void _showFilters() => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => StatefulBuilder(
            builder: (ctx, setModal) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filters',
                          style: Theme.of(ctx).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Text('Status',
                          style: Theme.of(ctx).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        FilterChip(
                            label: const Text('All'),
                            selected: _filterStatus == null,
                            onSelected: (_) =>
                                setModal(() => _filterStatus = null)),
                        ...PropertyStatus.values.map((s) => FilterChip(
                            label: Text(s.name),
                            selected: _filterStatus == s,
                            onSelected: (_) =>
                                setModal(() => _filterStatus = s)))
                      ]),
                      const SizedBox(height: 12),
                      Text('Type', style: Theme.of(ctx).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        FilterChip(
                            label: const Text('All'),
                            selected: _filterType == null,
                            onSelected: (_) =>
                                setModal(() => _filterType = null)),
                        ...PropertyType.values.map((t) => FilterChip(
                            label: Text(t.name),
                            selected: _filterType == t,
                            onSelected: (_) => setModal(() => _filterType = t)))
                      ]),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _reload();
                          },
                          child: const Text('Apply')),
                    ]))),
      );
}

class _PropertyCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap, onEdit, onDelete;
  const _PropertyCard(
      {required this.property,
      required this.onTap,
      required this.onEdit,
      required this.onDelete});

  IconData get _icon {
    switch (property.type) {
      case PropertyType.APARTMENT:
        return Icons.apartment;
      case PropertyType.HOUSE:
        return Icons.home;
      case PropertyType.COMMERCIAL:
        return Icons.store;
      case PropertyType.LAND:
        return Icons.landscape;
      case PropertyType.OFFICE:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                Icon(_icon, color: AppColors.accent, size: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(property.title,
                                  style: tt.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              if (property.city != null)
                                Text(property.city!, style: tt.bodySmall)
                            ])),
                        PropertyStatusChip(status: property.status),
                        PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') onEdit();
                              if (v == 'delete') onDelete();
                            },
                            itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [
                                        Icon(Icons.edit_outlined, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit')
                                      ])),
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [
                                        Icon(Icons.delete_outline,
                                            size: 16, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style: TextStyle(
                                                color: AppColors.error))
                                      ]))
                                ],
                            child: Icon(Icons.more_vert,
                                color: tt.bodySmall?.color, size: 20)),
                      ]),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(children: [
                        Text(formatPrice(property.price),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                                fontFamily: 'Sora')),
                        const Spacer(),
                        if (property.areaSqm != null)
                          Row(children: [
                            Icon(Icons.square_foot,
                                size: 13, color: tt.bodySmall?.color),
                            const SizedBox(width: 3),
                            Text('${property.areaSqm!.toStringAsFixed(0)} m²',
                                style: tt.bodySmall)
                          ]),
                        if (property.rooms != null) ...[
                          const SizedBox(width: 8),
                          Row(children: [
                            Icon(Icons.bed_outlined,
                                size: 13, color: tt.bodySmall?.color),
                            const SizedBox(width: 3),
                            Text('${property.rooms} rooms', style: tt.bodySmall)
                          ])
                        ],
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: tt.bodySmall?.color),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(property.address,
                                style: tt.bodySmall,
                                overflow: TextOverflow.ellipsis))
                      ]),
                    ]))));
  }
}
