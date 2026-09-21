part of 'theme_bloc.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);

  bool isDarkIn(BuildContext context) => mode == ThemeMode.system
      ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
      : mode == ThemeMode.dark;

  bool get isDark => mode == ThemeMode.dark;
}
