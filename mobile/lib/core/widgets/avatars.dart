import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.isDark ? t.surfaceVariant : t.primary,
      ),
      child: Text(
        _initial(name),
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
            color: t.accent),
      ),
    );

    if (onTap == null) return avatar;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: avatar),
    );
  }
}

class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  const InitialAvatar({super.key, required this.name, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: t.border, width: AppMetrics.borderWidth),
      ),
      child: Text(
        _initial(name),
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
            color: t.textPrimary),
      ),
    );
  }
}

String _initial(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
}
