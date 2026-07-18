import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// List-item card for a single deal: title, status chip, client/property,
/// price/budget and agent. Tap is delegated via [onTap].
class DealCard extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onTap;
  const DealCard({super.key, required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(deal.title,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600))),
                DealStatusChip(status: deal.status),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.person_outline,
                    size: 14, color: tt.bodySmall?.color),
                const SizedBox(width: 4),
                Text(deal.clientName, style: tt.bodySmall),
                if (deal.propertyTitle != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.home_outlined,
                      size: 14, color: tt.bodySmall?.color),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(deal.propertyTitle!,
                          style: tt.bodySmall,
                          overflow: TextOverflow.ellipsis)),
                ],
              ]),
              if (deal.dealPrice != null || deal.budget != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  if (deal.dealPrice != null) ...[
                    const Icon(Icons.attach_money,
                        size: 14, color: AppColors.success),
                    Text(formatPrice(deal.dealPrice!),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success))
                  ],
                  if (deal.budget != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 14, color: tt.bodySmall?.color),
                    Text('Budget: ${formatPrice(deal.budget!)}',
                        style: tt.bodySmall)
                  ],
                ]),
              ],
              const SizedBox(height: 4),
              Text('Agent: ${deal.agentName}', style: tt.labelSmall),
            ]),
          )),
    );
  }
}
