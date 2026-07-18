import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

/// A pill-style filter tab used in the deals list to filter by status.
class DealFilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const DealFilterTab(
      {super.key,
      required this.label,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final unselectedBorder =
        isDark ? AppColors.darkBorder : const Color(0xFFE8ECF4);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? cs.primary : unselectedBg,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: selected ? cs.primary : unselectedBorder),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                    color: selected ? Colors.white : tt.bodySmall?.color)),
          )),
    );
  }
}
