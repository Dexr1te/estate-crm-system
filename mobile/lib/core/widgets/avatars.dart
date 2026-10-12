import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_surface.dart';

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
      child: _Initial(
        name: name,
        size: size,
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
        color: AppSurface.fillOf(context),
        shape: BoxShape.circle,
      ),
      child: _Initial(
        name: name,
        size: size,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
            color: t.textSecondary),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final double size;
  final TextStyle style;

  const _Initial({required this.name, required this.size, required this.style});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Icon(Icons.person_rounded, size: size * 0.5, color: style.color);
    }
    return Text(trimmed[0].toUpperCase(), style: style);
  }
}
