part of 'theme_bloc.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);

  /// What the app is actually painting, which for [ThemeMode.system] is the
  /// phone's answer rather than a stored one.
  bool isDarkIn(BuildContext context) => mode == ThemeMode.system
      ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
      : mode == ThemeMode.dark;

  bool get isDark => mode == ThemeMode.dark;
}
