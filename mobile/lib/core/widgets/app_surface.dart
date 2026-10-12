import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

enum SurfaceLevel { page, card, nested, hero }

class AppSurface extends InheritedWidget {
  final SurfaceLevel level;

  const AppSurface({super.key, required this.level, required super.child});

  static SurfaceLevel levelOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSurface>()?.level ??
      SurfaceLevel.page;

  static Color fillOf(BuildContext context) {
    final t = context.tokens;
    return switch (levelOf(context)) {
      SurfaceLevel.page || SurfaceLevel.nested => t.surface,
      SurfaceLevel.card || SurfaceLevel.hero => t.surfaceVariant,
    };
  }

  @override
  bool updateShouldNotify(AppSurface oldWidget) => oldWidget.level != level;
}

class PagePadded extends InheritedWidget {
  const PagePadded({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PagePadded>() != null;

  @override
  bool updateShouldNotify(PagePadded oldWidget) => false;
}
