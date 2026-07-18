import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subColor =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary;
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontFamily: 'Sora')),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: subColor,
                              fontFamily: 'Sora')),
                      if (subtitle != null)
                        Text(subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: subColor)),
                    ],
                  ),
                ),
              ],
            ),
          ])),
    );
  }
}
