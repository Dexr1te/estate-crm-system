import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

/// Built once, not per sheet: `AppTheme.light` constructs a fresh [ThemeData]
/// on every read, and a sheet can be opened many times.
final ThemeData _sheetTheme = AppTheme.light;

/// Opens a modal bottom sheet that is **always light**, in both app themes.
///
/// Forcing only the background colour is not enough — the content would keep
/// the dark theme's near-white text and render invisible on a light sheet. So
/// the whole subtree is re-themed, which also covers text fields, list tiles
/// and icons inside sheet forms.
///
/// Prefer this over calling `showModalBottomSheet` directly: a raw call picks
/// up the ambient theme and will be dark in dark mode, which is now
/// inconsistent with every other sheet in the app.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    // Resolved here rather than left to the ambient theme, which would supply
    // the dark surface. Callers that draw their own container still pass
    // Colors.transparent explicitly and keep it.
    backgroundColor: backgroundColor ?? AppColors.surface,
    shape: shape ??
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    // Builder re-roots the caller's context below the Theme, so
    // Theme.of(context) inside `builder` sees the light theme.
    builder: (ctx) =>
        Theme(data: _sheetTheme, child: Builder(builder: builder)),
  );
}
