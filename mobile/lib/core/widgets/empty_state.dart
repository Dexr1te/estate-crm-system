import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyState(
      {super.key,
      required this.title,
      this.subtitle,
      required this.icon,
      this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? const Color(0xFF252A3D) : const Color(0xFFEEF1F8);
    final iconColor =
        isDark ? const Color(0xFF4A5070) : const Color(0xFFADB5CC);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDark ? const Color(0xFFF0F2FF) : const Color(0xFF0F1E3C),
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? const Color(0xFF8B9CC8) : const Color(0xFF6B7A99),
        );

    return Center(
        child: Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: titleStyle?.copyWith(fontSize: 20),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(subtitle!, style: subtitleStyle, textAlign: TextAlign.center)
            ],
            if (action != null) ...[const SizedBox(height: 22), action!],
          ]),
        ),
      ),
    ));
  }
}
