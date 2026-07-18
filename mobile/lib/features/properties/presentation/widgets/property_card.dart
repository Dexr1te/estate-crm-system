import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// List-item card for a single property: type icon, title/city, status chip,
/// price, area/rooms and address. Actions are delegated via callbacks.
class PropertyCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap, onEdit, onDelete;
  const PropertyCard(
      {super.key,
      required this.property,
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
                                color: AppColors.accent.withAlpha(31),
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
